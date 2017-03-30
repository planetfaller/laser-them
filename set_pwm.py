import wiringpi


def reset_pins(io):
    pins = [0, 1, 2, 3, 4, 5, 6, 7, ]
    for pin in pins:
        io.pinMode(pin, io.OUTPUT)
        io.digitalWrite(pin, io.LOW)


def pwm_dimm(io):
    pin = 1
    io.pinMode(pin, io.PWM_OUTPUT)

    while 1:
        io.pwmWrite(pin, 100)


# direct
#io = wiringpi.GPIO(wiringpi.GPIO.WPI_MODE_SYS)
io = wiringpi.GPIO(wiringpi.GPIO.WPI_MODE_PINS)

try:
    reset_pins(io)
    pwm_dimm(io)

except (KeyboardInterrupt, SystemExit):
    reset_pins(io)