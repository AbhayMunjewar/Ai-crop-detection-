import google.generativeai as genai
import json

genai.configure(api_key="AIzaSyAIeKu_yzJDd4xUmfxC4NGYW4BpioZBAs4")

clean_disease_name = "Grape Black rot"

prompt = f"""You are a plant pathology expert. A crop disease has been identified as: {clean_disease_name}.
Provide the response strictly in JSON format with the following keys:
"cause": "A brief explanation of what causes the disease",
"prevention": "A brief explanation of how to prevent it",
"treatment": "A brief explanation of how to treat it",
"farming_advice": "Some general farming advice related to this"
Make the text concise, informative, and professional."""

try:
    gemini_model = genai.GenerativeModel('gemini-pro')
    response = gemini_model.generate_content(prompt)
    response_text = response.text
    print("Raw Response:", response_text)
except Exception as e:
    print("Gemini API Error:", str(e))
    try:
        print("\nAvailable models you can use:")
        for m in genai.list_models():
            if 'generateContent' in m.supported_generation_methods:
                print(m.name)
    except Exception as list_e:
        print("Could not list models:", str(list_e))
