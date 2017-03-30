import RPi.GPIO as GPIO
import time


GPIO.setmode(GPIO.BCM)
GPIO.setup(23, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
lastTime = 0
countTime = 0

raw_input("Press Enter when ready\n>")

print ("Waiting for rising edge on port 23")


while GPIO.wait_for_edge(23, GPIO.RISING):
    lastTime = countTime
    countTime = int(time.time() * 1000)
    TimeDifference = (countTime - lastTime)
    print ((TimeDifference))
