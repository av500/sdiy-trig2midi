#include "main.h"
#include "gate.h"
#include "uart.h"

static uint16_t pins[GATE_NUM]  = { 
	GPIO_PIN_3, 	// G1
	GPIO_PIN_2, 	// G2
	GPIO_PIN_1, 	// G3
	GPIO_PIN_0, 	// G4
	GPIO_PIN_10, 	// G5
	GPIO_PIN_7, 	// G6
	GPIO_PIN_6, 	// G7
	GPIO_PIN_5, 	// G8
};

static GPIO_TypeDef* ports[GATE_NUM] = { 
	GPIOA, 
	GPIOA, 
	GPIOA, 
	GPIOA, 
	GPIOA, 
	GPIOA, 
	GPIOA, 
	GPIOA, 
};

static int state[GATE_NUM] = { 
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
};

void GATE_init( void ) 
{
dbg("[GATE] init\n");
	GPIO_InitTypeDef GPIO_InitStruct;

	__GPIOA_CLK_ENABLE();

	int i;
	for( i = 0; i < GATE_NUM; i++ ) {
		GPIO_InitStruct.Pin   = pins[i];
		GPIO_InitStruct.Mode  = GPIO_MODE_INPUT;
		GPIO_InitStruct.Pull  = GPIO_NOPULL;
		GPIO_InitStruct.Speed = GPIO_SPEED_HIGH;

		HAL_GPIO_Init( ports[i], &GPIO_InitStruct );
	}
}

int GATE_read( int num, int *on ) 
{
	int g = HAL_GPIO_ReadPin(ports[num], pins[num]);
	*on = g ? 0 : 1;
	if( g != state[num] ) {
		state[num] = g;
		return 1;
	}
	return 0;
}
