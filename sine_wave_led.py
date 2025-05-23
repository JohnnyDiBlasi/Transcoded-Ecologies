
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
BUFFER_SIZE = 44100  # 1 second of audio

# Initialize DotStar LED strip
dots = dotstar.DotStar(board.SCK, board.MOSI, LED_COUNT, brightness=BRIGHTNESS)

def generate_continuous_wave():
    """Generate a continuous sine wave."""
    t = np.arange(BUFFER_SIZE, dtype=np.float32) / SAMPLE_RATE
    return np.float32(0.5 * np.sin(2 * np.pi * FREQUENCY * t))

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
        
        # Generate the continuous wave
        samples = generate_continuous_wave()
        
        # Start the audio stream
        stream = sd.OutputStream(
            samplerate=SAMPLE_RATE,
            channels=1,
            dtype='float32'
        )
        stream.start()
        
        print("Press Ctrl+C to stop")
        
        # Continuous playback loop
        while True:
            stream.write(samples)
            # Update LEDs based on the current sample
            update_leds(samples[0])
            time.sleep(0.01)  # Small delay to prevent CPU overload
            
    except KeyboardInterrupt:
        print("\nStopping...")
    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        if 'stream' in locals():
            stream.stop()
            stream.close()
        # Turn off all LEDs
        dots.fill((0, 0, 0))
        dots.show()

if __name__ == "__main__":
    main()
