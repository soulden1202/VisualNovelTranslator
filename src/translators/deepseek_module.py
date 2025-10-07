from openai import OpenAI

class DeepSeekTranslator:
    def __init__(self , API_KEY, context,):
        self.client = OpenAI(api_key=API_KEY, base_url="https://api.deepseek.com")
        self.context = context
    
    def translate_text(self, text):
        response = self.client.chat.completions.create(
            model="deepseek-chat",
            messages=[
                {"role": "system", "content": self.context},
                {"role": "user", "content": text},
            ],
            stream=False
        )
        print(response)
        return response.choices[0].message.content