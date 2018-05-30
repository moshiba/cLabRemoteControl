#!/usr/bin/env python
"""@package docstring

This module is the server for MaRe.

Example:
    To run the WiFi Remote Car server, use the following command:

        $ python server.py

Author:
    Gary Huang<gh.nctu+code@gmail.com>

License:
    3-clause BSD License

"""

import RPi.GPIO as GPIO
import threading
import select
import socket
import time
import sys


class myCar:

    pwm_frequency = 200

    def __init__(self, right1, right2, left1, left2):
        GPIO.setmode(GPIO.BOARD)
        # pinMode
        GPIO.setup(right1, GPIO.OUT)
        GPIO.setup(right2, GPIO.OUT)
        GPIO.setup(left1, GPIO.OUT)
        GPIO.setup(left2, GPIO.OUT)
        # pwm output settings
        self.right1_pwm = GPIO.PWM(right1, self.pwm_frequency)
        self.right1_pwm.start(0.0)
        self.left1_pwm = GPIO.PWM(left1, self.pwm_frequency)
        self.left1_pwm.start(0.0)
        self.right2 = right2
        self.left2 = left2
        GPIO.output(self.right2, False)
        GPIO.output(self.left2, False)

    def rightWheel(self, value):
        if value >= 0:
            self.right1_pwm.ChangeDutyCycle(value)
            GPIO.output(self.right2, False)
        else:
            self.right1_pwm.ChangeDutyCycle(100.0 + value)
            GPIO.output(self.right2, True)

    def leftWheel(self, value):
        if value >= 0:
            self.left1_pwm.ChangeDutyCycle(value)
            GPIO.output(self.left2, False)
        else:
            self.left1_pwm.ChangeDutyCycle(100.0 + value)
            GPIO.output(self.left2, True)

    def __del__(self):
        self.left1_pwm.stop()
        self.right1_pwm.stop()


# Use BOARD numbering system
car = myCar(12, 11, 32, 31)


class Server:

    host = ''
    port_stream = 8888
    port_control = 8889

    def __init__(self):
        self.socket_stream = None
        self.socket_control = None
        self.threads = []

    def open_socket(self):
        try:
            # Image stream
            self.socket_stream = socket.socket(socket.AF_INET,
                                               socket.SOCK_STREAM)
            self.socket_stream.setsockopt(socket.SOL_SOCKET,
                                          socket.SO_REUSEADDR, 1)
            self.socket_stream.bind((self.host, self.port_stream))
            self.socket_stream.listen(5)

            # Control cmd stream
            self.socket_control = socket.socket(socket.AF_INET,
                                                socket.SOCK_STREAM)
            self.socket_control.setsockopt(socket.SOL_SOCKET,
                                           socket.SO_REUSEADDR, 1)
            self.socket_control.bind((self.host, self.port_control))
            self.socket_control.listen(5)
            print("[INFO] Server is listening on " + str(self.port_stream) +
                  " and " + str(self.port_control))
        except socket.error:
            if self.socket_control:
                self.socket_control.close()
                self.socket_stream.close()
            print("[ERROR] Could not open socket")
            sys.exit(1)

    def run(self):
        self.open_socket()
        try:
            input = [self.socket_stream, self.socket_control, sys.stdin]
            running = 1
            while running:
                input_ready, output_ready, except_ready = select.select(
                    input, [], [])

                for ss in input_ready:
                    if ss == self.socket_stream:
                        streamAcpt = self.socket_stream.accept()
                        cc = StreamClient(streamAcpt[0], streamAcpt[1])
                        cc.start()
                        self.threads.append(cc)

                    elif ss == self.socket_control:
                        ctrlAcpt = self.socket_control.accept()
                        cc = ControlClient(ctrlAcpt[0], ctrlAcpt[1])
                        cc.start()
                        self.threads.append(cc)

                    elif ss == sys.stdin:
                        cmd = sys.stdin.readline().strip()
                        if cmd == 'show':
                            # ss = ShowFrame()
                            ss.start()
                            self.threads.append(s)
                        elif cmd == 'quit':
                            running = 0
                        elif cmd == '':
                            pass
                        else:
                            print('Command not found: ' + cmd)

        except KeyboardInterrupt:
            pass

        self.socket_stream.shutdown(socket.SHUT_WR)
        self.socket_control.shutdown(socket.SHUT_WR)
        self.socket_stream.close()
        self.socket_control.close()

        for tt in self.threads:
            tt.running = 0
        while len(self.threads) > 0:
            self.threads = [
                t.join(1) for t in self.threads
                if t is not None and t.isAlive()
            ]

        print('Thank you')
        print('If it hangs here, please press Ctrl+\\ to quit')


"""
class ShowFrame(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.running = 1

    def run(self):
        while self.running:
            camera_lock.acquire()
            # grabbed, frame = camera.read()
            camera_lock.release()
            # cv2.imshow("Monitor", frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
            time.sleep(0.1)
        cv2.destroyWindow("Monitor")
"""


class StreamClient(threading.Thread):
    def __init__(self, client, address):
        threading.Thread.__init__(self)
        self.client = client
        self.address = address
        self.running = 1
        print("connected to " + str(self.address))

    def run(self):
        print("tried to run module StreamClient")


class ControlClient(threading.Thread):
    def __init__(self, client, address):
        threading.Thread.__init__(self)
        self.client = client
        self.address = address
        self.running = 1
        self.lock = threading.Lock()
        print("connected to " + str(self.address))

    def run(self):
        try:
            while self.running:
                self.lock.acquire()
                car.rightWheel(0.0)
                car.leftWheel(0.0)
                self.lock.release()

                data = self.client.recv(64)
                if not data:
                    self.client.close()
                    self.running = 0

                cmd = ''
                for char in data:
                    if char == '\n' or char == '\r':
                        break
                    cmd += str(char)

                # pre = ''
                self.lock.acquire()
                if 'NCTUEEclass20htlu' in cmd:
                    cmd = cmd.split(',')[1:]
                    car.rightWheel(float(cmd[0]))
                    car.leftWheel(float(cmd[1]))
                    print("got cmd:" + str(cmd[0]) + str(cmd[1]))
                    time.sleep(0.1)
                else:
                    # pre = 'unknown '
                    pass
                self.lock.release()

        except socket.error as e:
            print("error", e)
            pass
        self.client.close()
        print("connection to " + self.address + "closed")


if __name__ == '__main__':
    s = Server()
    s.run()

GPIO.cleanup()
