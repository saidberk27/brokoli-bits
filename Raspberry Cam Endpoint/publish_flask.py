# Gerekli kütüphaneleri içe aktar
from flask import Flask, Response, render_template_string, url_for
from picamera2 import Picamera2
from libcamera import controls  # Kare hızı gibi kontroller için
import io
import time

# --- Optimizasyon Ayarları (Bu değerleri deneyerek ayarlayın) ---

# Daha düşük çözünürlük = daha az veri = daha hızlı işleme ve gönderme
STREAM_WIDTH = 640  # Örnek: 640 veya 480 veya 320 gibi deneyin
STREAM_HEIGHT = 480 # Örnek: 480 veya 360 veya 240 gibi deneyin

# Daha düşük kalite = daha küçük JPEG dosyaları = daha hızlı kodlama ve daha az bant genişliği
JPEG_QUALITY = 75   # Örnek: 50 ile 90 arası bir değer deneyin (varsayılan ~85-90)

# Hedef kare hızı (Kamera ve Pi modeli desteklediği sürece bu hıza ulaşmaya çalışır)
FRAME_RATE = 25.0   # Örnek: 15, 20, 25, 30 gibi değerler deneyin

# --- Flask ve Kamera Kurulumu ---
app = Flask(__name__)
camera = Picamera2()

# --- Kamerayı Optimizasyon Ayarlarıyla Yapılandır ---
print("Kamera yapılandırılıyor...")
try:
    preview_config = camera.create_preview_configuration(
        # Çözünürlük ayarını uygula
        main={"size": (STREAM_WIDTH, STREAM_HEIGHT)},
        # Kontrolleri ayarla (örn: FrameRate)
        controls={
            "FrameRate": FRAME_RATE,
            # Not: Çok düşük ışıkta kare hızını korumak için otomatik pozlama (AE)
            # ayarlarıyla oynamak gerekebilir, ancak başlangıç için sadece FrameRate yeterli.
            # "AeEnable": True, # Varsayılan olarak genellikle açık
            # "NoiseReductionMode": controls.draft.NoiseReductionModeEnum.Fast # Gürültü azaltmayı hızlandırabilir
        },
        # MJPEG için uygun bir format kullanıldığından emin ol (genellikle otomatik)
        # queue=False # Kuyruğu kapatmak gecikmeyi biraz azaltabilir ama kare atlamasına neden olabilir
    )
    camera.configure(preview_config)
    print(f"Kamera yapılandırıldı: {STREAM_WIDTH}x{STREAM_HEIGHT} @ ~{FRAME_RATE}fps, JPEG Kalitesi: {JPEG_QUALITY}")
except Exception as e:
    print(f"Kamera yapılandırması başarısız: {e}")
    # Hata durumunda programdan çıkmak mantıklı olabilir
    exit()

# --- Kamerayı Başlat ---
camera.start()
print("Kamera başlatıldı. Başlangıç için bekleniyor...")
# Kameranın sensör ayarlarının oturması için kısa bir bekleme
time.sleep(2.0)
print("Kamera hazır.")

# --- Kareler için Bellek İçi Tampon ---
output = io.BytesIO()

# --- Video Akışı Üreteci Fonksiyonu ---
def gen():
    """Akış için JPEG karelerini üreten fonksiyon."""
    print("Kare üretme döngüsü başlatılıyor...")
    frame_count = 0
    start_time = time.time()
    while True:
        try:
            # Bir sonraki kare için tamponu sıfırla
            output.seek(0)
            output.truncate()

            # Belirtilen JPEG kalitesiyle kareyi yakala
            # capture_file metodu dahili olarak JPEG kodlaması yapar
            camera.capture_file(output, format='jpeg', quality=JPEG_QUALITY)
            frame = output.getvalue()

            # Kare yakalamanın başarılı olup olmadığını basitçe kontrol et
            if not frame:
                print("Uyarı: Boş kare yakalandı, atlanıyor.")
                time.sleep(0.05) # Hata durumunda CPU'yu yormamak için kısa bekleme
                continue

            # Kareyi multipart formatında gönder (yield)
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

            frame_count += 1
            # İsteğe bağlı: Periyodik olarak FPS yazdırma (performans takibi için)
            if frame_count % 50 == 0: # Her 50 karede bir
                 now = time.time()
                 elapsed = now - start_time
                 fps = frame_count / elapsed
                 print(f"Akış FPS: {fps:.2f} ({frame_count} kare / {elapsed:.2f} saniye)")
                 # Uzun süre çalışırsa sıfırlama yapılabilir
                 # frame_count = 0
                 # start_time = now


        except Exception as e:
            print(f"Kare üretme hatası: {e}")
            # Hatalar devam ederse döngüyü kırmak veya beklemek gerekebilir
            time.sleep(0.5)
            # break # Ciddi hatalarda döngüden çıkılabilir

# --- Flask Rotaları ---
@app.route('/video_feed')
def video_feed():
    """Video akış rotası."""
    print("İstemci /video_feed adresine bağlandı.")
    # Üreteç fonksiyonunu Response nesnesiyle kullan
    return Response(gen(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/')
def index():
    """Gömülü video akışını içeren ana sayfayı sunar."""
    print("İstemci / adresine bağlandı.")
    # Akışı göstermek için basit bir HTML sayfası
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
        video_url=url_for('video_feed'), # url_for kullanmak daha sağlamdır
        current_time=time.strftime("%Y-%m-%d %H:%M:%S")
    )
    # HTML içeriğini render et
    return render_template_string(html_content)

# --- Ana Çalıştırma Bloğu ---
if __name__ == '__main__':
    print("Flask sunucusu başlatılıyor...")
    try:
        # Flask sunucusunu çalıştır - threaded=True akış + diğer istekler için önemlidir
        # Daha iyi performans için 'gunicorn' gibi bir WSGI sunucusu düşünün:
        # Örnek: pip install gunicorn
        #        gunicorn -w 1 --threads 4 -b 0.0.0.0:8000 bu_dosyanin_adi:app
        app.run(host='0.0.0.0', port=8000, debug=False, threaded=True)
    except KeyboardInterrupt:
        print("\nSunucu durduruluyor (Ctrl+C)...")
    finally:
        # Uygulama bittiğinde kameranın düzgünce kapatıldığından emin ol
        print("Kamera durduruluyor...")
        camera.stop()
        print("Kamera durduruldu.")