###############################################################################
# Makefile for the project attiny45v-sound
###############################################################################

## General Flags
PROJECT = attiny45v-sound
MCU = attiny45
TARGET = attiny45v-sound.elf
CC = avr-gcc

CPP = avr-g++

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -gdwarf-2 -std=gnu99                                                                                                                                         -DF_CPU=16000000UL -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS += -MD -MP -MT $(*F).o -MF dep/$(@F).d 

## Assembly specific flags
ASMFLAGS = $(COMMON)
ASMFLAGS += $(CFLAGS)
ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS +=  -Wl,-Map=attiny45v-sound.map


## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom -R .fuse -R .lock -R .signature

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0 --no-change-warnings


## Objects that must be built in order to link
OBJECTS = Main.o SPI.o SPI.inc.o ImaAdpcmDecoder.o YamahaAdpcmDecoder.o WaveInfo.inc.o Decoder.inc.o Decoder.o Utility.o WaveParser.o SPIStream.o PlayController.o 

## Objects explicitly added by the user
LINKONLYOBJECTS = 

## Build
all: $(TARGET) attiny45v-sound.hex attiny45v-sound.eep attiny45v-sound.lss size

## Compile
Main.o: ../Main.cpp
	$(CPP) $(INCLUDES) $(CFLAGS) -c  $<

SPI.o: ../SPI.s
	$(CPP) $(INCLUDES) $(ASMFLAGS) -c  $<

SPI.inc.o: ../SPI.inc.s
	$(CPP) $(INCLUDES) $(ASMFLAGS) -c  $<

ImaAdpcmDecoder.o: ../ImaAdpcmDecoder.s
	$(CPP) $(INCLUDES) $(ASMFLAGS) -c  $<

YamahaAdpcmDecoder.o: ../YamahaAdpcmDecoder.s
	$(CPP) $(INCLUDES) $(ASMFLAGS) -c  $<

WaveInfo.inc.o: ../WaveInfo.inc.s
	$(CPP) $(INCLUDES) $(ASMFLAGS) -c  $<

Decoder.inc.o: ../Decoder.inc.s
	$(CPP) $(INCLUDES) $(ASMFLAGS) -c  $<

Decoder.o: ../Decoder.s
	$(CPP) $(INCLUDES) $(ASMFLAGS) -c  $<

Utility.o: ../Utility.s
	$(CPP) $(INCLUDES) $(ASMFLAGS) -c  $<

WaveParser.o: ../WaveParser.cpp
	$(CPP) $(INCLUDES) $(CFLAGS) -c  $<

SPIStream.o: ../SPIStream.cpp
	$(CPP) $(INCLUDES) $(CFLAGS) -c  $<

PlayController.o: ../PlayController.cpp
	$(CPP) $(INCLUDES) $(CFLAGS) -c  $<

##Link
$(TARGET): $(OBJECTS)
	 $(CPP) $(LDFLAGS) $(OBJECTS) $(LINKONLYOBJECTS) $(LIBDIRS) $(LIBS) -o $(TARGET)

%.hex: $(TARGET)
	avr-objcopy -O ihex $(HEX_FLASH_FLAGS)  $< $@

%.eep: $(TARGET)
	-avr-objcopy $(HEX_EEPROM_FLAGS) -O ihex $< $@ || exit 0

%.lss: $(TARGET)
	avr-objdump -h -S $< > $@

size: ${TARGET}
	@echo
	@avr-size -C --mcu=${MCU} ${TARGET}

## Clean target
.PHONY: clean
clean:
	-rm -rf $(OBJECTS) attiny45v-sound.elf dep/* attiny45v-sound.hex attiny45v-sound.eep attiny45v-sound.lss attiny45v-sound.map


## Other dependencies
-include $(shell mkdir dep 2>NUL) $(wildcard dep/*)

