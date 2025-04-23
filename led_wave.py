
import time
import math
import numpy as np
import sounddevice as sd
import board
import adafruit_dotstar as dotstar
import threading

# Constants
SAMPLE_RATE = 44100
FREQUENCY = 440  # Hz (A4 note)
LED_COUNT = 120
BRIGHTNESS = 0.4
BUFFER_SIZE = 44100  # 1 second of audio

# Initialize DotStar LED strip
dots = dotstar.DotStar(board.SCK, board.MOSI, LED_COUNT, brightness=BRIGHTNESS)

# Global variables for LED control
current_amplitude = 0
running = True

def generate_continuous_wave():
    """Generate a continuous sine wave."""
    t = np.arange(BUFFER_SIZE, dtype=np.float32) / SAMPLE_RATE
    return np.float32(0.5 * np.sin(2 * np.pi * FREQUENCY * t))

def update_leds():
    """Update LED colors based on sound amplitude."""
    global current_amplitude
    time_offset = 0
    while running:
        # Map amplitude to LED brightness
        brightness = int(abs(current_amplitude) * 255)
        for i in range(LED_COUNT):
            # Create a moving wave effect
            position = (i + int(time.time() * 10 + time_offset)) % LED_COUNT
            dots[position] = (brightness, 0, 0)  # Red color
        dots.show()  # Make sure to show the changes
        time_offset += 0.1  # Increment time offset for wave movement
        time.sleep(0.01)  # Small delay to control LED update rate

def main():
    global current_amplitude, running
    
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
        led_thread = threading.Thread(target=update_leds)
        led_thread.start()
        
        print("Press Ctrl+C to stop")
        
        # Continuous playback loop
        while running:
            stream.write(samples)
            # Update the current amplitude for LED control
            current_amplitude = samples[0]
            
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
            led_thread.join()

if __name__ == "__main__":
    main()

