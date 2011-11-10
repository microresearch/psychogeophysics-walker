# Name: Makefile
# Project: pysch walker (testing)
# Author: Martin Howse m@1010.co.uk
# License: GPL2
# Target MCU: Atmel Atmega8


COMPILE = avr-gcc -Wall -Os -Wl,-u,vfprintf -lprintf_flt -lm -mmcu=atmega8
MCU_AVRDUDE := m8

OBJECTS = fgm_slave.o
# Note that we link usbdrv.o first! This is required for correct alignment of
# driver-internal global variables!

# symbolic targets:
all:	fgm_slave.hex

.c.o:
	$(COMPILE) -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@
# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

.c.s:
	$(COMPILE) -S $< -o $@

clean:
	rm -f fgm_slave.hex fgm_slave.lst fgm_slave.obj fgm_slave.cof fgm_slave.list fgm_slave.map fgm_slave.eep.hex fgm_slave.bin *.o

# file targets:
fgm_slave.bin:	$(OBJECTS)
	$(COMPILE) -o fgm_slave.bin $(OBJECTS)

fgm_slave.hex:	fgm_slave.bin
	rm -f fgm_slave.hex fgm_slave.eep.hex
	avr-objcopy -j .text -j .data -O ihex fgm_slave.bin fgm_slave.hex


disasm:	fgm_slave.bin
	avr-objdump -d fgm_slave.bin

cpp:
	$(COMPILE) -E fgm_slave.c

flash: $(HEX)
	avrdude -y -c usbasp -p $(MCU_AVRDUDE) -U flash:w:fgm_slave.hex

fuse:
	avrdude -c usbasp -p m8 -U lfuse:w:0xFF:m -U hfuse:w:0xDF:m
