#include "DHT.h"

#define DHTPIN 2     // DHT11'in bağlı olduğu dijital pin
#define DHTTYPE DHT11   // DHT sensör tipi

DHT dht(DHTPIN, DHTTYPE);

const int nemSensorPin = A0;    // Toprak nem sensörünün bağlı olduğu analog pin
const int motorPin = 9;       // Su motorunun bağlı olduğu dijital pin (transistörün beyzi)

const int kuruHavaDegeri = 650; // Sensörün kuru havada okuduğu yaklaşık değer (DENEYSEL OLARAK BULUNMALI)
const int sudaDegeri = 250;   // Sensörün suya batırıldığında okuduğu yaklaşık değer (DENEYSEL OLARAK BULUNMALI)

const int sulamaEsigi = 40;    // Toprak nem yüzdesi olarak sulama eşiği

void setup() {
  Serial.begin(9600);
  Serial.println("DHT11 ve Toprak Nem Sensoru Uygulamasi");
  dht.begin();
  pinMode(motorPin, OUTPUT);
  digitalWrite(motorPin, LOW); // Başlangıçta motor kapalı
}

void loop() {
  delay(2000); // DHT11 için en az 2 saniye gecikme önerilir

  float nem = dht.readHumidity();
  float sicaklik = dht.readTemperature();

  if (isnan(nem) || isnan(sicaklik)) {
    Serial.println("DHT11 okuma hatasi!");
    return;
  }

  int hamNemDegeri = analogRead(nemSensorPin);
  // Ham değeri yüzdeye çevirme (map fonksiyonu daha hassas olabilir)
  int nemYuzdesi = map(hamNemDegeri, kuruHavaDegeri, sudaDegeri, 0, 100);

  // Değerleri 0-100 aralığına sınırla
  nemYuzdesi = constrain(nemYuzdesi, 0, 100);

  Serial.print("Sicaklik: ");
  Serial.print(sicaklik);
  Serial.print(" *C, Nem: ");
  Serial.print(nem);
  Serial.print(" %, Toprak Nemi: ");
  Serial.print(nemYuzdesi);
  Serial.println(" %");

  // Sulama kontrolü
  if (nemYuzdesi < sulamaEsigi) {
    Serial.println("Toprak kuru, sulama baslatiliyor...");
    digitalWrite(motorPin, HIGH); // Motoru aç
    delay(5000); // Belirli bir süre sula (ayarlanabilir)
    digitalWrite(motorPin, LOW);  // Motoru kapat
    Serial.println("Sulama tamamlandi.");
  } else {
    Serial.println("Toprak yeterince nemli.");
  }
}