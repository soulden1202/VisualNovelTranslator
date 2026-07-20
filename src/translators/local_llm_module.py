from openai import OpenAI, APIConnectionError, APITimeoutError

class LocalLLMTranslator:
    def __init__(self, API_KEY, context):
        from src.managers.config_manager import ConfigManager
        config = ConfigManager().load_config()

        self.base_url = config.get('local_llm_url', 'http://localhost:11434/v1')
        self.model = config.get('local_llm_model', 'gemma4')
        # Use API_KEY if set, otherwise default to "local"
        # timeout/max_retries: a hung or unreachable local server should fail
        # fast instead of blocking the translation loop indefinitely
        self.client = OpenAI(api_key=API_KEY or "local", base_url=self.base_url, timeout=30.0, max_retries=1)
        self.context = context

    def translate_text(self, text):
        print(self.context)
        print(text)
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self.context},
                    {"role": "user", "content": text},
                ],
                stream=False
            )
            return response.choices[0].message.content
        except APIConnectionError:
            return f"Error: Could not reach local LLM server at {self.base_url}. Make sure it's running."
        except APITimeoutError:
            return f"Error: Local LLM at {self.base_url} timed out after 30s. Model '{self.model}' may be too slow or still loading."
        except Exception as e:
            print(f"Error in LocalLLM translation: {e}")
            return f"Error: Local LLM translation failed. Make sure your local server is running at {self.base_url} with model {self.model}.\nDetails: {str(e)}"
