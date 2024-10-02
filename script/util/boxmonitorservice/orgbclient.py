import subprocess
import sys
import threading
import time

class OpenRGBClient:
    def __init__(self):
        self.lock = threading.Lock()
        self.process = None
        self.threads = []
        self.running = threading.Event()
        self.counter = 0
        self.connect()
        print("OpenRGBClient ready")

    def connect(self):
        self.running.set()
        if self.process:
            self.process.terminate()
            self.process.wait()
            for t in self.threads:
                t.join()

        self.process = subprocess.Popen(
            ["openrgb", "--nodetect", "-d", "Logitech G915 Wireless RGB Mechanical Gaming Keyboard", "-c", "000000", "--interactive"],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)

        self.threads = [
            threading.Thread(target=self.read_stream, args=(self.process.stdout, "stdout")),
            threading.Thread(target=self.read_stream, args=(self.process.stderr, "stderr"))
        ]
        for t in self.threads:
            t.start()

        time.sleep(3)

    def send(self, message):
        with self.lock:
            try:
                self.counter += 1
                print(f"Sending message {self.counter}: {message}", file=sys.stderr)
                self.process.stdin.write(message + "\n")
                self.process.stdin.flush()
            except Exception as e:
                print(f"Error: {e}", file=sys.stderr)
                print("Restarting openrgb...", file=sys.stderr)
                self.connect()

    def read_stream(self, stream, stream_name):
        while self.running.is_set():
            line = stream.readline()
            if line:
                print(f"Received from {stream_name}: {line.strip()}", file=sys.stderr)
            else:
                break


class OpenRGBClientXXX:
    def __init__(self):
        self.lock = threading.Lock()
        self.process = None
        self.counter = 0
        self.connect()
        print("OpenRGBClient ready")

    def connect(self):
        start_readers = self.process == None
        self.process = subprocess.Popen(
            ["openrgb", "--nodetect", "-d", "Logitech G915 Wireless RGB Mechanical Gaming Keyboard", "-c", "000000", "--interactive"],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        
        # Start threads to capture and print output from stdout and stderr
        if start_readers:
            threading.Thread(target=self.read_stream, args=(self.process.stdout, "stdout")).start()
            threading.Thread(target=self.read_stream, args=(self.process.stderr, "stderr")).start()

        time.sleep(3)

    def send(self, message):
        with self.lock:
            try:
                self.counter = self.counter + 1
                print(f"Sending message {self.counter}: {message}", file=sys.stderr)
                self.process.stdin.write(message + "\n")
                self.process.stdin.flush()
            except KeyboardInterrupt:
                # Handle Ctrl+C to gracefully terminate the script
                print("boxmonitor-service.py terminated by user", file=sys.stderr)
            except Exception as e:
                # Handle any exceptions that might occur during the subprocess or I/O operations
                print(f"Error: {e}", file=sys.stderr)
                print("Restarting openrgb...", file=sys.stderr)
                #self.process.kill()  # Kill the previous subprocess if it's still running
                self.process.terminate()  # Kill the previous subprocess if it's still running
                self.connect()

    def read_stream(self, stream, stream_name):
        """Function to continuously read from a stream and print its output."""
        while True:
            line = stream.readline()
            if line:
                print(f"Received from {stream_name}: {line.strip()}", file=sys.stderr)
            else:
                break


