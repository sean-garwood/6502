const unsigned char addr[] = {
    22, // A0
    24,
    26,
    28,
    30,
    32,
    34,
    36,
    38,
    40,
    42,
    44,
    46,
    48,
    50,
    52, // A15
};
const unsigned char data[] = {
    23, // D0
    25,
    27,
    29,
    31,
    33,
    35,
    37 // D7
};
#define CLOCK 2
#define RW 3
#define BAUDRATE 57600
#define ADDRSIZE 16U
#define DATASIZE 8U

void setup()
{
    for (unsigned i = ADDRSIZE; i-- > 0;)
        pinMode(addr[i], INPUT);
    for (unsigned i = DATASIZE; i-- > 0;)
        pinMode(data[i], INPUT);

    pinMode(CLOCK, INPUT);
    pinMode(RW, INPUT);
    attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING);
    Serial.begin(BAUDRATE);
}

void onClock()
{
    unsigned addrBits[ADDRSIZE];
    unsigned dataBits[DATASIZE];
    unsigned address = 0, val = 0, rw;

    for (unsigned i = ADDRSIZE; i-- > 0;)
        addrBits[i] = digitalRead(addr[i]) ? 1 : 0;
    for (unsigned i = DATASIZE; i-- > 0;)
        dataBits[i] = digitalRead(data[i]) ? 1 : 0;
    rw = digitalRead(RW);

    for (unsigned i = ADDRSIZE; i-- > 0;) {
        Serial.print(addrBits[i]);
        address = (address << 1) + addrBits[i];
    }
    Serial.print("\t");
    for (unsigned i = DATASIZE; i-- > 0;) {
        Serial.print(dataBits[i]);
        val = (val << 1) + dataBits[i];
    }

    char output[15];
    sprintf(output, "\t%04x\t%c\t%02x", address, rw ? 'r' : 'W', val);
    Serial.println(output);
}

void loop() {}
