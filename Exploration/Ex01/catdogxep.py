from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from tensorflow.keras.models import load_model
from PIL import Image
import numpy as np

# FastAPI 앱 생성
app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 출처 허용 (Flutter 앱 포함)
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드 허용
    allow_headers=["*"],  # 모든 헤더 허용
)

# 모델 로드
model = load_model('./xception_cats_vs_dogs_model.keras')

# 이미지 전처리 함수
def preprocess_image(image: Image.Image):
    image = image.resize((150, 150))  # 모델 입력 크기로 조정
    image_array = np.array(image) / 255.0  # 정규화
    image_array = np.expand_dims(image_array, axis=0)  # 배치 차원 추가
    return image_array

# API 엔드포인트: 이미지 업로드 및 예측
@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    try:
        # 이미지 열기
        image = Image.open(file.file).convert("RGB")
        
        # 이미지 전처리
        processed_image = preprocess_image(image)
        
        # 예측 수행
        prediction = model.predict(processed_image)[0]
        result = {
            "Cat": f"{(1 - prediction[0]) * 100:.2f}%",
            "Dog": f"{prediction[0] * 100:.2f}%"
        }
        return {"success": True, "result": result}
    except Exception as e:
        return {"success": False, "error": str(e)}
