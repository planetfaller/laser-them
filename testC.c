#include <bcm2835.h>
#include <stdio.h>
#include <sched.h>



int main(int argc, char **argv) {
 const struct sched_param priority = {1};
 sched_setscheduler(0, SCHED_FIFO, &priority);
  mlockall();


 if (!bcm2835_init())
   return 1;
 bcm2835_gpio_fsel(RPI_GPIO_P1_07 ,
 BCM2835_GPIO_FSEL_OUTP);


 
 while (1) {
  bcm2835_gpio_write(RPI_GPIO_P1_07 , HIGH);
  delay(1);
  bcm2835_gpio_write(RPI_GPIO_P1_07 , LOW);
  delay(1);
 }
 bcm2835_close();
 return 0;
}
