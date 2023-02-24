#!/usr/bin/python3

import subprocess
import argparse
import signal
import time


# Class that measures the time between two events
class Timer:
    def __init__(self):
        self.start = time.time()

    def elapsed(self):
        return time.time() - self.start

    def reset(self):
        self.start = time.time()

    # returns the string representing elapsed elapsed
    # time in as e.g. 1h:2m:33s or 4m:12s or 12s
    def elapsed_str(self):
        elapsed = self.elapsed()
        hours = int(elapsed / 3600)
        minutes = int((elapsed - hours * 3600) / 60)
        seconds = int(elapsed - hours * 3600 - minutes * 60)

        if hours > 0:
            return f"Time used: {hours}h:{minutes}m:{seconds}s"
        elif minutes > 0:
            return f"Time used: {minutes}m:{seconds}s"
        else:
            return f"Time used: {seconds}s"


elapsedTimer: Timer = None
completed: subprocess.CompletedProcess = None
orgbip: str = ""

def on_success(msg):
    print(msg + "\n" + elapsedTimer.elapsed_str())
    subprocess.run(["openrgb", "-p", "ok", "--client", orgbip], stdout=subprocess.DEVNULL)
    exit(0)


def on_failure(msg):
    print(msg + "\n" + elapsedTimer.elapsed_str())
    subprocess.run(["openrgb", "-p", "error", "--client", orgbip], stdout=subprocess.DEVNULL)
    exit(1)


def on_idle(msg):
    if elapsedTimer:
        print(msg + "\n" + elapsedTimer.elapsed_str())
    else:
        print(msg)
    subprocess.run(["openrgb", "-p", "idle", "--client", orgbip], stdout=subprocess.DEVNULL)
    exit(0)


def handler(signum, frame):
    on_idle("INTERRUPTED!")
    exit(1)


def run_subprocess(args):
    global elapsedTimer
    global completed

    signal.signal(signal.SIGINT, handler)
    try:
        subprocess.run(["openrgb", "-p", "busy", "--client", orgbip], stdout=subprocess.DEVNULL)
        elapsedTimer = Timer()
        completed = subprocess.run(args)
        if completed.returncode < 0:
            on_failure(f"WARNNG! Terminated by signal {-completed.returncode}")
        elif completed.returncode == 0:
            on_success(f"OK")
        else:
            on_failure(f"ERROR! Failed with {completed.returncode}")
    except OSError as e:
        on_failure(f"ERROR! Failed with {e}")



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--orgbip", default="127.0.0.1", help="IP address of OpenRGB server (default: %(default)s)")
    parser.add_argument("command", nargs=argparse.REMAINDER, help="Command to run and its arguments")
    args = parser.parse_args()
    orgbip = args.orgbip

    if not args.command:
        on_idle("idle")
        parser.error("Command is required")

    run_subprocess(args.command)
