/**
 * =========================================================================
 * PRJ301 - ESP32 FIRMWARE CHO HE THONG MAY BAN HANG TU DONG (TOPIC 01)
 * TICH HOP: DRIVER L298N (2 DONG CO) + CAM BIEN CAN HX711 + DONG BO SERVER
 * =========================================================================
 * - Phien ban dong bo hoan toan voi mach thuc te:
 *   + HX711: DOUT = 19, SCK = 18 (Calibration factor = 1097.325928)
 *   + L298N: IN1 = 25, IN2 = 26, IN3 = 27, IN4 = 14
 * - Ho tro 2 che do hoat dong song song:
 *   1. Chế độ Test qua Serial Monitor (nhập '1', '2', '0', 't', 'w')
 *   2. Chế độ Bán hàng tự động qua WiFi (Poll lệnh từ Server & gửi Ingest)
 * =========================================================================
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "HX711.h"
#include "esp_wifi.h"

// ======================== CAU HINH HE THONG ===============================
const char* WIFI_SSID       = "MinhPS";       // SSID WiFi (hoặc WiFi điện thoại/phòng lab)
const char* WIFI_PASSWORD   = "88888888";                  // Mật khẩu WiFi
const char* SERVER_BASE     = "http://172.18.9.4:9999/VendingMachineManagement"; // IP máy chủ Tomcat thực tế (Port 9999)
const char* API_KEY         = "demo-key-vend-0001"; // Khớp với api_key trong bảng Device (sql/02_sample_data_VN.sql)

// Chế độ mô phỏng (false = dùng cảm biến HX711 và motor thật; true = giả lập số liệu)
const bool  SIMULATION_MODE = false;

// ======================== HX711 (CAM BIEN CAN) ============================
#define HX711_DOUT 19
#define HX711_SCK  18

HX711 scale;

// Hệ số hiệu chuẩn thực nghiệm
const float CALIBRATION_FACTOR = 1125.290283f;

// ======================== L298N (DONG CO 2 RANH) ==========================
#define IN1 25
#define IN2 26
#define IN3 27
#define IN4 14

// Đèn LED báo trạng thái kết nối
#define LED_STATUS_PIN 2

// ======================== CAI DAT THOI GIAN ===============================
const unsigned long MOTOR_TIME       = 700; // Thời gian quay cho 1 vòng lò xo (ms)
const unsigned long WEIGHT_INTERVAL  = 500;  // Khoảng thời gian in cân nặng ra Serial Monitor (ms)
const unsigned long POLL_INTERVAL_MS = 1500; // Khoảng thời gian hỏi lệnh server (ms)

// ======================== BIEN TOAN CUC ===================================
bool motor1Running = false;
bool motor2Running = false;

unsigned long motor1Start = 0;
unsigned long motor2Start = 0;
unsigned long lastWeightTime = 0;
unsigned long lastPollTime = 0;
int currentDeviceSeq = 1000; // Khởi đầu từ 1000 để tránh trùng lặp với các phiên mẫu có sẵn

String command = "";

// ======================== KHAI BAO HAM ===================================
void connectWiFi();
void checkDispenseCommand();
void executeDispense(String orderId, String slotCode, int turns, int timeoutMs);
void sendIngestReport(String slotCode, int seqNum, int turns, int motorMs, int settleMs,
                      float wBefore, float wAfter, float wDelta, float peakDelta);
float readWeightGrams();
void printPeriodicWeight();
void readSerialCommand();
void updateMotors();
void runMotor1();
void runMotor2();
void stopMotor1();
void stopMotor2();
void stopAllMotors();

// ======================== SETUP ==========================================
void setup() {
  Serial.begin(115200);
  delay(500);

  // Cấu hình chân điều khiển L298N
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  pinMode(LED_STATUS_PIN, OUTPUT);

  stopAllMotors();
  digitalWrite(LED_STATUS_PIN, LOW);

  Serial.println();
  Serial.println("=======================================================");
  Serial.println(" ESP32 VENDING MACHINE + HX711 + L298N (PRJ301)");
  Serial.println("=======================================================");

  // Khởi tạo cân HX711
  scale.begin(HX711_DOUT, HX711_SCK);
  scale.set_scale(CALIBRATION_FACTOR);

  if (!scale.wait_ready_timeout(3000)) {
    Serial.println("[HX711] CAN CHUA SAN SANG (NOT READY)!");
  } else {
    Serial.println("[HX711] Vui long lay moi vat ra khoi khay de Tare...");
    delay(1500);
    scale.tare(20);
    Serial.println("[HX711] Can da san sang (Scale ready)!");
  }

  Serial.println("\n[HUONG DAN TEST QUA SERIAL MONITOR]:");
  Serial.println(" - Gui '1': Quay Motor 1 (Ranh SLOT-01)");
  Serial.println(" - Gui '2': Quay Motor 2 (Ranh SLOT-02)");
  Serial.println(" - Gui '0': Dung tat ca dong co");
  Serial.println(" - Gui 't': Tare (ve 0 can nang)");
  Serial.println(" - Gui 'w': Doc can nang hien tai ngay lap tuc\n");

  // Kết nối WiFi
  connectWiFi();
}

// ======================== MAIN LOOP ======================================
void loop() {
  // 1. Đọc và xử lý lệnh test trực tiếp từ Serial Monitor
  readSerialCommand();

  // 2. Cập nhật hẹn giờ dừng động cơ khi test lệnh Serial
  updateMotors();

  // 3. In khối lượng định kỳ ra Serial
  printPeriodicWeight();

  // 4. Kiểm tra WiFi và Poll lệnh từ Server
  if (WiFi.status() == WL_CONNECTED) {
    if (millis() - lastPollTime >= POLL_INTERVAL_MS) {
      lastPollTime = millis();
      checkDispenseCommand();
    }
  } else {
    // Thử kết nối lại WiFi nếu mất mạng (mỗi 10s kiểm tra 1 lần)
    static unsigned long lastWifiRetry = 0;
    if (millis() - lastWifiRetry >= 10000) {
      lastWifiRetry = millis();
      connectWiFi();
    }
  }
}

// ======================== MOTOR CONTROLS =================================
void stopMotor1() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  motor1Running = false;
  Serial.println("[MOTOR] Motor 1 (SLOT-01) STOP");
}

void stopMotor2() {
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  motor2Running = false;
  Serial.println("[MOTOR] Motor 2 (SLOT-02) STOP");
}

void stopAllMotors() {
  stopMotor1();
  stopMotor2();
}

void runMotor1() {
  if (motor1Running || motor2Running) {
    Serial.println("[MOTOR] Motor busy. Command ignored.");
    return;
  }

  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);

  motor1Running = true;
  motor1Start = millis();

  Serial.printf("[MOTOR] Motor 1 (SLOT-01) START - %lu ms\n", MOTOR_TIME);
}

void runMotor2() {
  if (motor1Running || motor2Running) {
    Serial.println("[MOTOR] Motor busy. Command ignored.");
    return;
  }

  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);

  motor2Running = true;
  motor2Start = millis();

  Serial.printf("[MOTOR] Motor 2 (SLOT-02) START - %lu ms\n", MOTOR_TIME);
}

void updateMotors() {
  unsigned long now = millis();

  if (motor1Running && now - motor1Start >= MOTOR_TIME) {
    stopMotor1();
  }

  if (motor2Running && now - motor2Start >= MOTOR_TIME) {
    stopMotor2();
  }
}

// ======================== SERIAL COMMAND =================================
void readSerialCommand() {
  while (Serial.available() > 0) {
    char c = Serial.read();

    if (c == '\n' || c == '\r') {
      command.trim();

      if (command == "1") {
        runMotor1();
      } 
      else if (command == "2") {
        runMotor2();
      } 
      else if (command == "0") {
        stopAllMotors();
      } 
      else if (command.equalsIgnoreCase("t") || command.equalsIgnoreCase("tare")) {
        Serial.println("[HX711] Dang Tare...");
        scale.tare(20);
        Serial.println("[HX711] Da Tare ve 0g!");
      }
      else if (command.equalsIgnoreCase("w")) {
        float w = readWeightGrams();
        Serial.printf("[HX711] Can nang hien tai: %.2f g\n", w);
      }
      else if (command.length() > 0) {
        Serial.println("[SERIAL] Lenh khong hop le. Hay dung: 1, 2, 0, t, w");
      }

      command = "";
    } 
    else {
      command += c;
    }
  }
}

// ======================== DOC CAN NANG ===================================
float readWeightGrams() {
  if (SIMULATION_MODE) {
    return 120.0f + (random(0, 50) / 10.0f);
  }

  if (scale.is_ready()) {
    float weight = scale.get_units(5);
    if (weight < 0 && weight > -2.0f) {
      weight = 0.0f;
    }
    return weight;
  }

  if (scale.wait_ready_timeout(500)) {
    float weight = scale.get_units(5);
    if (weight < 0 && weight > -2.0f) {
      weight = 0.0f;
    }
    return weight;
  }

  return 0.0f;
}

void printPeriodicWeight() {
  unsigned long now = millis();

  // Chỉ in định kỳ khi động cơ không chạy để Serial sạch sẽ
  if (!motor1Running && !motor2Running && (now - lastWeightTime >= WEIGHT_INTERVAL)) {
    lastWeightTime = now;

    if (scale.is_ready()) {
      float weight = scale.get_units(3);
      if (weight < 0 && weight > -2.0f) {
        weight = 0.0f;
      }
      Serial.print("Weight: ");
      Serial.print(weight, 2);
      Serial.println(" g");
    }
  }
}

// ======================== KET NOI WIFI ===================================
void connectWiFi() {
  Serial.printf("\n[WIFI] Dang ket noi toi SSID: %s ...\n", WIFI_SSID);

  // 1. Reset sạch cấu hình WiFi cũ trong Flash/NVS
  WiFi.disconnect(true, true);
  delay(200);

  WiFi.mode(WIFI_STA);

  // 2. Mở full dải kênh 1 - 14 chuẩn VN (giúp ESP32 bắt được Hotspot ở kênh 12, 13)
  wifi_country_t country = {
    .cc = "VN",
    .schan = 1,
    .nchan = 14,
    .policy = WIFI_COUNTRY_POLICY_MANUAL
  };
  esp_wifi_set_country(&country);

  WiFi.setAutoReconnect(true);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  // 3. Cho phép chờ kết nối tối đa 40 lần (20 giây)
  int tries = 0;
  while (WiFi.status() != WL_CONNECTED && tries < 40) {
    delay(500);
    Serial.print(".");
    digitalWrite(LED_STATUS_PIN, !digitalRead(LED_STATUS_PIN));
    tries++;
  }

  // 3. Kiểm tra kết quả và in mã lỗi chi tiết
  if (WiFi.status() == WL_CONNECTED) {
    digitalWrite(LED_STATUS_PIN, HIGH);
    Serial.println("\n[WIFI] Ket noi thanh cong!");
    Serial.print("[WIFI] Dia chi IP ESP32: ");
    Serial.println(WiFi.localIP());
  } else {
    digitalWrite(LED_STATUS_PIN, LOW);
    Serial.println("\n[WIFI] That bai! Ma trang thai: " + String(WiFi.status()));
    
    // Gợi ý theo mã trạng thái:
    switch (WiFi.status()) {
      case WL_NO_SSID_AVAIL:
        Serial.println("[WIFI LỖI] Khong tim thay SSID! (Kiem tra dung ten chua hoac wifi co phai 2.4GHz khong)");
        break;
      case WL_CONNECT_FAILED:
        Serial.println("[WIFI LỖI] Sai mat khau hoac bi Router tu choi!");
        break;
      case WL_DISCONNECTED:
        Serial.println("[WIFI LỖI] ESP32 bi mat ket noi / khong xin duoc IP DHCP.");
        break;
      default:
        Serial.println("[WIFI LỖI] Loi khong xac dinh.");
        break;
    }
  }
}


// ======================== POLLING LENH TU SERVER =========================
void checkDispenseCommand() {
  HTTPClient http;
  String url = String(SERVER_BASE) + "/api/device/poll";

  http.begin(url);
  http.addHeader("X-API-Key", API_KEY);
  http.setTimeout(3000);

  int httpCode = http.GET();

  if (httpCode == HTTP_CODE_OK) {
    String responseJson = http.getString();
    
    // Tương thích cả ArduinoJson v6 và v7
    #if ARDUINOJSON_VERSION_MAJOR >= 7
      JsonDocument doc;
    #else
      DynamicJsonDocument doc(512);
    #endif

    DeserializationError err = deserializeJson(doc, responseJson);

    if (!err) {
      String status = doc["status"].as<String>();

      if (status == "DISPENSE") {
        String orderId = doc["order_id"].as<String>();
        String slotCode = doc["slot_code"].as<String>();
        int turns = doc["turns"].as<int>();
        int timeoutMs = doc["timeout_ms"].as<int>();

        Serial.printf("\n[POLL] Nhan lenh TRA HANG tu Server! Order: %s | Slot: %s | So luong: %d\n",
                      orderId.c_str(), slotCode.c_str(), turns);

        // Thực hiện chu trình nhả hàng vật lý
        executeDispense(orderId, slotCode, turns > 0 ? turns : 1, timeoutMs > 0 ? timeoutMs : (turns * 4000));
      }
    }
  } else if (httpCode == HTTP_CODE_UNAUTHORIZED) {
    Serial.println("[POLL] Loi 401: Sai X-API-Key voi thiet bi!");
  }

  http.end();
}

// ======================== THUC THI TRA HANG ==============================
void executeDispense(String orderId, String slotCode, int turns, int timeoutMs) {
  Serial.println("[DISPENSE] === BAT DAU CHU TRINH NHA HANG ===");

  // 1. Đọc khối lượng khay trước khi nhả
  float weightBefore = readWeightGrams();
  Serial.printf("[SENSOR] Khoi luong ban dau (Weight Before): %.2f g\n", weightBefore);

  // 2. Kích hoạt động cơ rãnh tương ứng (SLOT-01 hoặc SLOT-02)
  unsigned long duration = (unsigned long)turns * MOTOR_TIME;
  Serial.printf("[MOTOR] Bat dong co %s | Quay %d vong (Tong thoi gian: %lu ms)...\n",
                slotCode.c_str(), turns, duration);

  unsigned long startMotorMs = millis();
  if (slotCode == "SLOT-02" || slotCode == "2") {
    digitalWrite(IN3, HIGH);
    digitalWrite(IN4, LOW);
  } else {
    // Mặc định SLOT-01
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
  }

  // Chờ động cơ quay đủ thời gian
  delay(duration);

  // Dừng động cơ
  stopAllMotors();
  unsigned long motorElapsed = millis() - startMotorMs;
  Serial.printf("[MOTOR] Dong co da dung sau: %lu ms\n", motorElapsed);

  // 3. Thời gian ổn định khay sau khi rơi (Settle time)
  int settleDelay = 700;
  delay(settleDelay);

  // Đọc khối lượng sau khi sản phẩm rơi
  float weightAfter = readWeightGrams();
  float weightDelta = weightAfter - weightBefore;

  // Nếu ở chế độ mô phỏng hoặc kiểm thử không cảm biến
  if (SIMULATION_MODE) {
    float unitWeight = (slotCode == "SLOT-02" || slotCode == "2") ? 33.0f : 25.0f;
    weightDelta = unitWeight * turns;
    weightAfter = weightBefore + weightDelta;
  } else {
    // Lọc nhiễu âm nhẹ
    if (weightDelta < 0 && weightDelta > -2.0f) {
      weightDelta = 0.0f;
    }
  }

  float peakDelta = (weightDelta > 0) ? (weightDelta + 12.0f) : 0.0f;

  Serial.printf("[SENSOR] Khoi luong sau nha (Weight After): %.2f g | Delta: %.2f g\n", weightAfter, weightDelta);

  // 4. Gửi báo cáo Ingest về máy chủ
  sendIngestReport(slotCode, currentDeviceSeq++, turns, (int)motorElapsed, settleDelay,
                   weightBefore, weightAfter, weightDelta, peakDelta);

  Serial.println("[DISPENSE] === HOAN TAT CHU TRINH NHA HANG ===\n");
}

// ======================== GUI BAO CAO VE SERVER ==========================
void sendIngestReport(String slotCode, int seqNum, int turns, int motorMs, int settleMs,
                      float wBefore, float wAfter, float wDelta, float peakDelta) {
  HTTPClient http;
  String url = String(SERVER_BASE) + "/api/ingest";

  http.begin(url);
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  http.addHeader("X-API-Key", API_KEY);
  http.setTimeout(5000);

  // Xây dựng form body theo đúng format mà IngestServlet mong đợi
  String body = "slot_code=" + slotCode +
                "&seq_num=" + String(seqNum) +
                "&coil_turns=" + String(turns) +
                "&motor_ms=" + String(motorMs) +
                "&settle_ms=" + String(settleMs) +
                "&weight_before=" + String(wBefore, 2) +
                "&weight_after=" + String(wAfter, 2) +
                "&weight_delta=" + String(wDelta, 2) +
                "&peak_delta=" + String(peakDelta, 2);

  Serial.println("[INGEST] Dang gui bao cao ket qua ve Server...");
  int httpCode = http.POST(body);

  if (httpCode == HTTP_CODE_OK) {
    String resp = http.getString();
    Serial.printf("[INGEST] Server phan hoi thanh cong (200 OK): %s\n", resp.c_str());
  } else {
    Serial.printf("[INGEST] Gui du lieu that bai (HTTP Code: %d)\n", httpCode);
  }

  http.end();
}