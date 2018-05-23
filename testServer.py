import socket
import sys
import logging
from time import sleep
import cv2 as cv
import random

logging.basicConfig(level=logging.DEBUG)

TEST = "output"  # "input"
logging.info(" Server Mode: %s", TEST)
MSG_INTERVAL = 5#0.025

count = 0

try:
    print("testing CV")
    cam = cv.VideoCapture(0)
    cam.set(3, 320)
    cam.set(4, 240)
    get, frame = cam.read()
    encJPG = cv.imencode(".jpg", frame)[1]
    cam.release()
    cv.destroyAllWindows()
except cv.error:
    logging.critical(" CV error")

cam.release()

try:
    print("opening sockets")
    img = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    img.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    cmd = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    cmd.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
except socket.error:
    logging.error(" socket opening issue")
    exit

try:
    print("binding...")
    img.bind(('', 8888))
    cmd.bind(('', 8889))
except socket.error:
    logging.error(" socket binding issue")
    exit

logging.info(" Bind to localhost:8888")
logging.info(" Bind to localhost:8889")

try:
    print("set to listen")
    img.listen(5)
    cmd.listen(5)
    (conn, addr) = img.accept()
    (conn, addr) = cmd.accept()
except socket.error:
    logging.error(" server have problems listening to designated port")
    exit

logging.info(" opens server")

while True:
    try:
        if TEST == "output":
            # conn.send(encJPG.tostring())
            msg = "aaa" + str(random.randint(10, 99)) + "aaa" #"a" * 10
            conn.send(msg)
            logging.info(" %s msg sent: %s", str(count), msg)
            count += 1
            sleep(MSG_INTERVAL)

        elif TEST == "input":
            data = conn.recv(64)
            if not data:
                conn.close()
            cmd = ''
            for char in data:
                if char == '\n' or char == '\r':
                    break
                cmd += char

            if 'NCTUEEclass20htlu' in cmd:
                cmd = cmd.split(',')[1:]
                logging.info(" got cmd: %s, %s", str(cmd[0]), str(cmd[1]))
            else:
                logging.exception(" weird cmd, check the code")

    except socket.error():
        conn.close()
        logging.error(" socket error")
        exit
    except Exception:
        logging.warning(" other error: ERR: %s", sys.exc_info())
        conn.close()
        break


conn.close()
