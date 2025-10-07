# VN Translator

[![Build Status](https://img.shields.io/badge/build_status-status)](https://github.com/soulden1202/VisualNovelTranslator/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python Version](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)

A real-time Visual Novel translator powered by LLMs (Large Language Models). Translate Japanese visual novels to English instantly using Gemini or DeepSeek AI, with support for multiple API keys and a customizable overlay interface.

![Screenshot 1](https://github.com/user-attachments/assets/9b2ff66f-8c67-4be9-be56-4dde0db4dde7)
![Screenshot 2](https://github.com/user-attachments/assets/e8bce674-d224-4365-9ad9-2989875cf55d)
![Screenshot 3](https://github.com/user-attachments/assets/dea5cd69-26c1-4b71-827f-d0228a93ca41)


## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
  - [Download Pre-built Executable](#option-1-download-pre-built-executable-recommended)
  - [Run from Source](#option-2-run-from-source)
- [Usage Guide](#usage-guide)
  - [Setup](#setup)
  - [Running](#running)
  - [Tips](#tips)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Features

- **Real-time Translation**: Automatic clipboard monitoring with instant translation
- **Multiple AI Models**: Support for Gemini and DeepSeek (easily extensible)
- **Multi-API Key Management**: Add multiple API keys per model with automatic rotation
- **Customizable Overlay**:
  - Adjustable window size and position
  - Customizable font, size, and color
  - Transparency control
  - Always-on-top, frameless design
- **Smart Translation**: Context-aware prompts for better accuracy
- **Easy Model Switching**: Change between AI models on the fly

## Quick Start

### Option 1: Download Pre-built Executable (Recommended)

1. Download the latest `VNTranslator.exe` from [Releases](https://github.com/soulden1202/VisualNovelTranslator/releases)
2. Run the executable
3. Configure your API keys in Settings → Manage API Keys
4. Start your visual novel and Textractor
5. Begin playing!

### Option 2: Run from Source

#### Prerequisites

- Python 3.9 or higher
- [Poetry](https://python-poetry.org/docs/#installation) for dependency management
- [Textractor](https://github.com/Artikash/Textractor) for text hooking
- API key for [Gemini](https://ai.google.dev/gemini-api/docs/pricing) or [DeepSeek](https://api-docs.deepseek.com)

#### Installation

```bash
# Clone the repository
git clone https://github.com/soulden1202/VisualNovelTranslator.git
cd VisualNovelTranslator

# Install Poetry (if not already installed)
pip install poetry

# Install dependencies
poetry install

# Run the application
poetry run python main.py
```

## Usage Guide

### Setup

1. **Get API Keys**:

   - **Gemini**: Get free API key at [Google AI Studio](https://ai.google.dev/gemini-api/docs/pricing) (1M free tokens/month)
   - **DeepSeek**: Get API key at [DeepSeek Platform](https://api-docs.deepseek.com)

2. **Install Textractor**:

   - Download from [Textractor GitHub](https://github.com/Artikash/Textractor)
   - Extract and run `Textractor.exe`

3. **Configure VN Translator**:
   - Open Settings (A button in top-right)
   - Click "🔑 Manage API Keys"
   - Add your API key(s)
   - Select preferred model
   - Customize appearance and translation prompt if desired

### Running

1. Start your Visual Novel
2. Launch Textractor and hook the game process
3. Launch VN Translator
4. Select the appropriate text thread in Textractor
5. Text will automatically translate and appear in the overlay

### Tips

- **Multiple API Keys**: Add multiple keys to automatically switch when quota limits are reached
- **Custom Prompts**: Adjust the translation prompt for better character consistency and style
- **Window Position**: Drag the overlay window to position it anywhere on screen
- **Font Selection**: Choose fonts that support Japanese characters for best display

## 🔧 Configuration

### Settings Window

Access via the **A** button in the top-right corner:

- **Height/Width**: Adjust overlay window dimensions
- **Color**: Choose text color via color picker
- **Size**: Set font size (1-200px)
- **Font**: Select from installed system fonts
- **Model**: Switch between Gemini, DeepSeek, or other registered models
- **LLM Prompt**: Customize the translation instructions

### API Key Management

Click **"🔑 Manage API Keys"** in Settings:

- Add multiple API keys per model
- Set active key with "Set Active" button
- Delete unused keys
- Keys are stored with Base64 obfuscation locally

### Configuration Files

- `config.json` - Application settings (window size, colors, prompt, etc. Auto-generated, gitignored)
- `api_keys.json` - Encrypted API keys storage (auto-generated, gitignored)

**Example `config.json`:**

```json
{
  "window_width": 1500,
  "window_height": 300,
  "window_opacity": 0.1,
  "text_color": "#2d567f",
  "text_size": 15,
  "text_font": "Segoe UI Black",
  "prompt": "You are a translator specializing in Japanese visual novels...",
  "selected_model": "Gemini"
}
```

**Example `api_keys.json`:**

```json
{
{
    "GEMINI_API_KEY": {
        "keys": [
          "key1",
          "key2"
        ],
        "active_index": 1
    }
}
}
```

## Development

### Setting Up Development Environment

See [SETUP.md](SETUP.md) for detailed development setup instructions.

```bash
# Install Poetry
pip install poetry

# Install dependencies
poetry install

# Activate virtual environment
poetry shell

# Run the application
python main.py
```

### Project Structure

```
VisualNovelTranslator/
├── UI/                          # QML interface files
│   ├── main.qml                 # Main overlay window
│   ├── SettingsWindow.qml       # Settings dialog
│   ├── APIKeyWindow.qml         # API key management
│   ├── Notification.qml         # Toast notifications
│   └── ...                      # Other UI components
├── main.py                      # Application entry point
├── config_manager.py            # Configuration handling
├── api_key_manager.py           # API key management
├── model_registry.py            # Model registration system
├── gemini_module.py             # Gemini translator
├── deepseek_module.py           # DeepSeek translator
├── pyproject.toml               # Poetry dependencies
├── VNTranslator.spec            # PyInstaller build config
└── tests/                       # Test files
```

### Adding a New Translation Model

1. Create a new translator module:

```python
# mymodel_module.py
class MyModelTranslator:
    def __init__(self, API_KEY, context):
        self.api_key = API_KEY
        self.context = context
        # Initialize your model client here

    def translate_text(self, text):
        # Implement translation logic
        response = your_api_call(text)
        return response
```

2. Register in `model_registry.py`:

```python
from mymodel_module import MyModelTranslator

class ModelRegistry:
    MODELS = {
        'Gemini': (GeminiTranslator, 'GEMINI_API_KEY'),
        'DeepSeek': (DeepSeekTranslator, 'DEEPSEEK_API_KEY'),
        'MyModel': (MyModelTranslator, 'MYMODEL_API_KEY'),
    }
```

3. Add dependencies:

```bash
poetry add your-model-sdk
```

4. Rebuild and test!

### Running Tests

```bash
# Run all tests
poetry run pytest

# Run with coverage
poetry run pytest --cov

# Run specific test file
poetry run pytest tests/test_config_manager.py
```

### Code Quality

```bash
# Format code with Black
poetry run black .

# Sort imports with isort
poetry run isort .

# Lint with Flake8
poetry run flake8 .
```

### Building Executable

```bash
# Build with PyInstaller
poetry run pyinstaller VNTranslator.spec

# Output will be in dist/VNTranslator.exe
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Ways to contribute:**

- Report bugs and suggest features
- Add support for new translation models
- Improve UI/UX
- Write documentation
- Add tests
- Fix bugs

## Roadmap

- [ ] Add support for more AI models (Claude, GPT-4, etc.)
- [ ] Translation caching to reduce API calls
- [ ] History/logging of translations
- [ ] Export translations to file
- [ ] Auto-detect language
- [ ] Custom dictionary/glossary support
- [ ] macOS and Linux support
- [ ] Better error handling and retry logic
- [ ] Translation memory system
- [ ] UI themes

## Known Issues

- Clipboard monitoring uses PowerShell on Windows (may be slow)
- QML files must be in correct path for PyInstaller builds
- Some fonts may not display Japanese characters properly

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Textractor](https://github.com/Artikash/Textractor) - Essential text hooking tool
- [Google Gemini](https://ai.google.dev/) - Powerful and free translation API
- [DeepSeek](https://www.deepseek.com/) - High-quality translation model
- [PyQt6](https://www.riverbankcomputing.com/software/pyqt/) - Cross-platform UI framework
- The Visual Novel community for inspiration

## Support

- **Issues**: [GitHub Issues](https://github.com/soulden1202/VisualNovelTranslator/issues)
- **Discussions**: [GitHub Discussions](https://github.com/soulden1202/VisualNovelTranslator/discussions)

## Star

If you find this project useful, please consider giving it a star!

---

**Made with ❤️ for Visual Novel fans who can't wait for official translations**
