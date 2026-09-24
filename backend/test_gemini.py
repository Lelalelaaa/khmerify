import os
from dotenv import load_dotenv
import google.generativeai as genai
from engine.rule_engine import convert_by_gemini

# Load environment variables
load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")
print(f"Loaded API Key: {'Yes' if api_key and api_key != 'your_key_here' else 'No (or default)'}")

# Test the Gemini function directly
test_word = "arkoun" # romanized for 'thank you'
print(f"\nAsking Gemini to translate: '{test_word}'...")

result = convert_by_gemini(test_word)
if result:
    print(f"Success! Gemini says: {result}")
else:
    print("Failed. No result from Gemini.")
