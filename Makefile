#******************************************************************************
# Copyright (C) 2017 by Alex Fosdick - University of Colorado
#
# Redistribution, modification or use of this software in source or binary
# forms is permitted as long as the files maintain this copyright. Users are 
# permitted to modify this and use it to learn about the field of embedded
# software. Alex Fosdick and the University of Colorado are not liable for any
# misuse of this material. 
#
#*****************************************************************************

#------------------------------------------------------------------------------
# <Put a Description Here>
#
# Use: make [TARGET] [PLATFORM-OVERRIDES]
#
# Build Targets:
#      <Put a description of the supported targets here>
#
# Platform Overrides:
#      <Put a description of the supported Overrides here
#
#------------------------------------------------------------------------------
include sources.mk

# Platform Overrides

PLATFORM = HOST

# Architectures Specific Flags

CPU = cortex-m4
ARCH = armv7e-m
SPECS = nosys.specs

# Compiler conditionaly Flags and Defines for HOST Platform and ARM Platform
ifeq ($(PLATFORM),HOST)

CC = gcc
LD = ld
CFLAGS = -D$(PLATFORM)
LDFLAGS = -Wl,-Map=$(TARGET).map

else

CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld
CFLAGS = -D$(PLATFORM) -mcpu=$(CPU) -mthumb -march=$(ARCH) --specs=$(SPECS) -mfloat-abi=hard -mfpu=fpv4-sp-d16
LINKER_FILE = -T msp432p401r.lds
LDFLAGS = -Wl,-Map=$(TARGET).map $(LINKER_FILE)

endif

TARGET = c1m2
OUTPUT = $(TARGET).out
SIZE = size
CPPFLAGS = -g -O0 -std=c99 -Wall -Werror

#Object Files
OBJS = $(SOURCES:.c=.o)
%.o: %.c
	$(CC) $(INCLUDES) -c $^ -o $@ $(CFLAGS) $(CPPFLAGS)

#Preprocessor Files
PREP= $(SOURCES:.c=.i)
%.i: %.c
	$(CC) $(INCLUDES) -E $(CFLAGS) $(CPPFLAGS) $< -D$(PLATFORM) -o $@

#Dependecies files
DEPS= $(SOURCES:.c=.d)
%.d: %.c
	$(CC) $(INCLUDES) -M $(CFLAGS) $(CPPFLAGS) $< -D$(PLATFORM) -o $@

#Assembly files
ASSE= $(SOURCES:.c=.asm)
%.asm: %.c
	$(CC) $(INCLUDES) -S $(CFLAGS) $(CPPFLAGS) $< -D$(PLATFORM) -o $@


#Phony

.PHONY: build
build: all

.PHONY: all
all: $(TARGET).out

$(TARGET).out: $(OBJS) $(PREP) $(DEPS) $(ASSE)
	$(CC) $(INCLUDES) $(OBJS) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -o $@
	$(SIZE) -Atd $(OUTPUT)

.PHONY: compile-all
compile-all: $(DEPS) $(PREP) $(ASSE) $(OBJS)

.PHONY: clean
clean:
	rm -f *.o *.i *.d *.asm *.out *.map
	echo 'CLEANED ALL FILES'



