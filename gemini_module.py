
from google import genai
from google.genai import types


class GeminiTranslator:
    
    def __init__(self , API_KEY, context,):
        self.client = genai.Client(api_key=API_KEY)
        self.context = context
        
        
    def translate_text(self, text):
        response = self.client.models.generate_content(
            model="gemini-2.0-flash",
            config=types.GenerateContentConfig(
                system_instruction=self.context),
            contents=[text]
        )
        print(response)
        return response.text