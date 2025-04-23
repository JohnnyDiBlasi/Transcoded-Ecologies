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
print("Initializing LED strip...")
dots = dotstar.DotStar(board.SCK, board.MOSI, LED_COUNT, brightness=BRIGHTNESS)
print("LED strip initialized")

def generate_continuous_wave():
    """Generate a continuous sine wave."""
    t = np.arange(BUFFER_SIZE, dtype=np.float32) / SAMPLE_RATE
    return np.float32(0.5 * np.sin(2 * np.pi * FREQUENCY * t))

def update_leds(amplitude, position):
    """Update LED colors based on sound amplitude."""
    try:
        brightness = int(abs(amplitude) * 255)
        # Only print every 100 updates to reduce console output
        if position % 100 == 0:
            print(f"Updating LEDs - Amplitude: {amplitude}, Brightness: {brightness}, Position: {position}")
        
        # Update all LEDs
        for i in range(LED_COUNT):
            pos = (i + position) % LED_COUNT
            dots[pos] = (brightness, 0, 0)
        
        dots.show()
    except Exception as e:
        print(f"Error updating LEDs: {str(e)}")

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
        print("Generated audio samples")
        
        # Start the audio stream
        stream = sd.OutputStream(
            samplerate=SAMPLE_RATE,
            channels=1,
            dtype='float32'
        )
        stream.start()
        print("Audio stream started")
        
        print("Press Ctrl+C to stop")
        
        # Continuous playback loop
        position = 0
        sample_index = 0
        
        while True:
            # Play audio
            stream.write(samples)
            
            # Update LEDs using a sample from the buffer
            sample_index = (sample_index + 1) % len(samples)
            update_leds(samples[sample_index], position)
            position = (position + 1) % LED_COUNT
            
            # Reduced sleep time to make audio smoother
            time.sleep(0.001)
            
    except KeyboardInterrupt:
        print("\nStopping...")
    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        if 'stream' in locals():
            stream.stop()
            stream.close()
        # Turn off all LEDs
        print("Turning off LEDs")
        dots.fill((0, 0, 0))
        dots.show()
        print("LEDs turned off")

if __name__ == "__main__":
    main()

