import tensorflow as tf

# .h5 모델 로드
model = tf.keras.models.load_model('./efficientnetb0_model.h5')

# TFLite Converter 설정
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# 양자화 설정 (예: Dynamic Range Quantization)
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# TFLite 모델 저장
tflite_model = converter.convert()

with open('model.tflite', 'wb') as f:
    f.write(tflite_model)
