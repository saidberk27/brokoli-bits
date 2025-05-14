const int motorPin = 9;       // Su motorunun bağlı olduğu dijital pin (transistörün beyzi)
String gelenVeri = "";         // Seri porttan gelen veriyi saklamak için bir String değişkeni
bool motorDurumu = false;      // Motorun mevcut durumunu takip eden değişken (başlangıçta kapalı)

void setup() {
  Serial.begin(9600);
  Serial.println("Seri Port Kontrollu Motor Uygulamasi");
  Serial.println("Motoru calistirmak icin '1' yazin ve Enter'a basin.");
  Serial.println("Motoru durdurmak icin '0' yazin ve Enter'a basin.");
  pinMode(motorPin, OUTPUT);
  digitalWrite(motorPin, LOW); // Başlangıçta motor kapalı
}

void loop() {
  if (Serial.available() > 0) {
    char karakter = Serial.read();
    if (karakter == '\n') { // Enter tuşuna basıldığında
      gelenVeri.trim();     // Baştaki ve sondaki boşlukları temizle
      if (gelenVeri == "1") {
        if (!motorDurumu) { // Eğer motor zaten çalışmıyorsa
          Serial.println("Motor calistiriliyor.");
          digitalWrite(motorPin, HIGH); // Motoru aç
          motorDurumu = true;
        } else {
          Serial.println("Motor zaten calisiyor.");
        }
      } else if (gelenVeri == "0") {
        if (motorDurumu) { // Eğer motor zaten çalışıyorsa
          Serial.println("Motor durduruluyor.");
          digitalWrite(motorPin, LOW);  // Motoru kapat
          motorDurumu = false;
        } else {
          Serial.println("Motor zaten kapali.");
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