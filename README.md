# wb_ram_bus_mux
Tiny Wishbone MUX for two memory blocks (OpenRAM + HyperRAM)

| Memory block  | Space| Address | Size |
| --- | --- | --- | --- |
| HyperRAM ext. chip  | RAM  | 0x3000_0000 - 0x307f_ffff | 8MB |
| HyperRAM ext. chip  | Registers  | 0x3080_0000 - 0x3080_ffff | max 64k registers, 16bit each |
| HyperRAM driver  | CSRs  | 0x3081_0000 - 0x3081_ffff | max 64kB, 16k CSRs |
| OpenRAM  | RAM  | 0x30c0_0000 - 0x30c0_ffff | max 64kB |
