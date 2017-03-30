import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BOARD)
GPIO.setup(11, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

timeList = list()
valueList = list()

for i in range(0, 100, 1):
    start = time.clock()
    valueList.append(GPIO.input(11))
    end = time.clock()
    timeList.append(end - start)

for i in range(0, 100, 1):
    print((timeList[i]))
    print((valueList[i]))
