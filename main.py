import sys
import os
import threading
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtQuick import QQuickWindow
from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot
import pyperclip
import subprocess


from gemini_module import GeminiTranslator
from deepseek_module import DeepSeekTranslator



class Backend(QObject):
    def __init__(self):
        QObject.__init__(self)

        
        
   
        
    #signal to update the translation    
    translatedText = pyqtSignal(str, arguments=['updater'])


    
    def updater(self, translated_text):
        self.translatedText.emit(translated_text)
    
    def get_clipboard_text(self):
        ret = subprocess.getoutput("powershell.exe -Command Get-Clipboard")  
        return ret
        

    def bootUp(self):
        t_thread = threading.Thread(target=self._bootUp)
        t_thread.daemon = True
        t_thread.start()
        
    def _bootUp(self):
        
        #Provide context for LLM model here
        role = "You are a translator that translate visual novel from Japanese to English and here is the context of the visual novel that you are translating you don't have to expalin your thought just return the most accurate translation"
        context = "A long time ago, a group of special girls known as ‘mahou shoujos’ saved the world after a fierce battle where blood and tears were shed and prayers were made. It was an overly common battle tale. However, no one thanked or praised them for their victory. In fact, no one even knew them at all. Even so, the future of humanity was protected and it came to a happy end. Now around ten years later, it was spring, the season of meetings and farewells. Those who had once saved the world have forgotten ‘magic’ and lived as normal girls with ordinary encounters and problems. Taiga was approached by the transfer student Haru, who made a request of him: “Please turn me back into a mahou shoujo."

        
        Translator = GeminiTranslator(os.getenv('GEMINI_API_KEY'), role + context)
        
        #For deepseek model
        #Translator = DeepSeekTranslator(os.getenv('DEEPSEEK_API_KEY'), role + context)
                     
        last_sentence = ""
        
        #empty clipboard when application starts
        pyperclip.copy("") 

    
        while True:
            clipboard_text = self.get_clipboard_text()                
            
            #check if clipboard text is empty or current sentence is the same with the last, then skip this iteration                                                    
            if clipboard_text == last_sentence or clipboard_text == "":
                continue              
            else:
                last_sentence = clipboard_text                
                new_translated_text  = Translator.translate_text(clipboard_text) 
                print(new_translated_text)                         
                self.updater(new_translated_text)

                
    @pyqtSlot()
    def close_button(self):
        app.quit()
    @pyqtSlot()
    def setting_button(self):
        engine.load('./UI/setting.qml')
        
        
QQuickWindow.setSceneGraphBackend('software')
app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.quit.connect(app.quit)
engine.load('./UI/main.qml')
back_end = Backend()
engine.rootObjects()[0].setProperty('backend', back_end)
back_end.bootUp()
sys.exit(app.exec())
