chip.bin: camera_configure.v OV7670_config.v OV7670_config_rom.v camera_configure.pcf SCCB_interface.v
	yosys -q -p "synth_ice40 -blif chip.blif" OV7670_config_rom.v OV7670_config.v SCCB_interface.v camera_configure.v
	arachne-pnr -d 8k -P tq144:4k -p camera_configure.pcf chip.blif -o chip.txt
	icepack chip.txt chip.bin

.PHONY: upload
upload:
	cat chip.bin >/dev/ttyUSB0

.PHONY: clean
clean:
	$(RM) -f chip.blif chip.txt chip.ex chip.bin
