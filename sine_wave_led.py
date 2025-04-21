import time
import math
import numpy as np
import sounddevice as sd
import board
import adafruit_dotstar as dotstar

# Constants
SAMPLE_RATE = 44100
FREQUENCY = 440  # Hz (A4 note)
LED_COUNT = 120
BRIGHTNESS = 0.4
CHUNK_SIZE = 1024  # Number of samples per callback

# Initialize DotStar LED strip
dots = dotstar.DotStar(board.SCK, board.MOSI, LED_COUNT, brightness=BRIGHTNESS)

# Global variables for audio generation
phase = 0
amplitude = 0.5

def audio_callback(outdata, frames, time, status):
    """Callback function for continuous audio generation."""
    global phase
    if status:
        print(status)
    
    # Generate continuous sine wave
    t = (phase + np.arange(frames)) / SAMPLE_RATE
    t = t.reshape(-1, 1)
    outdata[:] = amplitude * np.sin(2 * np.pi * FREQUENCY * t)
    phase += frames
    
    # Update LEDs based on current amplitude
    update_leds(outdata[0][0])

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
        print("Starting continuous audio and LED control...")
        # Start the audio stream with callback
        with sd.OutputStream(channels=1,
                           samplerate=SAMPLE_RATE,
                           blocksize=CHUNK_SIZE,
                           callback=audio_callback):
            print("Press Ctrl+C to stop")
            while True:
                time.sleep(0.1)  # Keep the main thread alive
            
    except KeyboardInterrupt:
        print("\nStopping...")
    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        # Turn off all LEDs
        dots.fill((0, 0, 0))
        dots.show()

if __name__ == "__main__":
    main()