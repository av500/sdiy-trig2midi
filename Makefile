ifeq (1,$(VERBOSE))
quiet =
else
quiet = quiet_
endif

-include local.mk

CUBEPATH = ../STM32Cube_FW_F0_V1.7.0/Drivers/
#CDEFS    += -DDEBUG
CDEFS    += -DDEBUG_BAUDRATE=115200

TARGET ?= lite

TCHAIN_PREFIX = arm-none-eabi-
REMOVE_CMD = rm

USE_THUMB_MODE = YES

ifeq ($(TARGET),lite)
MCU       = cortex-m0
CHIP      = STM32F030F4
BOARD     = F030_LITE

CDEFS    += -DSTM32F030x6
CDEFS    += -DUSE_HAL_DRIVER 
CDEFS    += -DHSE_VALUE=8000000UL
CDEFS    += -DARM_MATH_CM0

TGT_ASRC = gcc/startup_stm32f030x6.s
TGT_LD   = gcc/$(CHIP)_FLASH.ld
OOCD_TGT = stm32f0.cfg
endif

ifeq ($(TARGET),disco)
MCU       = cortex-m0
CHIP      = STM32F030R8
BOARD     = F030_DISCO

CDEFS    += -DSTM32F030x8
CDEFS    += -DUSE_HAL_DRIVER 
CDEFS    += -DHSE_VALUE=8000000UL
CDEFS    += -DARM_MATH_CM0

TGT_ASRC = gcc/startup_stm32f030x8.s
TGT_LD   = gcc/$(CHIP)_FLASH.ld
OOCD_TGT = stm32f0.cfg
endif

RUN_MODE=FLASH_RUN
#RUN_MODE=RAM_RUN

VECTOR_TABLE_LOCATION=VECT_TAB_FLASH
#VECTOR_TABLE_LOCATION=VECT_TAB_RAM

OUTDIR = build_$(TARGET)

# List C source files here
SRC += src/led.c
SRC += src/gate.c
SRC += src/main.c
SRC += src/midi.c
SRC += src/stm32f0xx_it.c
SRC += src/system_stm32f0xx.c
SRC += src/uart.c
SRC += src/xprintf.c

#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_hcd.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_ll_usb.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_spi.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_i2c.c
SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_adc.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_adc_ex.c
SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_cortex.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_dma.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_flash.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_flash_ex.c
SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_rcc.c
SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_rcc_ex.c
SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_gpio.c
SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_usart.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_tim.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_tim_ex.c
#SRC += $(CUBEPATH)/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_i2s.c

# List C source files here which must be compiled in ARM-Mode (no -mthumb).
SRCARM = 

# List Assembler source files here.
ASRC = $(TGT_ASRC)

# List Assembler source files here which must be assembled in ARM-Mode.
ASRCARM  = 

# Place project-specific -D and/or -U options for 
# Assembler with preprocessor here.
ADEFS = 

# List any extra directories to look for include files here.

EXTRAINCDIRS += src
EXTRAINCDIRS += $(CUBEPATH)/STM32F0xx_HAL_Driver/Inc
EXTRAINCDIRS += $(CUBEPATH)/CMSIS/Device/ST/STM32F0xx/Include
EXTRAINCDIRS += $(CUBEPATH)/CMSIS/Include

# List non-source files which should trigger build here
BUILDONCHANGE = Makefile $(TGT_LD)

# List any extra directories to look for library files here.
EXTRA_LIBDIRS =

OPT = 3

# Debugging format.
#DEBUG = stabs
#DEBUG = dwarf-2
DEBUG = gdb

# Compiler flag to set the C Standard level.
CSTANDARD = -std=gnu99

# Flash programming tool
FLASH_TOOL = OPENOCD

# Some warnings can be disabled by this setting 
DISABLESPECIALWARNINGS = no

# ---------------------------------------------------------------------------
# Options for OpenOCD flash-programming
# see openocd.pdf/openocd.texi for further information
#
OOCD_LOADFILE+=$(OUTDIR)/$(TARGET).elf
# if OpenOCD is in the $PATH just set OPENOCDEXE=openocd
OOCD_EXE=openocd
# debug level
OOCD_CL=-d0
#OOCD_CL=-d3
# interface and board/target settings (using the OOCD target-library here)
OOCD_CL+=-f $(OOCD_TGT) 
# initialize
OOCD_CL+=-c init
# if no SRST available:
## why unknown - it's documented... OOCD_CL+=-c "cortex_m3 reset_config sysresetreq"
# commands to prepare flash-write
OOCD_CL+= -c "reset halt"
# show the targets
OOCD_CL+=-c targets
# increase JTAG frequency a little bit - can be disabled for tests
#OOCD_CL+= -c "adapter_khz 1000"
# disable polling (optional)
OOCD_CL+= -c "poll off"
# flash-write and -verify
OOCD_CL+=-c "flash write_image erase $(OOCD_LOADFILE)" -c "verify_image $(OOCD_LOADFILE)"
# AIRCR SYSRESETREQ - workaround since sometimes the controller does not start after reset run
# but seems to "hang" in an NMI - should be removed once cortex_m3 reset_config works
OOCD_CL+=-c"mww 0xE000ED0C 0x05fa0004" -c "sleep 200"
# reset target
OOCD_CL+=-c "reset run"
# show the targets
OOCD_CL+=-c targets
# terminate OOCD after programming
OOCD_CL+=-c shutdown
# ---------------------------------------------------------------------------

OOCD_RESET_CL = openocd -d0 -f $(OOCD_TGT) -c init -c "reset run" -c shutdown

ifdef VECTOR_TABLE_LOCATION
CDEFS += -D$(VECTOR_TABLE_LOCATION)
ADEFS += -D$(VECTOR_TABLE_LOCATION)
endif

CDEFS += -D$(RUN_MODE) -D$(BOARD)
ADEFS += -D$(RUN_MODE) -D$(BOARD)

# Compiler flags.

ifeq ($(USE_THUMB_MODE),YES)
THUMB    = -mthumb
THUMB_IW = -mthumb-interwork
else 
THUMB    = 
THUMB_IW = 
endif

# Flags for C and C++ (arm-elf-gcc/arm-elf-g++)
CFLAGS =  -g$(DEBUG)
CFLAGS += -O$(OPT)
CFLAGS += -mcpu=$(MCU) $(THUMB_IW) 
CFLAGS += $(CDEFS)
CFLAGS += $(patsubst %,-I%,$(EXTRAINCDIRS)) -I.
# when using ".ramfunc"s without attribute longcall:
#CFLAGS += -mlong-calls
# -mapcs-frame is important if gcc's interrupt attributes are used
# (at least from my eabi tests), not needed if assembler-wrappers are used 

CFLAGS += -mapcs-frame 
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -fstrict-volatile-bitfields
CFLAGS += -Wall  
CFLAGS += -Wpointer-arith
CFLAGS += -Wno-cast-qual
CFLAGS += -Wno-attributes
CFLAGS += -Wa,-adhlns=$(addprefix $(OUTDIR)/, $(notdir $(addsuffix .lst, $(basename $<))))

# Compiler flags to generate dependency files:
CFLAGS += -MMD -MP -MF $(OUTDIR)/dep/$(@F).d

# flags only for C
CONLYFLAGS += -Wnested-externs 
CONLYFLAGS += $(CSTANDARD)

ifeq ($(DISABLESPECIALWARNINGS),yes)
CFLAGS += -Wno-cast-qual
CONLYFLAGS += -Wno-missing-prototypes 
CONLYFLAGS += -Wno-strict-prototypes
CONLYFLAGS += -Wno-missing-declarations
endif

# Assembler flags.
ASFLAGS  = -mcpu=$(MCU) $(THUMB_IW) -I. -x assembler-with-cpp
ASFLAGS += -D__ASSEMBLY__ $(ADEFS)
ASFLAGS += -Wa,-adhlns=$(addprefix $(OUTDIR)/, $(notdir $(addsuffix .lst, $(basename $<))))
ASFLAGS += -Wa,-g$(DEBUG)
ASFLAGS += $(patsubst %,-I%,$(EXTRAINCDIRS))

# Linker flags.
LDFLAGS = -Wl,-Map=$(OUTDIR)/$(TARGET).map,--cref,--gc-sections
LDFLAGS += --specs=nano.specs -lc -lnosys
LDFLAGS += $(patsubst %,-L%,$(EXTRA_LIBDIRS))
LDFLAGS += $(patsubst %,-L%,$(LINKERSCRIPTINC))
LDFLAGS += $(patsubst %,-l%,$(EXTRA_LIBS)) 
LDFLAGS += $(EXTRA_LDFLAGS)

# Set linker-script name depending on selected run-mode and chip
ifeq ($(RUN_MODE),RAM_RUN)
LDFLAGS +=-T./$(CHIP)_ram.ld
else 
LDFLAGS +=-T./$(TGT_LD)
endif

# Autodetect environment
SHELL   = sh
REMOVE_CMD:=rm

# Define programs and commands.
CC      = $(TCHAIN_PREFIX)gcc
AR      = $(TCHAIN_PREFIX)ar
OBJCOPY = $(TCHAIN_PREFIX)objcopy
OBJDUMP = $(TCHAIN_PREFIX)objdump
SIZE    = $(TCHAIN_PREFIX)size
NM      = $(TCHAIN_PREFIX)nm
REMOVE  = $(REMOVE_CMD) -f

      CMD_CC_O_C =  @$(CC) -c $(THUMB) $$(CFLAGS) $$(CONLYFLAGS) $$< -o $$@
quiet_CMD_CC_O_C = "[CC] $$<"

      CMD_AS_T_O_S =  @$(CC) -c $(THUMB) $$(ASFLAGS) $$< -o $$@
quiet_CMD_AS_T_O_S = "[AS] $$<"

      CMD_AS_O_S =  @$(CC) -c $$(ASFLAGS) $$< -o $$@
quiet_CMD_AS_O_S = "[AS] $$<"

      CMD_LD     =  @$(CC) $(THUMB) $(CFLAGS) $(ALLOBJ) --output $@  $(LDFLAGS)
quiet_CMD_LD     = "[LD] $@"

# Define Messages
MSG_SIZE_AFTER = [SZ]
MSG_LOAD_FILE  = [HX]
MSG_EXTENDED_LISTING = [LS]
MSG_SYMBOL_TABLE = [SY]
MSG_LINKING    = [LD]
MSG_COMPILING  = [CC]
MSG_ASSEMBLING = [AS]
MSG_CLEANING = Cleaning project:
MSG_ASMFROMC = "Creating asm-File from C-Source:"
MSG_ASMFROMC_ARM = "Creating asm-File from C-Source (ARM-only):"

# List of all source files.
ALLSRC     = $(ASRCARM) $(ASRC) $(SRCARM) $(SRC)
# List of all source files without directory and file-extension.
ALLSRCBASE = $(notdir $(basename $(ALLSRC)))

# Define all object files.
ALLOBJ     = $(addprefix $(OUTDIR)/, $(addsuffix .o, $(ALLSRCBASE)))

# Define all listing files (used for make clean).
LSTFILES   = $(addprefix $(OUTDIR)/, $(addsuffix .lst, $(ALLSRCBASE)))
# Define all depedency-files (used for make clean).
DEPFILES   = $(addprefix $(OUTDIR)/dep/, $(addsuffix .o.d, $(ALLSRCBASE)))

# Default target.
all: build

elf: $(OUTDIR)/$(TARGET).elf
lst: $(OUTDIR)/$(TARGET).lst 
sym: $(OUTDIR)/$(TARGET).sym
hex: $(OUTDIR)/$(TARGET).hex
bin: $(OUTDIR)/$(TARGET).bin

# Target for the build-sequence.
build: elf lst sym sizeafter

# Display sizes of sections.
ELFSIZE = $(SIZE) -B  $(OUTDIR)/$(TARGET).elf | grep -v .debug | grep -v .comment | grep -v .ARM.attributes | grep -v Total

sizeafter: elf
	@echo $(MSG_SIZE_AFTER)
	@$(ELFSIZE)

p: program

r: reset

# Program the device with Dominic Rath's OPENOCD in "batch-mode"
program: build
	@echo "Programming with OPENOCD"
	-$(OOCD_EXE) $(OOCD_CL)

reset: 
	@echo "RESET!"
	-$(OOCD_EXE) $(OOCD_RESET_CL)

# Create final output file in ihex format from ELF output file (.hex).
%.hex: %.elf
	@echo $(MSG_LOAD_FILE) $@
	$(OBJCOPY) -O ihex $< $@
	
# Create final output file in raw binary format from ELF output file (.bin)
%.bin: %.elf
	@echo $(MSG_LOAD_FILE) $@
	$(OBJCOPY) -O binary $< $@

# Create extended listing file/disassambly from ELF output file.
# using objdump (testing: option -C)
%.lst: %.elf
	@echo $(MSG_EXTENDED_LISTING) $@
	@$(OBJDUMP) -h -S -C -r $< > $@

# Create a symbol table from ELF output file.
%.sym: %.elf
	@echo $(MSG_SYMBOL_TABLE) $@
	@$(NM) -n $< > $@

# Link: create ELF output file from object files.
.SECONDARY : $(TARGET).elf
.PRECIOUS : $(ALLOBJ)
%.elf:  $(ALLOBJ) $(BUILDONCHANGE)
	@echo $($(quiet)CMD_LD)
	@$(CMD_LD)

# Assemble: create object files from assembler source files.
define ASSEMBLE_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@mkdir -p $(OUTDIR)
	@mkdir -p $(OUTDIR)/dep
	@echo $($(quiet)CMD_AS_T_O_S)
	@$(CMD_AS_T_O_S)
endef
$(foreach src, $(ASRC), $(eval $(call ASSEMBLE_TEMPLATE, $(src)))) 

# Assemble: create object files from assembler source files. ARM-only
define ASSEMBLE_ARM_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@echo $($(quiet)CMD_AS_O_S)
	@$(CMD_AS_O_S)
endef
$(foreach src, $(ASRCARM), $(eval $(call ASSEMBLE_ARM_TEMPLATE, $(src)))) 

# Compile: create object files from C source files.
define COMPILE_C_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@mkdir -p $(OUTDIR)
	@echo $($(quiet)CMD_CC_O_C)
	@$(CMD_CC_O_C)
endef
$(foreach src, $(SRC), $(eval $(call COMPILE_C_TEMPLATE, $(src)))) 

# Compile: create object files from C source files. ARM-only
define COMPILE_C_ARM_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@echo $(MSG_COMPILING) $$<
	@$(CC) -c $$(CFLAGS) $$(CONLYFLAGS) $$< -o $$@ 
endef
$(foreach src, $(SRCARM), $(eval $(call COMPILE_C_ARM_TEMPLATE, $(src)))) 

# Compile: create object files from C++ source files.
define COMPILE_CPP_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@echo $(MSG_COMPILING) $$<
	@$(CC) -c $(THUMB) $$(CFLAGS) $$(CPPFLAGS) $$< -o $$@ 
endef
$(foreach src, $(CPPSRC), $(eval $(call COMPILE_CPP_TEMPLATE, $(src)))) 

# Compile: create object files from C++ source files. ARM-only
define COMPILE_CPP_ARM_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@echo $(MSG_COMPILING) $$<
	@$(CC) -c $$(CFLAGS) $$(CPPFLAGS) $$< -o $$@ 
endef
$(foreach src, $(CPPSRCARM), $(eval $(call COMPILE_CPP_ARM_TEMPLATE, $(src)))) 

# Compile: create assembler files from C source files. ARM/Thumb
$(SRC:.c=.s) : %.s : %.c $(BUILDONCHANGE)
	@mkdir -p $(OUTDIR)
	@echo $(MSG_ASMFROMC) $<
	@$(CC) $(THUMB) -S $(CFLAGS) $(CONLYFLAGS) $< -o $@

# Compile: create assembler files from C source files. ARM only
$(SRCARM:.c=.s) : %.s : %.c $(BUILDONCHANGE)
	@echo $(MSG_ASMFROMC_ARM) $<
	@$(CC) -S $(CFLAGS) $(CONLYFLAGS) $< -o $@

# Target: clean project.
clean:
	@echo $(MSG_CLEANING)
	$(REMOVE) $(OUTDIR)/$(TARGET).map
	$(REMOVE) $(OUTDIR)/$(TARGET).elf
	$(REMOVE) $(OUTDIR)/$(TARGET).hex
	$(REMOVE) $(OUTDIR)/$(TARGET).bin
	$(REMOVE) $(OUTDIR)/$(TARGET).sym
	$(REMOVE) $(OUTDIR)/$(TARGET).lst
	$(REMOVE) $(ALLOBJ)
	$(REMOVE) $(LSTFILES)
	$(REMOVE) $(DEPFILES)
	$(REMOVE) $(SRC:.c=.s)
	$(REMOVE) $(SRCARM:.c=.s)
	$(REMOVE) $(CPPSRC:.cpp=.s)
	$(REMOVE) $(CPPSRCARM:.cpp=.s)

distclean: clean
	$(REMOVE) -r ./build_*

# Include the dependency files.
##-include $(wildcard dep/*)
-include $(wildcard $(OUTDIR)/dep/*.d)

# Listing of phony targets.
.PHONY : all sizeafter gccversion build elf hex bin lst sym clean distclean program reset

