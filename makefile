CA = ca65
CFLAGS = 
LD = ld65
LDFLAGS = -v 
LDCFG = mem_map.cfg
OBJS = serial.o
ASM = serial.asm
TARGET = serial.bin

all : $(TARGET) 

%.o: %.asm
	$(CA) $(CFLAGS) $< -o $@

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -C $(LDCFG) -o serial.bin $(OBJS)

.PHONY: clean
clean : 
	rm -f $(OBJS) $(TARGET)