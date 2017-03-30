import matplotlib.pyplot as plt
import time


plt.ion()
fig = plt.figure()

plt.axis()

i = 0
x = list()
y = list()

while i < 10:
    start = time.clock()
    time.sleep(0.00001)
    end = time.clock()
    temp_y = (end - start)
    x.append(i)
    y.append(temp_y)
    plt.scatter(i, temp_y)
    i += 1
    plt.show()
    plt.pause(0.0001)
    print(temp_y)
    time.sleep(1)

plt.show(block=True)