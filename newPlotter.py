# encoding=utf8

import time
import serial
import math
import numpy
import matplotlib.pyplot as plt

degreeList = []
distanceList = []

count = 0

ser = serial.Serial(port='/dev/serial0', baudrate=115200,
)  # enable the serial port

fig = plt.figure()
ax = fig.add_subplot(1, 1, 1, aspect='equal', projection='polar')
ax.hold(True)
plt.ioff()

 #  Display the measurments using matplotlib, using blit for speed
def plotThat(doblit=True):

    y = distanceList
    x = degreeList

    plt.show(False)

    ax.relim()
    ax.autoscale_view()
    ax.set_rmax(500)  # Fix this later

    plt.cla()  # Clear the plot
    #plt.draw()  # Draw

    if doblit:
        # cache the background
        background = fig.canvas.copy_from_bbox(ax.bbox)

    points = ax.plot(x, y, 'o')[0]

    # update the xy data
    points.set_data(x, y)

    if doblit:
        # restore background
        fig.canvas.restore_region(background)
        # redraw just the points
        ax.draw_artist(points)
        # fill in the axes rectangle
        fig.canvas.blit(ax.bbox)
    else:
        # redraw everything
        fig.canvas.draw()


# Gather Data
while 1:  # execute the loop forever

#    if (count > 9):
#        count == 0

    if (ser.inWaiting() > 0):           # read the serial data sent by the UNO
        ch = ser.read(2)
        if (count & 1 == 1):
            distanceList.append(int(ch.encode('hex'), 16))
            #print "---------------------- DistanceList ----------------------"
            #print distanceList
            count += 1

        elif (count & 1 == 0):
            if ((int(ch.encode('hex'), 16)) == 1): # if we wanna check for 0, 1 for example
                plotThat(doblit=True)  # Run plotfunction
                del degreeList[:]  # Clear lists
                del distanceList[:]

            degreeList.append((-1 * math.pi * int(ch.encode('hex'), 16))
            / (180.0))  # Convert degrees to radians
            #print "---------------------- RadianList ----------------------"
            #print degreeList
            count += 1
    time.sleep(0.001)
