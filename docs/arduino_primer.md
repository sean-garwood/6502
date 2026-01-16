# Arduino Primer for the 6502 Project

A practical introduction to Arduino, focused on the Mega 2560 and its role in
debugging and monitoring your Ben Eater 6502 build.

## What Is Arduino, Really?

If you're coming from STM32 development, you might find Arduino a bit
disorienting at first. Let's clear up what it actually is:

**Arduino is three things:**

1. **A hardware design** — open-source reference designs for microcontroller
   boards. The Mega 2560 uses an ATmega2560 chip (an 8-bit AVR microcontroller).

2. **A software framework** — a simplified C++ library that abstracts away
   register-level details. Instead of manipulating GPIO registers directly, you
   call functions like `digitalWrite()`.

3. **An IDE** — the Arduino IDE (or CLI) handles compilation, linking, and
   uploading firmware to the board.

The key insight: Arduino trades low-level control for accessibility. You *can*
still access registers directly when needed, but the framework provides a
higher-level API for common tasks.

## The Arduino Mega 2560

The Mega is Arduino's "big board"—designed for projects that need more I/O pins
or memory than the standard Uno.

### Hardware Specifications

| Feature              | Specification                              |
|----------------------|--------------------------------------------|
| Microcontroller      | ATmega2560 (8-bit AVR)                     |
| Clock Speed          | 16 MHz                                     |
| Digital I/O Pins     | 54 (15 with PWM)                           |
| Analog Input Pins    | 16                                         |
| Flash Memory         | 256 KB (8 KB used by bootloader)           |
| SRAM                 | 8 KB                                       |
| EEPROM               | 4 KB                                       |
| Operating Voltage    | 5V                                         |
| Input Voltage        | 7-12V (recommended)                        |

### Why the Mega for 6502 Monitoring?

The W65C02 has a 16-bit address bus and an 8-bit data bus. To monitor both
buses simultaneously, you need:

* 16 pins for the address bus (A0-A15)
* 8 pins for the data bus (D0-D7)
* A few more for control signals (clock, R/W, etc.)

That's at least 25+ pins—more than an Arduino Uno's 14 digital pins can
provide. The Mega's 54 digital I/O pins give you plenty of headroom.

## Arduino Program Structure

Every Arduino program (called a "sketch") has two required functions:

```cpp
void setup() {
    // Runs once when the board powers on or resets
    // Use for initialization: pin modes, serial communication, etc.
}

void loop() {
    // Runs repeatedly after setup() completes
    // Your main program logic goes here
}
```

This is roughly equivalent to:

```c
int main() {
    setup();
    while (1) {
        loop();
    }
    return 0;
}
```

The Arduino framework handles the `main()` function for you.

## Essential Concepts

### Pin Modes

Before using a digital pin, you must configure it as input or output:

```cpp
void setup() {
    pinMode(13, OUTPUT);    // Configure pin 13 as output
    pinMode(2, INPUT);      // Configure pin 2 as input
    pinMode(3, INPUT_PULLUP); // Input with internal pull-up resistor
}
```

For 6502 monitoring, your address and data bus pins will be inputs—you're
reading what the CPU is doing, not controlling it.

### Digital I/O

Reading and writing digital pins:

```cpp
// Writing (for OUTPUT pins)
digitalWrite(13, HIGH);  // Set pin 13 to 5V
digitalWrite(13, LOW);   // Set pin 13 to 0V

// Reading (for INPUT pins)
int state = digitalRead(2);  // Returns HIGH or LOW
```

### Serial Communication

The Mega has four hardware serial ports. `Serial` connects to your computer via
USB:

```cpp
void setup() {
    Serial.begin(115200);  // Initialize at 115200 baud
}

void loop() {
    Serial.println("Hello from Arduino");
    delay(1000);
}
```

For bus monitoring, you'll use Serial to send captured data back to your
computer for analysis.

### Timing

```cpp
delay(1000);              // Pause for 1000 milliseconds
delayMicroseconds(100);   // Pause for 100 microseconds

unsigned long now = millis();   // Milliseconds since startup
unsigned long us = micros();    // Microseconds since startup
```

**Important caveat:** The Arduino framework's timing functions have overhead.
For high-speed bus monitoring, you may need to read pins in tight loops without
delays, or use direct port manipulation (covered below).

## Connecting to the Mega

### Physical Connection

1. Connect the Mega to your computer via USB (Type-A to Type-B cable, like a
   printer cable).
2. The board powers from USB—no external supply needed for basic use.

### Software Setup (Ubuntu)

The Arduino IDE is available in Ubuntu's repositories, but it's often outdated.
Better options:

**Option 1: Arduino CLI (Recommended)**

```bash
# Install Arduino CLI
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

# Add to PATH (add to .bashrc for permanence)
export PATH="$PATH:$HOME/bin"

# Initialize configuration
arduino-cli config init

# Install AVR core (for Mega)
arduino-cli core update-index
arduino-cli core install arduino:avr

# Verify installation
arduino-cli board list
```

**Option 2: Arduino IDE 2.x**

Download from https://www.arduino.cc/en/software — the AppImage works well on
Ubuntu.

### Permissions (Ubuntu)

To upload to the board without `sudo`, add yourself to the `dialout` group:

```bash
sudo usermod -a -G dialout $USER
```

Log out and back in for this to take effect.

### Identifying the Serial Port

When you connect the Mega, it appears as a serial device:

```bash
ls /dev/ttyACM*   # Usually /dev/ttyACM0
# or
ls /dev/ttyUSB*   # On some systems
```

The Arduino CLI can auto-detect it:

```bash
arduino-cli board list
```

## Your First Sketch

Create a file called `blink.ino`:

```cpp
void setup() {
    pinMode(LED_BUILTIN, OUTPUT);  // LED_BUILTIN is pin 13 on Mega
}

void loop() {
    digitalWrite(LED_BUILTIN, HIGH);
    delay(500);
    digitalWrite(LED_BUILTIN, LOW);
    delay(500);
}
```

### Compiling and Uploading (CLI)

```bash
# Compile
arduino-cli compile --fqbn arduino:avr:mega blink.ino

# Upload
arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:mega blink.ino
```

The `--fqbn` (Fully Qualified Board Name) tells the compiler which board you're
targeting. For the Mega 2560, it's `arduino:avr:mega`.

### Monitoring Serial Output

```bash
# Using Arduino CLI
arduino-cli monitor -p /dev/ttyACM0 -c baudrate=115200

# Or use screen
screen /dev/ttyACM0 115200

# Or use minicom
minicom -D /dev/ttyACM0 -b 115200
```

Press `Ctrl+A` then `K` to exit screen, or `Ctrl+A` then `X` for minicom.

## Mega-Specific Features

### Multiple Serial Ports

The Mega has four hardware UARTs:

| Port      | TX Pin | RX Pin | Usage                        |
|-----------|--------|--------|------------------------------|
| Serial    | 1      | 0      | USB connection to computer   |
| Serial1   | 18     | 19     | Available for external use   |
| Serial2   | 16     | 17     | Available for external use   |
| Serial3   | 14     | 15     | Available for external use   |

For 6502 work, you'll typically use `Serial` for debugging output.

### Pin Mapping

The Mega's pins are grouped into ports (like any AVR chip). Knowing this
becomes important for fast I/O:

| Port  | Pins         |
|-------|--------------|
| PORTA | 22-29        |
| PORTB | 10-13, 50-53 |
| PORTC | 30-37        |
| PORTD | 18-21, 38    |
| PORTE | 0-3, 5       |
| PORTF | A0-A7        |
| PORTG | 4, 39-41     |
| PORTH | 6-9, 16-17   |
| PORTJ | 14-15        |
| PORTK | A8-A15       |
| PORTL | 42-49        |

For efficient bus monitoring, you'll want to read entire ports at once rather
than individual pins—covered in the next section.

## Direct Port Manipulation

The Arduino functions `digitalRead()` and `digitalWrite()` are convenient but
slow. Each call takes ~50 CPU cycles. For monitoring a 1 MHz 6502, you need
faster access.

### Reading a Port

Each port has three registers:

* `DDRx` — Data Direction Register (0 = input, 1 = output)
* `PORTx` — Output register (also controls pull-ups for inputs)
* `PINx` — Input register (read current pin states)

Example—reading all 8 pins of PORTA (pins 22-29) at once:

```cpp
void setup() {
    DDRA = 0x00;  // All pins as input
    Serial.begin(115200);
}

void loop() {
    uint8_t value = PINA;  // Read all 8 pins simultaneously
    Serial.println(value, BIN);
    delay(100);
}
```

This reads 8 bits in a single CPU cycle, compared to 8 × 50+ cycles for eight
`digitalRead()` calls.

### Why This Matters for 6502 Monitoring

At 1 MHz, the 6502 completes one clock cycle per microsecond. The Mega runs at
16 MHz, giving you ~16 Arduino clock cycles per 6502 clock cycle. That sounds
like plenty, but:

* A single `digitalRead()` takes ~50 cycles (3+ µs)
* `Serial.print()` is *much* slower

For reliable monitoring, you'll likely:

1. Use direct port reads
2. Buffer data in RAM
3. Output to serial only during pauses or after capturing a burst

Ben Eater's monitor sketch addresses these constraints.

## Practical Example: Simple Bus Monitor

Here's a minimal example that reads 8 bits from a port on each clock edge:

```cpp
const int CLOCK_PIN = 2;  // Connect 6502 clock here

volatile uint8_t capturedData;
volatile bool dataReady = false;

void setup() {
    Serial.begin(115200);
    DDRA = 0x00;  // PORTA (pins 22-29) as input
    pinMode(CLOCK_PIN, INPUT);
    
    // Trigger interrupt on rising edge of clock
    attachInterrupt(digitalPinToInterrupt(CLOCK_PIN), onClock, RISING);
}

void onClock() {
    capturedData = PINA;
    dataReady = true;
}

void loop() {
    if (dataReady) {
        Serial.println(capturedData, HEX);
        dataReady = false;
    }
}
```

This is simplified—a real monitor captures address + data + control signals and
formats them readably. But it illustrates the pattern: interrupt on clock,
capture fast, process later.

## Common Pitfalls

### Serial Buffer Overflow

`Serial.print()` is buffered (64 bytes by default). If you print faster than
the USB can transmit, the buffer fills and data is lost. Solutions:

* Print less frequently
* Use higher baud rates (up to 2000000 on Mega)
* Buffer data in your own array first

### 5V Logic Levels

The Mega operates at 5V. The W65C02 is also 5V, so they're compatible. If you
ever mix in 3.3V components, you'll need level shifters.

### Pin 0 and 1

Pins 0 and 1 are connected to the USB-serial chip. Avoid using them for other
purposes, or you'll interfere with uploads and serial communication.

### Reset on Serial Connect

By default, opening a serial connection to the Mega resets it. This is usually
helpful (ensures your sketch restarts cleanly) but can be surprising during
debugging.

## Development Workflow

A typical edit-compile-upload cycle:

```bash
# Edit your sketch
vim mysketch.ino

# Compile (catches errors quickly)
arduino-cli compile --fqbn arduino:avr:mega mysketch.ino

# Upload
arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:mega mysketch.ino

# Monitor output
arduino-cli monitor -p /dev/ttyACM0 -c baudrate=115200
```

You can also use the Arduino IDE if you prefer a GUI, but the CLI integrates
nicely into terminal-based workflows.

## Next Steps

Once your Mega arrives, try these exercises:

1. **Blink the LED** — verify your toolchain works
2. **Serial echo** — send characters to the Mega and have it echo them back
3. **Read a button** — practice with digital input
4. **Read multiple pins** — try both `digitalRead()` and direct port access;
   compare the code complexity and observe timing differences with an
   oscilloscope or logic analyzer if available

When you're ready to integrate with the 6502:

* Ben Eater has a specific monitor sketch in his video series
* The basic idea: connect address bus to one or two ports, data bus to another,
  clock to an interrupt pin
* Capture on each clock edge, format, and print

## Additional Resources

* [Arduino Language Reference](https://www.arduino.cc/reference/en/)
* [ATmega2560 Datasheet](https://ww1.microchip.com/downloads/en/devicedoc/atmel-2549-8-bit-avr-microcontroller-atmega640-1280-1281-2560-2561_datasheet.pdf) — for when you need the full hardware details
* [Arduino CLI Documentation](https://arduino.github.io/arduino-cli/)
* Ben Eater's 6502 monitor video (part of the playlist you're following)
