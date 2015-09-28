8 channel trigger to MIDI converter module in Eurorack format

	copyright Vladimir Pantelic (av500) / 2015, see LICENSE

based on an STM32F030F4P6 module from 39board in China, available e.g. at Aliexpress:

	http://www.aliexpress.com/store/group/39-board-Development-Board/1305771_260227473.html

See https://www.muffwiggler.com/forum/viewtopic.php?t=146538 for description and discussion


To compile and rund this code you need the following:

1) Toolchain

Download and unzip the toolchain at: 
	
	https://launchpad.net/gcc-arm-embedded/+download
	
Add the PATH to the compile to your PATH variable, e.g.

	export PATH=$PATH:/opt/gcc-arm-none-eabi-4_9-2014q4/arm-none-eabi/bin/
	
	
2) STM32CubeF0

This project uses the HAL library for the STM32F0 series, download the package from:

	http://www.st.com/web/en/catalog/tools/PF260612

Unpack STM32CubeF0 and edit the CUBEPATH variable at the top of the Makefile:

	CUBEPATH = ../STM32Cube_FW_F0_V1.4.0/Drivers/
	
	
3) OpenOCD

To flash the SW to the CPU/module you need to install openOCD and make sure it's in the PATH. you need an STLINK or compatible SWD debugger, edit stm32f0.cfg to switch from v2.1 to v.2. For some reason SWD with the 030 series seems to work much better when using the reset line, so you need to connect that one as well besides SWCLK and SWDIO


4) Building
	
To build, simply type

	make
	
which will build the project in the build_tiny/ folder

To program the board, use

	make p (or make program)
	
For a debug build that uses the UART to output debug logs instead of MIDI data, uncomment

	#CDEFS    += -DDEBUG

in the Makefile

You can also build the project for the STM32F0-Discovery board, in that case prepend TARGET=disco to the make calls 

	TARGET=disco make (or edit the Makefile)
	
and edit stm32f0.cfg to use STLINK v2 instead of v2.1


have fun!
