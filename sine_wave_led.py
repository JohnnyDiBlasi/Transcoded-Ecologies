import time
import math
import numpy as np
import pyaudio
import board
import adafruit_dotstar as dotstar

# Constants
SAMPLE_RATE = 44100
DURATION = 0.1  # seconds
FREQUENCY = 440  # Hz (A4 note)
LED_COUNT = 120
BRIGHTNESS = 0.4

# Initialize DotStar LED strip
dots = dotstar.DotStar(board.SCK, board.MOSI, LED_COUNT, brightness=BRIGHTNESS)

def generate_sine_wave():
    """Generate a sine wave sample."""
    t = np.linspace(0, DURATION, int(SAMPLE_RATE * DURATION), False)
    return np.sin(2 * np.pi * FREQUENCY * t)

def update_leds(amplitude):
    """Update LED colors based on sound amplitude."""
    # Map amplitude to LED brightness
    brightness = int(abs(amplitude) * 255)
    for i in range(LED_COUNT):
        # Create a moving wave effect
        position = (i + int(time.time() * 10)) % LED_COUNT
        dots[position] = (brightness, 0, 0)  # Red color

def main():
    # Initialize PyAudio
    p = pyaudio.PyAudio()
    
    # Open stream
    stream = p.open(format=pyaudio.paFloat32,
                    channels=1,
                    rate=SAMPLE_RATE,
                    output=True)
    
    try:
        while True:
            # Generate sine wave
            samples = generate_sine_wave()
            
            # Play sound and update LEDs
            for sample in samples:
                stream.write(sample.astype(np.float32).tobytes())
                update_leds(sample)
                time.sleep(0.001)  # Small delay to control LED update rate
            
    except KeyboardInterrupt:
        print("\nStopping...")
    finally:
        # Cleanup
        stream.stop_stream()
        stream.close()
        p.terminate()
        # Turn off all LEDs
        dots.fill((0, 0, 0))
        dots.show()

if __name__ == "__main__":
    main() 