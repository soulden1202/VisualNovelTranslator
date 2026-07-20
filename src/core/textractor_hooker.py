import subprocess
import threading
import re
import ctypes
import psutil
import os
import io

class TextractorHooker:
    def __init__(self, textractor_dir):
        self.textractor_dir = textractor_dir
        self.process = None
        self.read_thread = None
        self.stderr_thread = None
        self.running = False
        self._manual_stop = False
        self.active_threads = {}  # Format: {raw_bracket_content: {"name": name, "last_text": text}}
        self.selected_thread_id = None
        self.on_text_hooked = None  # Callback function for new text
        self.on_thread_list_changed = None  # Callback when new thread is discovered
        self.on_process_exited = None  # Callback(reason: str) when TextractorCLI dies unexpectedly
        self.pid = None
        self._last_stderr_lines = []
        # Many VN engines redraw the current line repeatedly as it types on
        # screen (typewriter effect), so the hook fires many times per line
        # with a growing substring each time. Firing the callback on every
        # single event translates half-typed fragments instead of the
        # finished line -- debounce so it only fires once the text for the
        # selected thread has stopped changing for a moment.
        self._debounce_seconds = 0.4
        self._debounce_timer = None
        self._pending_text = ""

    def is_32bit_process(self, pid):
        """Detect process architecture using ctypes"""
        PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
        kernel32 = ctypes.windll.kernel32
        h_process = kernel32.OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, pid)
        if not h_process:
            h_process = kernel32.OpenProcess(0x0400, False, pid)
        if h_process:
            try:
                is_wow64 = ctypes.c_int()
                if kernel32.IsWow64Process(h_process, ctypes.byref(is_wow64)):
                    return bool(is_wow64.value)
            finally:
                kernel32.CloseHandle(h_process)
        return False

    def attach(self, pid):
        self.stop()
        self._manual_stop = False

        # Select correct CLI based on process architecture
        cli_name = "TextractorCLI.exe"
        sub_folder = "x86" if self.is_32bit_process(pid) else "x64"
        cli_path = os.path.join(self.textractor_dir, sub_folder, cli_name)

        if not os.path.exists(cli_path):
            raise FileNotFoundError(f"TextractorCLI not found at {cli_path}")

        self.pid = pid
        self.active_threads.clear()
        self._last_stderr_lines = []

        # Windows specifics: hide console window
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW

        # Binary stdin (commands are hand-encoded as UTF-16LE, confirmed by
        # testing against a real game -- see _read_loop/_stderr_loop for why
        # stdout/stderr are wrapped instead of read raw).
        self.process = subprocess.Popen(
            [cli_path],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            bufsize=0,
            startupinfo=startupinfo
        )
        self.running = True

        # TextractorCLI's stdout/stderr are UTF-16LE (confirmed empirically).
        # Wrapping with TextIOWrapper decodes 2-byte-aligned and only looks for
        # newlines *after* decoding. Reading raw bytes and splitting on the
        # single 0x0A byte (as an earlier version of this code did) corrupts
        # every line after the first: UTF-16LE encodes '\n' as two bytes
        # (0A 00), so a raw byte-level readline() stops right after the 0A
        # and leaves the trailing 00 as an orphan at the front of the next
        # read, shifting every subsequent 2-byte character pairing by one byte.
        self._stdout_reader = io.TextIOWrapper(self.process.stdout, encoding='utf-16-le', errors='replace', newline='')
        self._stderr_reader = io.TextIOWrapper(self.process.stderr, encoding='utf-16-le', errors='replace', newline='')

        # Start reading threads
        self.read_thread = threading.Thread(target=self._read_loop, daemon=True)
        self.read_thread.start()

        self.stderr_thread = threading.Thread(target=self._stderr_loop, daemon=True)
        self.stderr_thread.start()

        # Send attach command
        self.send_command(f"attach -P{pid}\n")

    def send_command(self, cmd):
        if self.process and self.process.stdin:
            try:
                if not cmd.endswith("\n"):
                    cmd += "\n"
                self.process.stdin.write(cmd.encode("utf-16-le"))
                self.process.stdin.flush()
            except (IOError, ValueError):
                pass

    def _read_loop(self):
        # Any bracketed prefix is treated as a hook identifier -- the exact
        # number/meaning of the colon-separated fields inside isn't confirmed
        # yet, so the whole bracket content is used as the thread key rather
        # than assuming a fixed field layout.
        pattern = re.compile(r"^\[([^\]]*)\]\s?(.*)$")
        try:
            while self.running:
                line = self._stdout_reader.readline()
                if not line:
                    break
                line = line.strip()
                if not line:
                    continue

                print(f"[TextractorCLI] {line}")

                match = pattern.match(line)
                if not match:
                    continue

                bracket, text = match.groups()
                # The leading numeric/address fields are volatile per-call
                # (confirmed empirically: two calls from the same hook
                # differed in both the first field AND a later address
                # field). The only fields that stay constant are the last
                # three -- hookcode@offset:module:function, e.g.
                # "HW8@0:gdi32.dll:GetGlyphOutlineW" -- Textractor's own
                # hook-code notation, which is the real hook identity.
                # Keying on more than that fragments one logical thread
                # into many and silently drops most calls.
                fields = bracket.split(":")
                thread_key = ":".join(fields[-3:]) if len(fields) >= 3 else bracket
                name = fields[-3] if len(fields) >= 3 else bracket

                is_new_thread = thread_key not in self.active_threads

                # Register or update the thread
                self.active_threads[thread_key] = {"name": name, "last_text": text}

                if is_new_thread and self.on_thread_list_changed:
                    self.on_thread_list_changed()

                # If this is our selected thread, schedule translation (debounced)
                if thread_key == self.selected_thread_id and self.on_text_hooked:
                    self._schedule_hook_callback(text)
        except Exception as e:
            print(f"Error reading from Textractor: {e}")
        finally:
            # stdout closing while we were still meant to be running means the
            # CLI process died (crash, game closed, antivirus kill, etc.) rather
            # than us calling stop() -- surface that instead of going silent.
            was_running = self.running
            self.running = False
            if was_running and not self._manual_stop and self.on_process_exited:
                reason = self._last_stderr_lines[-1] if self._last_stderr_lines else "TextractorCLI process exited unexpectedly"
                self.on_process_exited(reason)

    def _schedule_hook_callback(self, text):
        """Reset the debounce timer on every new event; only fire on_text_hooked
        once the selected thread's text has stopped changing for a moment.

        Different hooks feed text differently: some resend the whole line so
        far on every call (typewriter effect -- each call is a superset of
        the last), others send one fragment/character per call (confirmed
        for GetGlyphOutlineW, which is a Win32 API that takes a single
        character per call). Handle both without needing to know which:
        if the new text extends what's already pending, treat it as the
        latest snapshot; otherwise append it as a new fragment.
        """
        if self._debounce_timer:
            self._debounce_timer.cancel()
        else:
            self._pending_text = ""

        if text.startswith(self._pending_text):
            self._pending_text = text
        else:
            self._pending_text += text

        def fire():
            accumulated = self._pending_text
            self._pending_text = ""
            if self.on_text_hooked:
                self.on_text_hooked(accumulated)

        self._debounce_timer = threading.Timer(self._debounce_seconds, fire)
        self._debounce_timer.daemon = True
        self._debounce_timer.start()

    def _stderr_loop(self):
        try:
            while True:
                line = self._stderr_reader.readline()
                if not line:
                    break
                line = line.strip()
                if line:
                    print(f"[TextractorCLI stderr] {line}")
                    self._last_stderr_lines.append(line)
                    self._last_stderr_lines = self._last_stderr_lines[-10:]
        except Exception:
            pass

    def stop(self):
        self._manual_stop = True
        self.running = False
        if self._debounce_timer:
            self._debounce_timer.cancel()
            self._debounce_timer = None
        self._pending_text = ""
        if self.process:
            try:
                self.process.terminate()
            except Exception:
                pass
            self.process = None
        self.active_threads.clear()
        self.selected_thread_id = None
