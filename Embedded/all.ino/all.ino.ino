#include "DHT.h"

#define DHTPIN 2     // DHT11'in bağlı olduğu dijital pin (D2)
#define DHTTYPE DHT11   // DHT 11

const int motorPin = 9;        // Su motorunun bağlı olduğu dijital pin (transistörün beyzi)
const int sensorPin = A0;      // Analog sensör pini
String gelenVeri = "";         // Seri porttan gelen veriyi saklamak için bir String değişkeni
bool motorDurumu = false;      // Motorun mevcut durumunu takip eden değişken (başlangıçta kapalı)
unsigned long sonOkumaZamani = 0;  // Son sensör okuma zamanı
const long okumaAraligi = 1000;    // Sensör okuma aralığı (1 saniye)
unsigned long sonDHTOkumaZamani = 0; // Son DHT okuma zamanı
const long dhtOkumaAraligi = 2000;  // DHT okuma aralığı (2 saniye)

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(9600);
  Serial.println("Seri Port Kontrollu Motor ve Sensor Uygulamasi");
  Serial.println("Motoru calistirmak icin '1' yazin ve Enter'a basin.");
  Serial.println("Motoru durdurmak icin '0' yazin ve Enter'a basin.");
  pinMode(motorPin, OUTPUT);
  pinMode(sensorPin, INPUT);    // A0 pinini giriş olarak ayarla
  digitalWrite(motorPin, LOW);  // Başlangıçta motor kapalı
  dht.begin();
}

void loop() {
  // 1. DHT11 sensöründen veri oku ve yazdır
  unsigned long simdikiZaman = millis();
  if (simdikiZaman - sonDHTOkumaZamani >= dhtOkumaAraligi) {
    float nem = dht.readHumidity();
    float sicaklik = dht.readTemperature();

    if (isnan(nem) || isnan(sicaklik)) {
      Serial.println("DHT11 okuma hatasi!");
    } else {
      Serial.print("Hava Nemi,");
      Serial.print(nem);
      Serial.println(" %\t");
      Serial.print("Sicaklik,");
      Serial.print(sicaklik);
      Serial.println(" *C");
    }
    sonDHTOkumaZamani = simdikiZaman;
  }

  // 2. Analog sensörden veri oku ve yazdır
  if (simdikiZaman - sonOkumaZamani >= okumaAraligi) {
    int sensorDegeri = analogRead(sensorPin);
    Serial.print("Toprak Nem,");
    Serial.println(sensorDegeri);
    sonOkumaZamani = simdikiZaman;
  }

  // 3. Seri porttan gelen komutları işle
  if (Serial.available() > 0) {
    char karakter = Serial.read();
    if (karakter == '\n') { // Enter tuşuna basıldığında
      gelenVeri.trim();     // Baştaki ve sondaki boşlukları temizle
      if (gelenVeri == "0") {
        if (!motorDurumu) { // Eğer motor zaten çalışmıyorsa
          Serial.println("Motor durduruluyor.");
          digitalWrite(motorPin, HIGH); // Motoru aç
          motorDurumu = true;
        } else {
          Serial.println("Motor zaten durdu.");
        }
      } else if (gelenVeri == "1") {
        if (motorDurumu) { // Eğer motor zaten çalışıyorsa
          Serial.println("Motor calistiriliyor.");
          digitalWrite(motorPin, LOW);  // Motoru kapat
          motorDurumu = false;
        } else {
          Serial.println("Motor zaten calisiyor.");
        }
      } else {
        Serial.print("Gecersiz komut: ");
        Serial.println(gelenVeri);
        Serial.println("Lutfen '1' veya '0' girin.");
      }
      gelenVeri = ""; // Gelen veriyi temizle
    } else if (karakter != '\r') { // Satır başı karakterini yoksay
      gelenVeri += karakter; // Gelen karakteri String'e ekle
    }
  }
}
