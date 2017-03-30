import time
import wiringpi


wiringpi.wiringPiSetupGpio()

wiringpi.pinMode(18, wiringpi.GPIO.PWM_OUTPUT)

wiringpi.pwmSetMode(wiringpi.GPIO.PWM_MODE_MS)

wiringpi.pwmSetClock(192)
wiringpi.pwmSetRange(200)

delay_period = 1

wiringpi.pwmWrite(18, 0)
time.sleep(delay_period)
