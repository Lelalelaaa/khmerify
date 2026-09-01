# uvicorn main:app --port 8000 --reload

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from engine.rule_engine import convert as khmer_convert

class ConvertRequest(BaseModel):
    input: str

@app.post("/convert")
def convert(request: ConvertRequest):
    return {"output": khmer_convert(request.input)}
    
