#define TRIG_PIN 5    // Change pin as needed
#define ECHO_PIN 18   // Change pin as needed

#define SOUND_SPEED 0.034  // cm/us
#define CM_TO_INCH 0.393701

long duration;
float distanceCm;
float distanceInch;

void setup() {
  Serial.begin(115200);         // Start serial communication
  pinMode(TRIG_PIN, OUTPUT);    // Set trig pin as output
  pinMode(ECHO_PIN, INPUT);     // Set echo pin as input
}

void loop() {
  // Clear the trigPin
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);

  // Set the trigPin HIGH for 10 microseconds
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Read echoPin duration
  duration = pulseIn(ECHO_PIN, HIGH);

  // Calculate distance
  distanceCm = duration * SOUND_SPEED / 2;
  distanceInch = distanceCm * CM_TO_INCH;

  // Print results to Serial Monitor
  // Serial.print("Distance (cm): ");
  // Serial.print(distanceCm);
  // Serial.print(" | Distance (inch): ");
  Serial.println(distanceInch);

  delay(1000);  // Wait for 1 second before next reading
}
