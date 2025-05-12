from ultralytics import YOLO
import cv2
import numpy as np
import time
import torch

def run_detection(http_url, model_path):
    try:
        if not torch.cuda.is_available():
            raise RuntimeError("CUDA kullanılamıyor! GPU'nuzun ve CUDA'nın doğru kurulu olduğundan emin olun.")

        device = 'cuda'
        print(f"Kullanılan cihaz: {device}")
        print(f"GPU Modeli: {torch.cuda.get_device_name(0)}")
        print(f"CUDA Versiyonu: {torch.version.cuda}")

        model = YOLO(model_path)
        model.to(device)

        model.conf = 0.25
        model.iou = 0.45

        cap = cv2.VideoCapture(http_url)
        cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

        if not cap.isOpened():
            raise RuntimeError("HTTP stream'ine bağlanılamadı!")

        print("Stream başlatıldı. Çıkmak için 'q' tuşuna basın.")

        fps_start_time = time.time()
        fps_frame_count = 0
        fps = 0
        frame_count = 0
        skip_frames = 2

        current_detections = {}

        while True:
            ret, frame = cap.read()
            frame_count += 1

            if not ret:
                print("Frame okunamadı!")
                break

            frame = cv2.resize(frame, (640, 480))

            if frame_count % skip_frames == 0:
                try:
                    current_detections.clear()

                    with torch.amp.autocast('cuda'):
                        results = model.predict(
                            source=frame,
                            conf=0.25,
                            iou=0.45,
                            device=device,
                            verbose=False
                        )
                        result = results[0]

                    for box in result.boxes:
                        x1, y1, x2, y2 = box.xyxy[0]
                        x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
                        conf = float(box.conf[0])
                        cls = int(box.cls[0])
                        class_name = result.names[cls]

                        if conf > 0.6:
                            if class_name in current_detections:
                                current_detections[class_name] += 1
                            else:
                                current_detections[class_name] = 1

                            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                            label = f'{class_name} {conf:.2f}'
                            (label_width, label_height), _ = cv2.getTextSize(
                                label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2
                            )
                            cv2.rectangle(
                                frame,
                                (x1, y1-label_height-10),
                                (x1+label_width, y1),
                                (0, 255, 0),
                                -1
                            )
                            cv2.putText(
                                frame,
                                label,
                                (x1, y1-5),
                                cv2.FONT_HERSHEY_SIMPLEX,
                                0.5,
                                (0, 0, 0),
                                2
                            )

                    if current_detections:
                        print("\n--- Anlık Tespitler ---")
                        for obj, count in current_detections.items():
                            print(f"{obj}: {count} adet")
                        print("-----------------------")

                except Exception as e:
                    print(f"Tespit sırasında hata: {e}")
                    torch.cuda.empty_cache()
                    continue

            fps_frame_count += 1
            if fps_frame_count >= 30:
                fps = fps_frame_count / (time.time() - fps_start_time)
                fps_frame_count = 0
                fps_start_time = time.time()

            gpu_usage = torch.cuda.memory_allocated(0) / 1024**2
            gpu_info = f"GPU Bellek: {gpu_usage:.1f}MB"

            cv2.putText(
                frame,
                f'FPS: {fps:.1f} | {gpu_info}',
                (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.7,
                (0, 255, 0),
                2
            )

            cv2.imshow('YOLO Detection (CUDA)', frame)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

    except Exception as e:
        print(f"Genel hata: {e}")

    finally:
        if 'cap' in locals():
            cap.release()
        cv2.destroyAllWindows()
        torch.cuda.empty_cache()

if __name__ == "__main__":
    http_url = "http://192.168.7.252:8000/video_feed"  # HTTP video kaynağı
    model_path = "yolov8n.pt"
    run_detection(http_url, model_path)