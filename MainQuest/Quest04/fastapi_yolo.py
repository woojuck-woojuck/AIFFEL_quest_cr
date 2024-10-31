from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
from ultralytics import YOLO
from PIL import Image
import base64
import io
import cv2
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
import logging
from fastapi.responses import HTMLResponse

# 로깅 설정
logging.basicConfig(level=logging.INFO)

app = FastAPI()
model = YOLO('yolov8n.pt')  # YOLO 모델 로드

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 출처 허용
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 루트 경로 처리
@app.get("/", response_class=HTMLResponse)
async def read_root():
    return "<h1>Welcome to the YOLO API</h1><p>Use /predict/, /upload/, or /camera-stream/ to interact with the YOLO model.</p>"

# 파비콘 요청 처리
@app.get("/favicon.ico")
async def favicon():
    return {"message": "Favicon not available"}

class ImageData(BaseModel):
    image: str

# 1. Base64로 인코딩된 이미지를 업로드하여 분류하는 엔드포인트
@app.post("/predict/")
async def predict_image(data: ImageData):
    try:
        # Base64 디코딩 및 이미지 로드
        image_data = base64.b64decode(data.image)
        img = Image.open(io.BytesIO(image_data)).convert("RGB")
        img = np.array(img)[:, :, ::-1]  # PIL 이미지를 OpenCV 형식으로 변환 (RGB -> BGR)
        
        logging.info(f"Received image of shape: {img.shape}")

        results = model(img)

        detections = [
            {"class": box.cls.item(), "confidence": box.conf.item()}
            for box in results[0].boxes
        ]

        return {"detections": detections}
    except Exception as e:
        logging.error(f"Error during prediction: {str(e)}")
        return {"error": str(e)}

# 2. 로컬 이미지를 업로드하여 분류하는 엔드포인트
@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    try:
        # 이미지 로드
        img = Image.open(io.BytesIO(await file.read())).convert("RGB")
        img = np.array(img)[:, :, ::-1]  # PIL 이미지를 OpenCV 형식으로 변환 (RGB -> BGR)

        logging.info(f"Uploaded image of shape: {img.shape}")

        results = model(img)

        detections = [
            {"class": box.cls.item(), "confidence": box.conf.item()}
            for box in results[0].boxes
        ]

        return {"detections": detections}
    except Exception as e:
        logging.error(f"Error during image upload prediction: {str(e)}")
        return {"error": str(e)}

# 3. 노트북 전면 카메라를 통해 실시간으로 분류하는 엔드포인트
@app.get("/camera-stream/")
async def camera_stream():
    try:
        logging.info("Attempting to open camera...")
        cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)

        if not cap.isOpened():
            logging.error("Camera not accessible")
            return {"error": "Camera not accessible"}

        logging.info("Camera opened successfully. Attempting to capture frame...")

        # 카메라에서 프레임 읽기
        for _ in range(10):  # 최대 10번 시도
            ret, frame = cap.read()
            if ret:
                logging.info(f"Captured frame of shape: {frame.shape}")
                break
        else:
            cap.release()
            logging.error("Failed to capture frame after multiple attempts")
            return {"error": "Failed to capture frame"}

        # YOLO 모델로 프레임 처리
        logging.info("Sending frame to YOLO model for detection...")
        results = model(frame)

        detections = [
            {"class": box.cls.item(), "confidence": box.conf.item()}
            for box in results[0].boxes
        ]

        cap.release()
        return {"detections": detections}
    except Exception as e:
        logging.error(f"Error during camera stream prediction: {str(e)}")
        return {"error": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
