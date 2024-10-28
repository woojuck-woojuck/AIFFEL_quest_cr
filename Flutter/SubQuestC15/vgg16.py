from fastapi import FastAPI, UploadFile, File, HTTPException
from tensorflow.keras.applications import VGG16
from tensorflow.keras.applications.vgg16 import preprocess_input, decode_predictions
from tensorflow.keras.preprocessing import image
import numpy as np
import uvicorn
import io
from PIL import Image
import logging
from fastapi.middleware.cors import CORSMiddleware

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load the VGG16 model
model = VGG16(weights="imagenet")
logger.info("VGG16 모델 로드 완료")

# Initialize FastAPI app
app = FastAPI()

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인에서의 접근 허용
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        # Load image file
        contents = await file.read()
        img = Image.open(io.BytesIO(contents)).convert("RGB")
        logger.info(f"이미지 로드 완료, 크기: {img.size}")
        
        # Resize image while maintaining aspect ratio
        img.thumbnail((224, 224))  # Resize image keeping aspect ratio
        logger.info(f"이미지 크기 조정 완료, 크기: {img.size}")
        
        # Pad the image to make it 224x224
        new_img = Image.new("RGB", (224, 224), (0, 0, 0))
        new_img.paste(img, ((224 - img.size[0]) // 2, (224 - img.size[1]) // 2))
        logger.info(f"이미지 패딩 완료, 크기: {new_img.size}")
        
        # Preprocess the image
        img_array = image.img_to_array(new_img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = preprocess_input(img_array)
        logger.info(f"이미지 전처리 완료, 배열 크기: {img_array.shape}")
        
        # Make prediction
        predictions = model.predict(img_array)
        logger.info(f"예측 완료, 예측값: {predictions}")
        decoded_predictions = decode_predictions(predictions, top=3)[0]
        logger.info(f"디코딩된 예측값: {decoded_predictions}")
        
        # Prepare response
        response = []
        for i, (imagenet_id, label, score) in enumerate(decoded_predictions):
            response.append({"rank": i + 1, "label": label, "score": float(score)})
        
        # Get the highest probability class and confidence
        highest_prob_class = decoded_predictions[0][1]
        confidence = float(decoded_predictions[0][2])
        
        return {"predicted_food": highest_prob_class, "confidence": confidence, "top_3_predictions": response}
    except Exception as e:
        logger.error(f"예측 중 오류 발생: {str(e)}")
        raise HTTPException(status_code=500, detail=f"예측 중 오류가 발생했습니다: {str(e)}")

# Run the server if the script is executed directly
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=5000)
