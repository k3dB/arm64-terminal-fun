AS      := as
LD      := ld
ARCH    := arm64
SDKROOT := $(shell xcrun --show-sdk-path)

SRC     := leapyear.s
OBJ     := build/leapyear.o
BIN     := bin/leapyear

.PHONY: all clean

all: $(BIN)

$(BIN): $(OBJ) | bin
	$(LD) -o $@ -lSystem -syslibroot "$(SDKROOT)" -e _main -arch $(ARCH) $<

$(OBJ): $(SRC) | build
	$(AS) -arch $(ARCH) -o $@ $<

build bin:
	mkdir -p $@

clean:
	rm -rf build bin
