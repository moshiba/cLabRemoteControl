import cv2 as cv
import numpy as np
from time import sleep

MULTI = 1

cam = cv.VideoCapture(0)
cam.set(3, 320*MULTI)
cam.set(4, 240*MULTI)
count = 0
maxi = 0
while True:
    get, frame = cam.read()
    encJPG = cv.imencode(".jpg", frame)[1]
    #print("YOYO",encJPG.__str__())
    print(len(encJPG))
    # len(encJPG) == len(encJPG.tostring())
    decJPG = cv.imdecode(encJPG, 1)
    #print(decJPG.tostring())
    serilMtx = np.append(encJPG[0], encJPG[1:])
    #print(np.array_str(serilMtx))

    NEWdecJPG = cv.imdecode(serilMtx, 1)
    cv.imshow("facetime", NEWdecJPG)
    sleep(0.05)
    if cv.waitKey(1) & 0xFF == ord('q'):
        break

cam.release()
cv.destroyAllWindows()
