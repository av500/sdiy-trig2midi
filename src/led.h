#ifndef _LED_H_
#define _LED_H_

#define LED_NUM 4

#define LED_0	0
#define LED_1	1
#define LED_2	2
#define LED_3	3

void LED_init  ( void ); 
void LED_on    ( unsigned int led );
void LED_off   ( unsigned int led );
void LED_set   ( unsigned int led, int on );
void LED_toggle( unsigned int led );

#endif 

