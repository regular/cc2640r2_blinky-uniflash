
#
# User settings
#

TARGET=blinky
BUILD_DIR = ./_build

# Anything with ti/ at the beginning should be searched via the vpath set up for $TICCSDK.
C_SOURCES := \
	src/main.c \
	src/board_config.c \
	$(TICCDEVICESRC)/startup_files/startup_gcc.c

CFLAGS += -O3 -g

DEFINES += -DDeviceFamily_CC26X0R2

INCLUDES += -I$(TICCSDK)/source
INCLUDES += -I$(TICCSDK)/source/$(TICCDEVICESRC)

#
# Advanced project settings
#

PREFIX=arm-none-eabi
CC=$(PREFIX)-gcc
LD=$(PREFIX)-gcc
AS=$(PREFIX)-gcc
OBJDUMP=$(PREFIX)-objdump
OBJCOPY=$(PREFIX)-objcopy

UF=/opt/ti/uniflash/dslite.sh 

# CFLAGS for all sources.
CFLAGS += -mthumb -mcpu=cortex-m3
CFLAGS += -ffunction-sections -fdata-sections

# Error on implicit function declaration.
CFLAGS += -Werror=implicit-function-declaration

LDFLAGS += -Wl,-T"$(TICCSDK)/source/$(TICCDEVICESRC)/linker_files/cc26x0r2f.lds"
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -mthumb -mcpu=cortex-m3
LDFLAGS += -nostartfiles

#
# Build sanity checks.
#

ifeq ($(TICCSDK),)
  $(error TICCSDK is not defined)
endif

include $(TICCSDK)/imports.mak

ifeq ($(GCC_ARMCOMPILER),)
  GCC_TEST
  $(error GCC_ARMCOMPILER is not defined and arm-none-eabi cannot be found.)
else
  export PATH := $(PATH):$(GCC_ARMCOMPILER)/bin
endif

# Compile commands are echoed if V=1
ifneq ($(V),)
  SS=
else
  SS=@
endif

vpath %.c $(TICCSDK)/source

DRIVERLIB_DIR := $(TICCDEVICESRC)/driverlib
DRIVERLIB_SRC := \
	$(DRIVERLIB_DIR)/adi.c \
	$(DRIVERLIB_DIR)/aon_batmon.c \
	$(DRIVERLIB_DIR)/aon_event.c \
	$(DRIVERLIB_DIR)/aon_ioc.c \
	$(DRIVERLIB_DIR)/aon_rtc.c \
	$(DRIVERLIB_DIR)/aon_wuc.c \
	$(DRIVERLIB_DIR)/aux_adc.c \
	$(DRIVERLIB_DIR)/aux_smph.c \
	$(DRIVERLIB_DIR)/aux_tdc.c \
	$(DRIVERLIB_DIR)/aux_timer.c \
	$(DRIVERLIB_DIR)/aux_wuc.c \
	$(DRIVERLIB_DIR)/ccfgread.c \
	$(DRIVERLIB_DIR)/chipinfo.c \
	$(DRIVERLIB_DIR)/cpu.c \
	$(DRIVERLIB_DIR)/crypto.c \
	$(DRIVERLIB_DIR)/ddi.c \
	$(DRIVERLIB_DIR)/debug.c \
	$(DRIVERLIB_DIR)/driverlib_release.c \
	$(DRIVERLIB_DIR)/event.c \
	$(DRIVERLIB_DIR)/flash.c \
	$(DRIVERLIB_DIR)/gpio.c \
	$(DRIVERLIB_DIR)/i2c.c \
	$(DRIVERLIB_DIR)/i2s.c \
	$(DRIVERLIB_DIR)/interrupt.c \
	$(DRIVERLIB_DIR)/ioc.c \
	$(DRIVERLIB_DIR)/osc.c \
	$(DRIVERLIB_DIR)/prcm.c \
	$(DRIVERLIB_DIR)/pwr_ctrl.c \
	$(DRIVERLIB_DIR)/rfc.c \
	$(DRIVERLIB_DIR)/setup.c \
	$(DRIVERLIB_DIR)/setup_rom.c \
	$(DRIVERLIB_DIR)/smph.c \
	$(DRIVERLIB_DIR)/ssi.c \
	$(DRIVERLIB_DIR)/sw_chacha.c \
	$(DRIVERLIB_DIR)/sw_poly1305-donna.c \
	$(DRIVERLIB_DIR)/sys_ctrl.c \
	$(DRIVERLIB_DIR)/systick.c \
	$(DRIVERLIB_DIR)/timer.c \
	$(DRIVERLIB_DIR)/trng.c \
	$(DRIVERLIB_DIR)/uart.c \
	$(DRIVERLIB_DIR)/udma.c \
	$(DRIVERLIB_DIR)/vims.c \
	$(DRIVERLIB_DIR)/watchdog.c

# Add the driverlib 
C_SOURCES += $(DRIVERLIB_SRC)

# Compile list of objects.
C_OBJECTS := $(addprefix $(BUILD_DIR)/, $(C_SOURCES:.c=.o))

# CFLAGS for anything in driverlib
CFLAGS_DRIVERLIB += -O3

# Append extra CFLAGS depending on directory.
$(BUILD_DIR)/$(DRIVERLIB_DIR)/%.o: CFLAGS+=$(CFLAGS_DRIVERLIB)

#
# Build Rules
#

.PHONY: clean all flash uflash disasm

all: $(TARGET).elf $(TARGET).hex

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(TARGET).elf $(TARGET).hex
	rm -f $(TARGET).disasm

flash: $(TARGET).hex
	openocd -f ocd_flash.cfg

uflash: $(TARGET).hex
	$(UF) --config=/opt/ti/uniflash/deskdb/content/TICloudAgent/linux/ccs_base/arm/cc13xx_cc26xx_2pin_cJTAG_XDS110.ccxml --reset 0 $<

disasm: $(TARGET).elf
	$(OBJDUMP) -d $(TARGET).elf > $(TARGET).disasm

$(TARGET).elf: $(C_OBJECTS)
	@echo LD $@
	$(SS) $(LD) -o $@ $(LDFLAGS) $^

%.hex: %.elf
	@echo HEX $@
	$(SS) $(OBJCOPY) -O ihex $< $@

# Include generated dependency files (alongside .o files)
-include $(C_OBJECTS:.o=.d)

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo CC $(notdir $<)
	$(SS) $(CC) $(INCLUDES) $(DEFINES) $(CFLAGS) -c -o $@ $<
	$(SS) $(CC) $(INCLUDES) $(DEFINES) $(CFLAGS) -MM -MT $@ $< > $(BUILD_DIR)/$*.d
