import threading
import time
import sys
from boxmonitorservice import orgbclient
import subprocess
import re

def get_keyboard_device():
    # Command to list devices and grep for the specific keyboard model
    command = "openrgb -l | grep '[0-9]\+:.*G915'"
    try:
        # Run the command and capture the output
        result = subprocess.run(command, shell=True, check=True, text=True, stdout=subprocess.PIPE)
        # Use regex to find the first device number in the output
        match = re.search(r'(\d+):', result.stdout)
        if match:
            return int(match.group(1))
        else:
            raise ValueError("G915 keyboard not found")
    except subprocess.CalledProcessError:
        raise RuntimeError("Failed to execute command to find keyboard device")



class OpenRGBEffect:
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
        self.openrgb_client = openrgb_client
        self.device = get_keyboard_device()

    def run(self):
        pass

    def stop(self):
        pass


class OpenRGBEffectKeyboardBlink(OpenRGBEffect):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient, on_seconds: float, off_seconds: float, blinks_count: int = 3, color: str = "0000ff"):
        super().__init__(openrgb_client)
        self.openrgb_client = openrgb_client
        self.on_seconds = on_seconds
        self.off_seconds = off_seconds
        self.blinks_count = blinks_count
        self.color = color

    def run(self):
        #print(f"run blink, color={self.color}", file=sys.stderr)
        for i in range(self.blinks_count):
            self.openrgb_client.send(f"-d {self.device} -c {self.color}")
            time.sleep(self.on_seconds)
            self.openrgb_client.send(f"-d {self.device} -c 000000")
            time.sleep(self.off_seconds)

class OpenRGBEffectKeyboardLetter(OpenRGBEffect):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient, color: str = "0000ff", character: str = "a"):
        super().__init__(openrgb_client)
        self.openrgb_client = openrgb_client
        self.color = color
        self.led_id = ord(character) - ord('a')

    def run(self):
        #print(f"run letter, key={self.led_id}", file=sys.stderr)
        self.openrgb_client.send(f"-d {self.device} -c {self.color} -L {self.led_id}")

    def stop(self):
        #print(f"stop letter, key={self.led_id}", file=sys.stderr)
        self.openrgb_client.send(f"-d {self.device} -c 000000 -L {self.led_id}")

class OpenRGBEffectProfile(OpenRGBEffect):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient, profile: str):
        super().__init__(openrgb_client)
        self.openrgb_client = openrgb_client
        self.profile = profile

    def run(self):
        self.openrgb_client.send(f"-p {self.profile}")


class OpenRGBEffectIdle(OpenRGBEffectProfile):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
        super().__init__(openrgb_client, "idle")


class OpenRGBEffectBusy(OpenRGBEffectProfile):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
        super().__init__(openrgb_client, "busy")


class OpenRGBEffectError(OpenRGBEffectProfile):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
        super().__init__(openrgb_client, "error")


class OpenRGBEffectOk(OpenRGBEffectProfile):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
        super().__init__(openrgb_client, "ok")

class OpenRGBEffectNewEmail(OpenRGBEffectKeyboardBlink):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
        super().__init__(openrgb_client, 0.9, 0.1, 1, "000066")

class OpenRGBEffectNewMessage(OpenRGBEffectKeyboardBlink):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
        super().__init__(openrgb_client, 0.9, 0.1, 1, "660066")

class OpenRGBEffectBlank(OpenRGBEffectKeyboardBlink):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
        super().__init__(openrgb_client, 0.01, 0.01, 1, "000000")

# class OpenRGBEffectEmailUnread(OpenRGBEffectKeyboardBlink):
#     def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
#         super().__init__(openrgb_client, 2.0, 0.1, 1, "0000aa")
#
# class OpenRGBEffectImUnread(OpenRGBEffectKeyboardBlink):
#     def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
#         super().__init__(openrgb_client, 2.0, 0.1, 1, "aa00aa")

class OpenRGBEffectEmailUnread(OpenRGBEffectKeyboardLetter):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
        super().__init__(openrgb_client, "0000cc", 'e')

class OpenRGBEffectImUnread(OpenRGBEffectKeyboardLetter):
    def __init__(self, openrgb_client: orgbclient.OpenRGBClient):
        super().__init__(openrgb_client, "cc00cc", 'm')
