

/*
LOW	Triggers interrupt whenever the pin is LOW
HIGH	Triggers interrupt whenever the pin is HIGH
CHANGE	Triggers interrupt whenever the pin changes value, from HIGH to LOW or LOW to HIGH
FALLING	Triggers interrupt when the pin goes from HIGH to LOW
RISING	Triggers interrupt when the pin goes from LOW to HIGH
*/


#define LOW     1
#define HIGH    2
#define CHANGE  3
#define FALLING 4
#define RISING  5


void attachInterrupt(int port, int bit, void(*ISR)(ULONGLONG lastTime), int Mode);
void detachInterrupt(int port, int bit, int Mode);
