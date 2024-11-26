from fastapi import FastAPI
from transformers import MT5ForConditionalGeneration, MT5Tokenizer
import uvicorn
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# 모델 로드
model_name = "google/mt5-small"  # mT5 모델 사용 (다국어 지원)
tokenizer = MT5Tokenizer.from_pretrained(model_name)
model = MT5ForConditionalGeneration.from_pretrained(model_name)

# FastAPI 앱 초기화
app = FastAPI()

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 요청 데이터 모델 정의
class TextRequest(BaseModel):
    text: str

@app.post("/summarize/")
async def summarize(request: TextRequest):
    input_text = "summarize: " + request.text
    input_ids = tokenizer.encode(input_text, return_tensors="pt", max_length=512, truncation=True)

    # 요약 생성
    summary_ids = model.generate(input_ids, max_length=150, min_length=30, length_penalty=2.0, num_beams=4, early_stopping=True)
    summary = tokenizer.decode(summary_ids[0], skip_special_tokens=True)

    return {"summary": summary}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
