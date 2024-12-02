from fastapi import FastAPI, File, UploadFile
import torch
from torchvision import transforms
from PIL import Image
import io
import base64
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# CycleGAN Generator 정의
class ResnetBlock(torch.nn.Module):
    def __init__(self, dim):
        super(ResnetBlock, self).__init__()
        self.conv_block = torch.nn.Sequential(
            torch.nn.ReflectionPad2d(1),
            torch.nn.Conv2d(dim, dim, kernel_size=3, stride=1, padding=0),
            torch.nn.InstanceNorm2d(dim),
            torch.nn.ReLU(inplace=True),
            torch.nn.ReflectionPad2d(1),
            torch.nn.Conv2d(dim, dim, kernel_size=3, stride=1, padding=0),
            torch.nn.InstanceNorm2d(dim),
        )

    def forward(self, x):
        return x + self.conv_block(x)

class CycleGANGenerator(torch.nn.Module):
    def __init__(self, input_nc=3, output_nc=3, ngf=64, n_blocks=9):
        super(CycleGANGenerator, self).__init__()
        model = [
            torch.nn.ReflectionPad2d(3),
            torch.nn.Conv2d(input_nc, ngf, kernel_size=7, stride=1, padding=0),
            torch.nn.InstanceNorm2d(ngf),
            torch.nn.ReLU(inplace=True),
        ]

        for _ in range(2):
            model += [
                torch.nn.Conv2d(ngf, ngf * 2, kernel_size=3, stride=2, padding=1),
                torch.nn.InstanceNorm2d(ngf * 2),
                torch.nn.ReLU(inplace=True),
            ]
            ngf *= 2

        for _ in range(n_blocks):
            model += [ResnetBlock(ngf)]

        for _ in range(2):
            model += [
                torch.nn.ConvTranspose2d(
                    ngf, ngf // 2, kernel_size=3, stride=2, padding=1, output_padding=1
                ),
                torch.nn.InstanceNorm2d(ngf // 2),
                torch.nn.ReLU(inplace=True),
            ]
            ngf //= 2

        model += [
            torch.nn.ReflectionPad2d(3),
            torch.nn.Conv2d(ngf, output_nc, kernel_size=7, stride=1, padding=0),
            torch.nn.Tanh(),
        ]

        self.model = torch.nn.Sequential(*model)

    def forward(self, x):
        return self.model(x)

# 모델 로드
model = CycleGANGenerator()
state_dict = torch.load("day2night.pth", map_location=torch.device("cpu"))
model.load_state_dict(state_dict, strict=False)
model.eval()

@app.post("/upload_image/")
async def upload_image(file: UploadFile = File(...)):
    contents = await file.read()
    input_image = Image.open(io.BytesIO(contents)).convert("RGB")

    # 이미지 전처리
    preprocess = transforms.Compose([
        transforms.Resize((256, 256)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.5, 0.5, 0.5], std=[0.5, 0.5, 0.5]),
    ])
    input_tensor = preprocess(input_image).unsqueeze(0)

    # 모델 추론
    with torch.no_grad():
        output_tensor = model(input_tensor)[0]
    output_image = transforms.ToPILImage()(output_tensor)

    # Base64로 변환
    buffer = io.BytesIO()
    output_image.save(buffer, format="PNG")
    base64_image = base64.b64encode(buffer.getvalue()).decode("utf-8")

    return JSONResponse(content={"image": base64_image})
