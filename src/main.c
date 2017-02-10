#include "main.h"
#include "led.h"
#include "gate.h"
#include "uart.h"
#include "midi.h"

#include <stdlib.h>

void Error_Handler( void )
{
	while ( 1 );
}

// we must use the internal oscillator as we need the F0/F1 pins as GPIOs
#define CONFIG_HSI

#ifdef CONFIG_HSI
void SystemClock_Config(void)
{
	RCC_OscInitTypeDef RCC_OscInitStruct;
	RCC_ClkInitTypeDef RCC_ClkInitStruct;

	RCC_OscInitStruct.OscillatorType        = RCC_OSCILLATORTYPE_HSI|RCC_OSCILLATORTYPE_HSI14;
	RCC_OscInitStruct.HSIState              = RCC_HSI_ON;
	RCC_OscInitStruct.HSI14State            = RCC_HSI14_ON;
	RCC_OscInitStruct.HSICalibrationValue   = 16;
	RCC_OscInitStruct.HSI14CalibrationValue = 16;
	RCC_OscInitStruct.PLL.PLLState          = RCC_PLL_ON;
	RCC_OscInitStruct.PLL.PLLSource         = RCC_PLLSOURCE_HSI;
	RCC_OscInitStruct.PLL.PLLMUL            = RCC_PLL_MUL12;
	RCC_OscInitStruct.PLL.PREDIV            = RCC_PREDIV_DIV1;
	HAL_RCC_OscConfig(&RCC_OscInitStruct);

	RCC_ClkInitStruct.ClockType             = RCC_CLOCKTYPE_SYSCLK;
	RCC_ClkInitStruct.SYSCLKSource          = RCC_SYSCLKSOURCE_PLLCLK;
	RCC_ClkInitStruct.AHBCLKDivider         = RCC_SYSCLK_DIV1;
	RCC_ClkInitStruct.APB1CLKDivider        = RCC_HCLK_DIV1;
	HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_1);

	RCC_PeriphCLKInitTypeDef PeriphClkInit;
	PeriphClkInit.PeriphClockSelection = RCC_PERIPHCLK_USART1;
	PeriphClkInit.Usart1ClockSelection = RCC_USART1CLKSOURCE_PCLK1;
	HAL_RCCEx_PeriphCLKConfig(&PeriphClkInit);

	__SYSCFG_CLK_ENABLE();

}
#else
static void SystemClock_Config( void )
{
	RCC_ClkInitTypeDef RCC_ClkInitStruct;
	RCC_OscInitTypeDef RCC_OscInitStruct;

	/* Enable HSE Oscillator and Activate PLL with HSE as source */
	RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
	RCC_OscInitStruct.HSEState       = RCC_HSE_ON;
	RCC_OscInitStruct.PLL.PLLState   = RCC_PLL_ON;
	RCC_OscInitStruct.PLL.PLLSource  = RCC_PLLSOURCE_HSE;
	RCC_OscInitStruct.PLL.PREDIV     = RCC_PREDIV_DIV1;
	RCC_OscInitStruct.PLL.PLLMUL     = RCC_PLL_MUL6;
	if ( HAL_RCC_OscConfig( &RCC_OscInitStruct ) != HAL_OK ) {
		Error_Handler(  );
	}

	/* Select PLL as system clock source and configure the HCLK and PCLK1 clocks dividers */
	RCC_ClkInitStruct.ClockType      = ( RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_PCLK1 );
	RCC_ClkInitStruct.SYSCLKSource   = RCC_SYSCLKSOURCE_PLLCLK;
	RCC_ClkInitStruct.AHBCLKDivider  = RCC_SYSCLK_DIV1;
	RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
	if ( HAL_RCC_ClockConfig( &RCC_ClkInitStruct, FLASH_LATENCY_1 ) != HAL_OK ) {
		Error_Handler(  );
	}
}
#endif

static void button_init( void )
{
	__GPIOA_CLK_ENABLE();

	// put pin to input
	GPIO_InitTypeDef GPIO_InitStruct;

	GPIO_InitStruct.Pin   = GPIO_PIN_13 | GPIO_PIN_14;
	GPIO_InitStruct.Mode  = GPIO_MODE_INPUT;
	GPIO_InitStruct.Pull  = GPIO_PULLUP;
	GPIO_InitStruct.Speed = GPIO_SPEED_HIGH;

	HAL_GPIO_Init( GPIOA, &GPIO_InitStruct );
}

static int debounce_count = 0;
static int debounce_pin   = -1;
#define DEBOUNCE_COUNT 5

static int check_button( int *on )
{
	// todo: button DOWN at PA14
	int pin = HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_13);

	if( pin == debounce_pin ) {
		debounce_count ++;
		if( debounce_count == DEBOUNCE_COUNT ) {
			static int last;
			if( pin != last ) {
				last = pin;
				*on = pin;
				return 1;
			}
		}	
	} else {
		debounce_pin = pin;
		debounce_count = 0;
	}
	return 0;
}

int main( void )
{
	HAL_Init();

	SystemClock_Config();

	UART_init();

dbg("\n\n[trig2midi]\n");
	GATE_init();

	LED_init();
	
	MIDI_init();

	button_init();

	while ( 1 ) {
		static int last;
		int now = 0;
		int i;
		for( i = 0; i < GATE_NUM; i++ ) {
			int on;
			if( GATE_read( i, &on ) ) {
				// we control LEDs 4-7
				if( i >= 4 ) {
					LED_set( i - 4, on );
				}
				MIDI_send(i, on );
			}
			now = (now << 1) | on;
		}
		if( now != last ) {
dbg("[%02X]\n", now);
			last = now;
		}
		int on;
		if( check_button( &on ) ) {
dbg("\t(%d)\n", on);
			// button handling not implemented yet
		}
	}
}
