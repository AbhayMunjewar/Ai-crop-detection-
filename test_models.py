import google.generativeai as genai
import warnings
warnings.filterwarnings('ignore')

genai.configure(api_key="AIzaSyAIeKu_yzJDd4xUmfxC4NGYW4BpioZBAs4")

models = [m.name for m in genai.list_models() if 'generateContent' in m.supported_generation_methods]
with open('models_output.txt', 'w') as f:
    f.write('\n'.join(models))

print("Models written to file.")
