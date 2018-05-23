import socket
import cv2 as cv
from time import sleep

count = 0

cam = cv.VideoCapture(0)
cam.set(3, 320)
cam.set(4, 240)
get, frame = cam.read()
encJPG = cv.imencode(".jpg", frame)[1]
cam.release()
cv.destroyAllWindows()
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

TEST = "output"  # "input"
MSG_INTERVAL = 0.025

if TEST == "output":
    s.bind(('', 8888))
elif TEST == "input":
    s.bind(('', 8889))

print("bind to localhost:8888")
s.listen(5)
(conn, addr) = s.accept()
print("opens server")

while True:
    try:
        if TEST == "output":
            #conn.send(encJPG.tostring())
            conn.send("a" * 10)
            print(str(count) + " msg sent")
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
                print("got cmd:" + str(cmd[0]) + str(cmd[1]))
            else:
                print("weird cmd, chk le code")

    except socket.error():
        conn.close()
        break
    except:
        print("other error")
        break
conn.close()
