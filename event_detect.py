import RPi.GPIO as GPIO
import math
import datetime
import time


GPIO.setmode(GPIO.BCM)
GPIO.setup(23, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
lastTime = datetime.datetime.now()
countTime = datetime.datetime.now()


raw_input("Press Enter when ready\n>")

print ("Waiting for rising edge on GPIO-port 23")

lastTime = datetime.datetime.now()


def handle(pin):
    global countTime
    lastTime = countTime
    countTime = datetime.datetime.now()
    TimeDifference = ((countTime - lastTime))
    TimeDifference = float(TimeDifference.total_seconds() * 1000)
    Hertz = float(1 / (TimeDifference / 1000))
    print "Hertz: ", Hertz
    radS = Hertz * math.pi * 2
    print "Rad/s: ", radS
    RPM = ((radS * 60) / (2 * math.pi))
    print "RPM: ", RPM
    print "Time Difference: ", TimeDifference, "\n"


GPIO.add_event_detect(23, GPIO.RISING, callback=handle)

while 1:
    time.sleep(1)

