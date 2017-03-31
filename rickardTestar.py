#!/usr/bin/python

# interrupt-based GPIO example using LEDs and pushbuttons

import RPi.GPIO as GPIO
import time
import threading

GPIO.setmode(GPIO.BCM)
	
GPIO.setwarnings(False) # because I'm using the pins for other things too!
GPIO.setup(23, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

def handle(pin):
	# light corresponding LED when pushbutton of same color is pressed
	print time.time() 

GPIO.add_event_detect(23, GPIO.RISING, handle)

# TODO: pause?
while True:
	time.sleep(1e6)
