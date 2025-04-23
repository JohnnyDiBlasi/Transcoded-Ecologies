import time
import math
import numpy as np
import sounddevice as sd
import board
import adafruit_dotstar as dotstar
import threading
from queue import Queue

# Constants
SAMPLE_RATE = 44100
FREQUENCY = 440  # Hz (A4 note)
LED_COUNT = 120
BRIGHTNESS = 0.4
BUFFER_SIZE = 44100  # 1 second of audio

# Initialize DotStar LED strip
dots = dotstar.DotStar(board.SCK, board.MOSI, LED_COUNT, brightness=BRIGHTNESS)

# Global variables for LED control
running = True
amplitude_queue = Queue()

def generate_continuous_wave():
    """Generate a continuous sine wave."""
    t = np.arange(BUFFER_SIZE, dtype=np.float32) / SAMPLE_RATE
    return np.float32(0.5 * np.sin(2 * np.pi * FREQUENCY * t))

def update_leds():
    """Update LED colors based on sound amplitude."""
    global running
    position = 0
    
    while running:
        try:
            # Get the latest amplitude from the queue
            if not amplitude_queue.empty():
                amplitude = amplitude_queue.get()
                brightness = int(abs(amplitude) * 255)
                
                # Update all LEDs
                for i in range(LED_COUNT):
                    # Create a moving wave effect
                    pos = (i + position) % LED_COUNT
                    dots[pos] = (brightness, 0, 0)
                
                dots.show()
                position = (position + 1) % LED_COUNT
            
            time.sleep(0.01)  # Small delay to control update rate
            
        except Exception as e:
            print(f"LED update error: {str(e)}")
            continue

def main():
    global running
    
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
        
        # Start LED update thread
        led_thread = threading.Thread(target=update_leds, daemon=True)
        led_thread.start()
        
        print("Press Ctrl+C to stop")
        
        # Continuous playback loop
        while running:
            stream.write(samples)
            # Put the current amplitude in the queue
            amplitude_queue.put(samples[0])
            time.sleep(0.001)  # Small delay to prevent CPU overload
            
    except KeyboardInterrupt:
        print("\nStopping...")
        running = False
    except Exception as e:
        print(f"Error: {str(e)}")
        running = False
    finally:
        if 'stream' in locals():
            stream.stop()
            stream.close()
        # Turn off all LEDs
        dots.fill((0, 0, 0))
        dots.show()
        # Wait for LED thread to finish
        if 'led_thread' in locals():
            led_thread.join(timeout=1.0)

if __name__ == "__main__":
    main()

