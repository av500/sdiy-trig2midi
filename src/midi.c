#include "main.h"
#include "midi.h"
#include "uart.h"

/*
Korg Electribe ER-1 mapping: PS = Percussion Synth

PS1 (Bass Drum)		C2 	36
PS2 (Acoustic Snare)	D2 	38
PS3 (Electric Snare)	E2 	40
PS4 (Low Tom)		F2 	41
Audio In 1 		G2 	43
Audio In 2 		A2 	45
Hi-hat (Close) 		F#2 	42
Hi-hat (Open) 		A#2 	46
Crash 			C#3 	49
Handclap 		D#2 	39
*/

#define BASSD	36
#define ASNARE	38
#define ESNARE	40
#define LFTOM	41
#define CLHHAT	42
#define OPHHAT	46
#define CRASH	49
#define HCLAP	39

#define AUDIO1	43
#define AUDIO2	45

// Channel Voice Messages 
#define NOTE_OFF	0x80
#define NOTE_ON		0x90
#define KEY_PRESS	0xA0
#define CONTROL_CH	0xB0
#define PROGRAM_CH	0xC0
#define CHANNEL_PRESS	0xD0
#define PITCH_BEND	0xE0

static int notes[8]  = { 
	BASSD,
	ASNARE,
	ESNARE,
	LFTOM,
	CLHHAT,
	OPHHAT,
	CRASH,
	HCLAP,
};

static int channel = 9;		// default MIDI channel 10

#define USART_CLK_ENABLE()              __USART1_CLK_ENABLE();
#define USART_TX_GPIO_CLK_ENABLE()      __GPIOA_CLK_ENABLE()

#define USART_TX_PIN                    GPIO_PIN_9
#define USART_TX_PORT                   GPIOA
#define USART_TX_AF                     GPIO_AF1_USART1

static USART_HandleTypeDef huart;

void MIDI_init( void ) 
{
dbg("[MIDI] init\n");
#ifndef CONFIG_UART
	GPIO_InitTypeDef  GPIO_InitStruct;

	USART_TX_GPIO_CLK_ENABLE();

	GPIO_InitStruct.Pin	  = USART_TX_PIN;
	GPIO_InitStruct.Mode	  = GPIO_MODE_AF_PP;
	GPIO_InitStruct.Pull	  = GPIO_NOPULL;
	GPIO_InitStruct.Speed	  = GPIO_SPEED_HIGH;
	GPIO_InitStruct.Alternate = USART_TX_AF;

	HAL_GPIO_Init(USART_TX_PORT, &GPIO_InitStruct);

	USART_CLK_ENABLE(); 

	huart.Instance	      = USART1;
	huart.Init.BaudRate   = 31250;
	huart.Init.WordLength = USART_WORDLENGTH_8B;
	huart.Init.StopBits   = USART_STOPBITS_1;
	huart.Init.Parity     = USART_PARITY_NONE;
	huart.Init.Mode	      = USART_MODE_TX;
	  
	int ret;
	if((ret = HAL_USART_Init(&huart)) != HAL_OK) {
		return;
	}
	return;
#endif
}

static void send_byte( uint8_t c)
{
    while(__HAL_USART_GET_FLAG(&huart, USART_FLAG_TXE) == RESET) {
    	// wait
    }
    huart.Instance->TDR = c;
}

void MIDI_message(int command, int note, int velocity) 
{
	send_byte(command | (channel & 0x0F ));
	send_byte(note     & 0x7F);
	send_byte(velocity & 0x7F);
}

void MIDI_send( int num, int on )
{
#ifdef CONFIG_UART
//dbg("[MIDI] note %2d %s\n", notes[num], on ? "ON" : "off" );
#else
	if( on ) {
		MIDI_message(NOTE_ON, notes[num], 127);
	} else {
		MIDI_message(NOTE_OFF, notes[num], 0);
	}
#endif
}
