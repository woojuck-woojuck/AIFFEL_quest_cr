from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from diffusers import StableDiffusionPipeline
import torch
import os

app = FastAPI()

# Static 파일 디렉토리 생성
output_dir = "generated_images"
os.makedirs(output_dir, exist_ok=True)  # 디렉토리가 없으면 생성

# Static 파일 마운트
app.mount("/images", StaticFiles(directory=output_dir), name="images")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Stable Diffusion 모델 로드
device = "cuda" if torch.cuda.is_available() else "cpu"
pipe = StableDiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5")
pipe = pipe.to(device)

class Prompt(BaseModel):
    text: str

@app.post("/generate/")
async def generate_image(prompt: Prompt):
    try:
        # 이미지 생성
        image = pipe(prompt.text, num_inference_steps=50, guidance_scale=7.5).images[0]
        # 파일 저장
        image_path = os.path.join(output_dir, "generated_image.png")
        image.save(image_path)
        # URL 반환
        return {"image_url": f"http://127.0.0.1:8000/images/generated_image.png"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
