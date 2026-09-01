from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class ConvertRequest(BaseModel):
    input: str

@app.post("/convert")
def convert(request: ConvertRequest):
    return {"output": request.input}