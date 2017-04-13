# encoding=utf8

import time
import serial

degreeList = []
distanceList = []

count = 0

ser = serial.Serial(port='/dev/serial0', baudrate=115200,
)        # enable the serial port
while 1:                              # execute the loop forever

    if (count > 9):
        count == 0

    if (ser.inWaiting() > 0):           # read the serial data sent by the UNO
        ch = ser.read(2)
        if (count & 1 == 1):
            distanceList.append(int(ch.encode('hex'), 16))
            print "---------------------- DistanceList ----------------------"
            print distanceList
            count += 1

        elif (count & 1 == 0):
            if ((int(ch.encode('hex'), 16)) in (0, 1)):
                del degreeList[:]
                del distanceList[:]
            degreeList.append(int(ch.encode('hex'), 16))
            print "---------------------- DegreeList ----------------------"
            print degreeList
            count += 1
