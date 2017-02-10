#include "main.h"
#include "led.h"
#include "uart.h"

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static uint16_t pins[LED_NUM]  = { 
	GPIO_PIN_0, 
	GPIO_PIN_1, 
	GPIO_PIN_4, 
	GPIO_PIN_1, 
};

static GPIO_TypeDef *ports[LED_NUM] = { 
	GPIOF, 
	GPIOF, 
	GPIOA, 
	GPIOB, 
};

void LED_on( unsigned int led )
{
	if( led >= LED_NUM ) {
		return;
	}
	HAL_GPIO_WritePin(ports[led], pins[led], GPIO_PIN_RESET);
}

void LED_off( unsigned int led ) 
{
	if( led >= LED_NUM ) {
		return;
	}
	HAL_GPIO_WritePin(ports[led], pins[led], GPIO_PIN_SET);
}

void LED_set( unsigned int led, int on )
{
	if( led >= LED_NUM ) {
		return;
	}
	HAL_GPIO_WritePin(ports[led], pins[led], on ? GPIO_PIN_RESET : GPIO_PIN_SET);
}

void LED_toggle( unsigned int led ) 
{
	if( led >= LED_NUM ) {
		return;
	}
	HAL_GPIO_TogglePin(ports[led], pins[led]);
}

void LED_init(void)
{
dbg("[LED ] init\n");
	GPIO_InitTypeDef GPIO_InitStruct;

	__GPIOA_CLK_ENABLE();
	__GPIOB_CLK_ENABLE();
	__GPIOF_CLK_ENABLE();

	int i;
	for( i = 0; i < LED_NUM; i++ ) {
		GPIO_InitStruct.Pin   = pins[i];
		GPIO_InitStruct.Mode  = GPIO_MODE_OUTPUT_PP;
		GPIO_InitStruct.Pull  = GPIO_NOPULL;
		GPIO_InitStruct.Speed = GPIO_SPEED_HIGH;

		HAL_GPIO_Init( ports[i], &GPIO_InitStruct );
		LED_off( i );
	}
}

