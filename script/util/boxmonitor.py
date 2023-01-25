#!/usr/bin/python3

import subprocess
import argparse
import signal

def on_success(timeout, msg):
    print("OK: " + msg)
    subprocess.run(["openrgb", "-p", "ok"], stdout=subprocess.DEVNULL)


def on_failure(timeout, msg):
    print("FAIL: " + msg)
    subprocess.run(["openrgb", "-p", "error"], stdout=subprocess.DEVNULL)


def on_idle(timeout, msg):
    print("IDLE: " + msg)
    subprocess.run(["openrgb", "-p", "idle"], stdout=subprocess.DEVNULL)


completed : subprocess.CompletedProcess = None


def handler(signum, frame):
    on_idle(0, "interrupted")
    exit(1)


def run_subprocess(args, timeout):
    signal.signal(signal.SIGINT, handler)

    try:
        subprocess.run(["openrgb", "-p", "busy"], stdout=subprocess.DEVNULL)
        completed = subprocess.run(args)
        if completed.returncode < 0:
            on_failure(timeout, f"terminated by signal {-completed.returncode}")
        elif completed.returncode == 0:
            on_success(timeout, f"ok")
        else:
            on_failure(timeout, f"failed with {completed.returncode}")
    except OSError as e:
        on_failure(timeout, f"failed with {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("command", nargs=argparse.REMAINDER, help="Command to run and its arguments")
    parser.add_argument("--timeout", type=int, help="Timeout for the command in seconds")
    args = parser.parse_args()

    if not args.command:
        on_idle(0, "startup")
        parser.error("Command is required")

    run_subprocess(args.command, timeout=args.timeout)
