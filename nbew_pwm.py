import time
import wiringpi


wiringpi.wiringPiSetupGpio()

wiringpi.pinMode(18, wiringpi.GPIO.PWM_OUTPUT)

wiringpi.pwmSetMode(wiringpi.GPIO.PWM_MODE_MS)

wiringpi.pwmSetClock(192)
wiringpi.pwmSetRange(200)

delay_period = 0.01

time.sleep(1)
wiringpi.pwmWrite(18, 0)
time.sleep(1)
wiringpi.pwmWrite(18, 100)
time.sleep(1)
wiringpi.pwmWrite(18, 0)
time.sleep(1)
pwmDuty = 100

#for i in range(0,10000):
while 1:
    wiringpi.pwmWrite(18, pwmDuty)
    pwmDuty = int(raw_input('Set pwm 100-200: '))
    time.sleep(delay_period)
#    time.sleep(delay_period)

#wiringpi.pwmWrite(18,0)
