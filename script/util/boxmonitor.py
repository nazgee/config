#!/usr/bin/python3
import os
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


# openrgb -d "Logitech G915 Wireless RGB Mechanical Gaming Keyboard" -c 0000ff

colorMap = {"idle": "0000ff", "busy": "55280a", "error": "ff0000", "ok": "00ff00", "off": "000000"}
#colorMap = {"idle": "0000ff", "busy": "20004", "error": "ff0000", "ok": "00ff00", "off": "000000"}
orgbBlink="openrgb -d \"Logitech G915 Wireless RGB Mechanical Gaming Keyboard\" -c "

elapsedTimer: Timer = None
completed: subprocess.CompletedProcess = None
orgbip: str = ""

def start_org_blink(state, client_ip):
    start_org_blink.blinkProcess = None

    if start_org_blink.blinkProcess and start_org_blink.blinkProcess.poll() is None:
        start_org_blink.blinkProcess.kill()

    if client_ip and client_ip != "":
        blink_start = orgbBlink + colorMap[state] + " --client " + client_ip
        blinkStop = orgbBlink + colorMap["off"] + " --client " + client_ip
    else:
        blink_start = orgbBlink + colorMap[state]
        blinkStop = orgbBlink + colorMap["off"]

    blink = "for i in 2 2; do " + blink_start + " && sleep $i && " + blinkStop + " && sleep 0.2 ; done"
    start_org_blink.blinkProcess = subprocess.Popen(["bash", "-c", blink], stdout=subprocess.DEVNULL, start_new_session=True)

def set_orgb_state(state, client_ip):
    if client_ip and client_ip != "":
        orgb = subprocess.run(["openrgb", "-p", state, "--client", client_ip], stdout=subprocess.DEVNULL)
    else:
        orgb = subprocess.run(["openrgb", "-p", state], stdout=subprocess.DEVNULL)
    print("orgb.returncode=" + str(orgb.returncode))

    start_org_blink(state, client_ip)

def on_success(msg):
    print(msg + "\n" + elapsedTimer.elapsed_str())
    set_orgb_state("ok", orgbip)
    exit(0)


def on_failure(msg):
    print(msg + "\n" + elapsedTimer.elapsed_str())
    set_orgb_state("error", orgbip)
    exit(1)


def on_idle(msg):
    if elapsedTimer:
        print(msg + "\n" + elapsedTimer.elapsed_str())
    else:
        print(msg)
    set_orgb_state("idle", orgbip)
    exit(0)


def handler(signum, frame):
    on_idle("INTERRUPTED!")
    exit(1)


def run_subprocess(args):
    global elapsedTimer
    global completed

    signal.signal(signal.SIGINT, handler)
    try:
        set_orgb_state("busy", orgbip)
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
    parser.add_argument("--orgbip", default="", help="IP address of OpenRGB server. In not given, environemnt's ORGBIP will be tried. If none of them are set, local instance will be used and --connect argument will not be passed to orgb (default: %(default)s)")
    parser.add_argument("command", nargs=argparse.REMAINDER, help="Command to run and its arguments")
    args = parser.parse_args()

    orgbip = args.orgbip

    if orgbip == "":
        # if ORGBIP env var is set (e.g. to "172.17.0.1"), use it as default value
        if "ORGBIP" in os.environ:
            orgbip = os.environ["ORGBIP"]

    if not args.command:
        on_idle("idle")
        parser.error("Command is required")

    if args.command[0].startswith("("):
        print("starting bash \"" + args.command[0] + "\" subshell")
        run_subprocess(["bash", "-c", args.command[0]])
    else:
        run_subprocess(args.command)
