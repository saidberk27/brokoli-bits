import time
import subprocess
import signal
import sys
import io
from picamera2 import Picamera2
from picamera2.encoders import H264Encoder
from picamera2.outputs import FileOutput
from libcamera import controls

# --- Ayarlar ---
RTSP_URL = "rtsp://localhost:8554/cam"
STREAM_WIDTH = 1280
STREAM_HEIGHT = 720
FRAME_RATE = 25.0
# Bitrate'i düşürmeyi deneyin:
BITRATE = 4000000  # 4 Mbps (İlk deneme için iyi bir başlangıç)
# Veya belki:
# BITRATE = 5000000  # 5 Mbps

# Küresel ffmpeg süreci değişkeni
ffmpeg_process = None

def cleanup(signum, frame):
    """Ctrl+C veya sonlandırma sinyali geldiğinde temizlik yapar."""
    global ffmpeg_process
    print("\nSinyal alındı, temizleniyor...")
    if ffmpeg_process and ffmpeg_process.poll() is None:
        print("ffmpeg süreci sonlandırılıyor...")
        ffmpeg_process.stdin.close() # ffmpeg'in stdin'ini kapat
        ffmpeg_process.terminate()
        try:
            ffmpeg_process.wait(timeout=5) # 5 saniye bekle
        except subprocess.TimeoutExpired:
            print("ffmpeg zorla sonlandırılıyor (kill)...")
            ffmpeg_process.kill()
        print("ffmpeg süreci durduruldu.")

    if 'camera' in globals() and camera.started:
        print("Kamera durduruluyor...")
        try:
            camera.stop_encoder()
            camera.stop()
        except Exception as e:
            print(f"Kamera durdurulurken hata: {e}")
        print("Kamera durduruldu.")
    print("Çıkılıyor.")
    sys.exit(0)

# Sinyal işleyicilerini ayarla (Ctrl+C ve kill için)
signal.signal(signal.SIGINT, cleanup)
signal.signal(signal.SIGTERM, cleanup)

# Kamera kurulumu
print("Kamera başlatılıyor...")
camera = Picamera2()
video_config = camera.create_video_configuration(
    main={"size": (STREAM_WIDTH, STREAM_HEIGHT)},
    controls={
        "FrameRate": FRAME_RATE,
        # H.264 için kalite yerine bitrate daha önemlidir
        # "NoiseReductionMode": controls.draft.NoiseReductionModeEnum.HighQuality # Gürültü azaltma
    }
)
camera.configure(video_config)
print(f"Kamera yapılandırıldı: {STREAM_WIDTH}x{STREAM_HEIGHT} @ {FRAME_RATE}fps")

# H.264 Kodlayıcı
# quality parametresi H264Encoder için doğrudan bitrate'i etkileyebilir,
# ama bitrate'i ayrıca belirtmek daha nettir.
encoder = H264Encoder(bitrate=BITRATE)
print(f"H.264 Kodlayıcı ayarlandı: Bitrate={BITRATE}")

# ffmpeg komutunu hazırla
# -i - : Girişi standart girdiden (stdin) al
# -c:v copy : Video codec'ini kopyala (tekrar kodlama yapma, Picamera2 zaten H.264 yaptı)
# -f rtsp : Çıkış formatını RTSP olarak ayarla
# -rtsp_transport tcp : UDP yerine TCP kullan (genellikle daha güvenilir)
# RTSP_URL : mediamtx sunucusunun adresi
ffmpeg_command = [
    'ffmpeg',
    '-f', 'h264',      # Giriş formatını belirt (Picamera2'den H.264 geliyor)
    '-framerate', str(FRAME_RATE), # Giriş kare hızını belirtmek senkronizasyona yardımcı olabilir
    '-i', '-',          # Giriş stdin
    '-c:v', 'copy',     # Video codec'ini kopyala
    '-f', 'rtsp',       # Çıkış formatı RTSP
    '-rtsp_transport', 'tcp', # Taşıma protokolü TCP
    RTSP_URL            # Hedef RTSP sunucu adresi
]

print(f"ffmpeg komutu çalıştırılacak: {' '.join(ffmpeg_command)}")

try:
    # ffmpeg sürecini başlat, stdin'i PIPE yap ki Picamera2 oraya yazabilsin
    ffmpeg_process = subprocess.Popen(ffmpeg_command, stdin=subprocess.PIPE)
    print("ffmpeg süreci başlatıldı.")

    # Picamera2'nin kodlayıcısını başlat ve çıktıyı ffmpeg'in stdin'ine yönlendir
    # FileOutput kullanarak doğrudan ffmpeg'in stdin akışına yazıyoruz
    output = FileOutput(ffmpeg_process.stdin)
    camera.start_encoder(encoder, output=output)
    camera.start() # Kamera akışını başlat
    print("Kamera ve kodlayıcı başlatıldı, RTSP akışı yayınlanıyor...")
    print(f"Akışı izlemek için: rtsp://<RaspberryPi_IP>:{RTSP_URL.split(':')[-1]}") # Portu göster
    print("Durdurmak için Ctrl+C basın.")

    # Ana döngü - Betiğin çalışır durumda kalmasını sağlar
    # Sinyal işleyicisi (cleanup) Ctrl+C'yi yakalayacak
    while True:
        time.sleep(1)

except Exception as e:
    print(f"Ana try bloğunda hata oluştu: {e}")
    # Hata durumunda da temizlik yapmayı dene
    cleanup(None, None)