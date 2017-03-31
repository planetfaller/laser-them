import datetime
import time


while 1:
    firstTime = datetime.datetime.now()
    time.sleep(1)
    secondTime = datetime.datetime.now()
    TimeDifference = ((secondTime - firstTime))
    TimeDifference = float(TimeDifference.total_seconds() * 1000)

    print (TimeDifference)


