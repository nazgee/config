#!/usr/bin/python3

import paramiko
import json
import argparse
import getpass
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--username", default=getpass.getuser(), help="username to use with ssh (default: %(default)s)")
parser.add_argument("--server", default="aerepo.cloud.panasonicautomotive.com", help="gerrit server to use (default: %(default)s)")
parser.add_argument("--port", type=int, default=29418, help="gerrit port server to use (default: %(default)s)")
parser.add_argument("--cherry-pick", action="store_true",  default=False, help="cherry-pick instead of checkout")

search_type_group = parser.add_mutually_exclusive_group(required=True)
search_type_group.add_argument("--topic", type=str, required=False, help="gerrit topic to apply changes from")
search_type_group.add_argument("--hashtag", type=str, required=False, help="gerrit hashtag to apply changes from")


args = parser.parse_args()

# Set up the ssh client
client = paramiko.SSHClient()
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

# Connect to the server
client.connect(
    args.server,
    port=args.port,
    username=args.username
)

ssh_cmdline = "gerrit query --format=JSON --current-patch-set status:open"
if args.topic:
    ssh_cmdline = ssh_cmdline + " topic:" + args.topic
else:
    ssh_cmdline = ssh_cmdline + " hashtag:" + args.hashtag

# Execute the gerrit query command
stdin, stdout, stderr = client.exec_command(ssh_cmdline)

class Change:
    def __init__(self, data):
        self.project = data["project"]
        self.id = data["number"]
        self.subject = data["subject"]
        self.base_repo_cmd="repo download --quiet"
        result = subprocess.run(f"repo list {self.project}", shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        if (result.returncode == 0):
            self.path = result.stdout.decode().split(" :")[0]
        else:
            self.path = "?"
        self.last_error = None

    def download(self):
        cmd = f"{self.base_repo_cmd} {self.project} {self.id}"
        result = subprocess.run(cmd, shell=True, stderr=subprocess.PIPE)
        if result.returncode == 0:
            return True
        else:
            self.last_error = result.stderr.decode()
            return False

    def cherrypick(self):
        cmd = f"{self.base_repo_cmd} --cherry-pick {self.project} {self.id}"
        result = subprocess.run(cmd, shell=True, stderr=subprocess.PIPE)
        if result.returncode == 0:
            return True
        else:
            self.last_error = result.stderr.decode()
            return False

    def dumpstring(self):
        def limit_text(text: str, limit: int) -> str:
            if len(text) > limit:
                return "..." + text[-limit+3:]
            else:
                return text.ljust(limit)

        return f"{self.id} {limit_text(self.path, 40)} | {limit_text(self.project, 40)} | {limit_text(self.subject, 50)}"

# If the command was successful (exit code 0), parse the output as JSON
if stderr.channel.recv_exit_status() == 0:
    # Split the string into lines
    lines = stdout.read().decode().split("\n")

    changes = []
    changes_ok = []
    changes_failed = []

    # Iterate over the lines and parse each line as JSON
    for line in lines:
        if line:  # Ignore empty lines
            data = json.loads(line)
            if not "project" in data:
                continue
            else:
                changes.append(Change(data))

    if len(changes) == 0:
        print(f">>> no changes with given topic or hashtag found, bye")
    else:

        for change in changes:
            ok = False
            if args.cherry_pick:
                print(f">>> cherry-pick {change.dumpstring()}")
                ok = change.cherrypick()
            else:
                print(f">>> checkout {change.dumpstring()}")
                ok = change.download()

            if ok:
                # print(f">>> OK")
                changes_ok.append(change)
            else:
                print(f"{change.last_error}")
                print(f">>> FAILED")
                changes_failed.append(change)

        n_total = len(changes)
        n_ok = len(changes_ok)
        n_failed = len(changes_failed)

        if n_ok > 0:
            print(f">>> {n_ok}/{n_total} OK")
            for change in changes_ok:
                print(f"\t{change.dumpstring()}")

        if n_failed > 0:
            print(f">>> {n_failed}/{n_total} FAILED")
            for change in changes_failed:
                print(f"\t{change.dumpstring()}")

else:
    # Print the stderr output if the command failed
    print(stderr.read())

# Disconnect from the server
client.close()
