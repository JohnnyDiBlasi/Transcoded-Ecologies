import time
import math
import numpy as np
import sounddevice as sd
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
    # List available audio devices
    print("Available audio devices:")
    print(sd.query_devices())
    
    # Get default output device
    device_info = sd.query_devices(kind='output')
    print(f"\nUsing audio device: {device_info['name']}")
    
    try:
        print("Starting audio and LED control...")
        while True:
            # Generate sine wave
            samples = generate_sine_wave()
            
            # Play sound and update LEDs
            sd.play(samples, SAMPLE_RATE)
            for sample in samples:
                update_leds(sample)
                time.sleep(0.001)  # Small delay to control LED update rate
            
            # Wait for the sound to finish playing
            sd.wait()
            
    except KeyboardInterrupt:
        print("\nStopping...")
    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        # Cleanup
        sd.stop()
        # Turn off all LEDs
        dots.fill((0, 0, 0))
        dots.show()

if __name__ == "__main__":
    main()