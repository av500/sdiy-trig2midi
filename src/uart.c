#include "main.h"
#include "uart.h"

#ifdef CONFIG_UART

static USART_HandleTypeDef huart;

void UART_putc( unsigned char c)
{
    while(__HAL_USART_GET_FLAG(&huart, USART_FLAG_TXE) == RESET) {
    	// wait
    }
    huart.Instance->TDR = c;
}

#define USART_CLK_ENABLE()              __USART1_CLK_ENABLE();
#define USART_TX_GPIO_CLK_ENABLE()      __GPIOA_CLK_ENABLE()

#define USART_TX_PIN                    GPIO_PIN_9
#define USART_TX_PORT                   GPIOA
#define USART_TX_AF                     GPIO_AF1_USART1

int UART_init()
{
	GPIO_InitTypeDef  GPIO_InitStruct;

	/* Enable GPIO TX/RX clock */
	USART_TX_GPIO_CLK_ENABLE();

	/* UART TX GPIO pin configuration  */
	GPIO_InitStruct.Pin	  = USART_TX_PIN;
	GPIO_InitStruct.Mode	  = GPIO_MODE_AF_PP;
	GPIO_InitStruct.Pull	  = GPIO_NOPULL;
	GPIO_InitStruct.Speed	  = GPIO_SPEED_HIGH;
	GPIO_InitStruct.Alternate = USART_TX_AF;

	HAL_GPIO_Init(USART_TX_PORT, &GPIO_InitStruct);

	USART_CLK_ENABLE(); 

	huart.Instance	      = USART1;
	huart.Init.BaudRate   = DEBUG_BAUDRATE;
	huart.Init.WordLength = USART_WORDLENGTH_8B;
	huart.Init.StopBits   = USART_STOPBITS_1;
	huart.Init.Parity     = USART_PARITY_NONE;
	huart.Init.Mode	      = USART_MODE_TX;
	  
	int ret;
	if((ret = HAL_USART_Init(&huart)) != HAL_OK) {
		return ret;
	}
	return HAL_OK;
}
#endif
