# Gerekli kütüphaneleri içe aktar
from flask import Flask, Response, render_template_string, url_for
from flask_cors import CORS
from picamera2 import Picamera2
from libcamera import controls  # Kare hızı gibi kontroller için
from PIL import Image
import io
import time

# --- Optimizasyon Ayarları (Bu değerleri deneyerek ayarlayın) ---

STREAM_WIDTH = 640
STREAM_HEIGHT = 480
JPEG_QUALITY = 75
FRAME_RATE = 25.0

# --- Flask ve Kamera Kurulumu ---
app = Flask(__name__)
CORS(app)
camera = Picamera2()

# --- Kamerayı Optimizasyon Ayarlarıyla Yapılandır ---
print("Kamera yapılandırılıyor...")
try:
    preview_config = camera.create_preview_configuration(
        main={"size": (STREAM_WIDTH, STREAM_HEIGHT)},
        controls={
            "FrameRate": FRAME_RATE,
        },
    )
    camera.configure(preview_config)
    print(f"Kamera yapılandırıldı: {STREAM_WIDTH}x{STREAM_HEIGHT} @ ~{FRAME_RATE}fps, JPEG Kalitesi: {JPEG_QUALITY}")
except Exception as e:
    print(f"Kamera yapılandırması başarısız: {e}")
    exit()

# --- Kamerayı Başlat ---
camera.start()
print("Kamera başlatıldı. Başlangıç için bekleniyor...")
time.sleep(2.0)
print("Kamera hazır.")

# --- Kareler için Bellek İçi Tampon ---
output = io.BytesIO()

# --- Video Akışı Üreteci Fonksiyonu ---
def gen():
    print("Kare üretme döngüsü başlatılıyor...")
    frame_count = 0
    start_time = time.time()
    while True:
        try:
            frame_array = camera.capture_array()
            image = Image.fromarray(frame_array).convert('RGB')  # RGBA'yı RGB'ye çevir
            output.seek(0)
            output.truncate()
            image.save(output, format='JPEG', quality=JPEG_QUALITY)
            frame = output.getvalue()

            if not frame:
                print("Uyarı: Boş kare yakalandı, atlanıyor.")
                time.sleep(0.05)
                continue

            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

            frame_count += 1
            if frame_count % 50 == 0:
                now = time.time()
                elapsed = now - start_time
                fps = frame_count / elapsed
                print(f"Akış FPS: {fps:.2f} ({frame_count} kare / {elapsed:.2f} saniye)")

        except Exception as e:
            print(f"Kare üretme hatası: {e}")
            time.sleep(0.5)

# --- Flask Rotaları ---
@app.route('/video_feed')
def video_feed():
    print("İstemci /video_feed adresine bağlandı.")
    return Response(gen(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/')
def index():
    print("İstemci / adresine bağlandı.")
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Optimize Edilmiş Kamera Akışı</title>
        <style>
            body {{ font-family: sans-serif; text-align: center; padding-top: 20px; background-color: #f0f0f0; }}
            img {{ display: block; margin: 10px auto; border: 2px solid #555; background-color: #fff; }}
            p {{ color: #333; }}
            a {{ color: #007bff; text-decoration: none; }}
            a:hover {{ text-decoration: underline; }}
        </style>
    </head>
    <body>
        <h1>Optimize Edilmiş Raspberry Pi Kamera Akışı</h1>
        <p>Çözünürlük: {width}x{height} | Kalite: {quality} | Hedef FPS: {fps}</p>
        <img src="{video_url}" width="{width}" height="{height}" alt="Kamera Akışı Yükleniyor..." >
        <p><a href="{video_url}">Sadece Ham Video Akışı</a></p>
        <p>Eğer akış durursa, sayfayı yenilemeyi deneyin.</p>
        <p><small>Sunucu {current_time} itibarıyla çalışıyor.</small></p>
    </body>
    </html>
    """.format(
        width=STREAM_WIDTH,
        height=STREAM_HEIGHT,
        quality=JPEG_QUALITY,
        fps=FRAME_RATE,
        video_url=url_for('video_feed'),
        current_time=time.strftime("%Y-%m-%d %H:%M:%S")
    )
    return render_template_string(html_content)

# --- Ana Çalıştırma Bloğu ---
if __name__ == '__main__':
    print("Flask sunucusu başlatılıyor...")
    try:
        app.run(host='0.0.0.0', port=8000, debug=False, threaded=True)
    except KeyboardInterrupt:
        print("\nSunucu durduruluyor (Ctrl+C)...")
    finally:
        print("Kamera durduruluyor...")
        camera.stop()
        print("Kamera durduruldu.")
