#!/usr/bin/python3
import queue
import socketserver
import sys
import threading
import time
from collections import defaultdict
from enum import Enum

from boxmonitorservice.orgbclient import OpenRGBClient
import boxmonitorservice.effects as effects


openrgb_client = OpenRGBClient()


class BoxStatus(Enum):
    IDLE = ("@idle", effects.OpenRGBEffectIdle(openrgb_client))
    BUSY = ("@busy", effects.OpenRGBEffectBusy(openrgb_client))
    ERROR = ("@error", effects.OpenRGBEffectError(openrgb_client))
    OK = ("@ok", effects.OpenRGBEffectOk(openrgb_client))

    def __init__(self, status_name: str, effect: effects.OpenRGBEffect):
        self.effect = effect
        self.status_name = status_name

    def apply(self):
        if self.effect:
            self.effect.run()


class NotificationStatus(Enum):
    UNREAD_EMAIL = effects.OpenRGBEffectEmailUnread(openrgb_client)
    UNREAD_IM = effects.OpenRGBEffectImUnread(openrgb_client)

    def __init__(self, effect: effects.OpenRGBEffect):
        self.effect = effect

    def apply(self):
        self.effect.run()

    def clear(self):
        self.effect.stop()

class NotificationEvent(Enum):
    NEW_EMAIL = effects.OpenRGBEffectNewEmail(openrgb_client)
    NEW_MESSAGE = effects.OpenRGBEffectNewMessage(openrgb_client)

    def __init__(self, effect: effects.OpenRGBEffect):
        self.effect = effect

    def apply(self):
        if self.effect:
            self.effect.run()


class NotificationManager:
    def __init__(self, openrgb_client: OpenRGBClient):
        self.openrgb_client = openrgb_client
        self.active_notifications = defaultdict(set)
        self.notifications_queue = queue.Queue()
        self.notifications_thread = threading.Thread(target=self.handle_notifications)
        self.notifications_thread.start()

    def handle_notifications(self):
        def update_status():
            for session, notifications in self.active_notifications.items():
                for active_notification in notifications:
                    #print("update_status notification=" + str(active_notification.name) + " session=" + str(session), file=sys.stderr)
                    active_notification.apply()

        while True:
            try:
                notification = self.notifications_queue.get(timeout=4)
                print("handle_notifications: notification: " + notification.name, file=sys.stderr)
                notification.apply()
                update_status()
            except queue.Empty:
                # refresh all notifications (in case some other keyboard effect ruined them)
                update_status()

    def show_notification(self, session: str, notification_status: NotificationStatus):
        print("show_notification: status=" + notification_status.name + " session=" + session, file=sys.stderr)
        # let the thread handling notifications know that this notification is active
        self.active_notifications[session].add(notification_status)

        # check what notification status was registered, and add papropriate event to queue
        notification_event = None
        if notification_status == NotificationStatus.UNREAD_EMAIL:
            print("show_notification: new email")
            notification_event = NotificationEvent.NEW_EMAIL
        elif notification_status == NotificationStatus.UNREAD_IM:
            print("show_notification: new message")
            notification_event = NotificationEvent.NEW_MESSAGE

        if notification_event:
            # add event to queue. it will be depleted/animated from a different thread
            self.notifications_queue.put(notification_event)

    def hide_notification(self, session: str, notification_status: NotificationStatus):
        print("hide_notification: status=" + notification_status.name + " session=" + session, file=sys.stderr)
        # make sure that thread handling notifications is not trying to animate this notification anymore
        try:
            self.active_notifications[session].remove(notification_status)
            # clear the notification animation
            notification_status.clear()

            if len(self.active_notifications[session]) == 0:
                print("empty session=" + str(session) + ", remove it", file=sys.stderr)
                self.active_notifications.pop(session)

        except KeyError:
            print("dangling session=" + str(session) + ", remove it, active_notifications=" + str(self.active_notifications), file=sys.stderr)
            self.active_notifications.pop(session)
            pass

    def update(self, new_status: str):
        [command, session] = new_status.split('.')
        # check if session split ok, exit if not
        if not session:
            print(f"Invalid session: {new_status}", file=sys.stderr)
            return

        match command:
            case "#new_email":
                self.show_notification(session, NotificationStatus.UNREAD_EMAIL)
            case "#new_im":
                self.show_notification(session, NotificationStatus.UNREAD_IM)
            case "#no_email":
                self.hide_notification(session, NotificationStatus.UNREAD_EMAIL)
            case "#no_im":
                self.hide_notification(session, NotificationStatus.UNREAD_IM)
            case _:
                print(f"Unknown notification: {command}", file=sys.stderr)
                pass

class StatusManager:
    def __init__(self, openrgb_client: OpenRGBClient):
        self.openrgb_client = openrgb_client
        self.status = BoxStatus.IDLE
        self.status_queue = queue.Queue()
        self.status_thread = threading.Thread(target=self.handle_status)
        self.status_thread.start()

    def handle_status(self):
        while True:
            try:
                status = self.status_queue.get(timeout=5)
                print(f"Apply status {status.name}", file=sys.stderr)
                status.apply()
            except queue.Empty:
                pass

    def update(self, new_status: str):
        match new_status:
            case "@idle":
                self.status_queue.put(BoxStatus.IDLE)
            case "@busy":
                self.status_queue.put(BoxStatus.BUSY)
            case "@error":
                self.status_queue.put(BoxStatus.ERROR)
            case "@ok":
                self.status_queue.put(BoxStatus.OK)
            case _:
                print(f"Unknown status: {new_status}", file=sys.stderr)
                pass

notification_manager = NotificationManager(openrgb_client)
status_manager = StatusManager(openrgb_client)

class OpenRGBInteractiveServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    daemon_threads = True
    allow_reuse_address = True

class OpenRGBRequestHandler(socketserver.StreamRequestHandler):
    def handle(self):

        client = f'{self.client_address}'
        print(f'Connected: {client}', file=sys.stderr)
        while True:
            data = self.rfile.readline()
            if not data:
                break
            message = data.decode().strip()
            # choose between different type of messages (#blink, #off, #on, #color)
            if message.startswith("@"):
                print(f'status: {message}', file=sys.stderr)
                status_manager.update(message)
            elif message.startswith("#"):
                print(f'notification: {message}', file=sys.stderr)
                notification_manager.update(message)
            else:
                print(f'Unknown message: {message}')
                openrgb_client.send(f'{message}', file=sys.stderr)

        print(f'Closed: {client}', file=sys.stderr)

with OpenRGBInteractiveServer(('', 59898), OpenRGBRequestHandler) as server:
    effects.OpenRGBEffectBlank(openrgb_client).run()

    print(f'OpenRGB interactive server started on port {server.server_address[1]}', file=sys.stderr)
    server.serve_forever()
