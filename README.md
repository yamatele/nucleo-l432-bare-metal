cd ~/embedded/nucleo-l432
cat > README.md << 'EOF'
# NUCLEO-L432KC bare-metal

Learning embedded C on an STM32L432KC (Cortex-M4F) with no HAL and no IDE.
Everything is built from the reference manual, and every register address and
bit position in this repo comes from the documents listed below.

## Hardware
- ST NUCLEO-L432KC (STM32L432KC, 256 KB flash, 64 KB RAM)
- On-board ST-LINK debugger, used over SWD
- User LED LD3 (green) on **PB3**, which is Arduino signal D13 (solder bridge SB15)

## Toolchain
- Arm GNU Toolchain 14.2.Rel1 (`arm-none-eabi-gcc`, `arm-none-eabi-gdb`)
- OpenOCD 0.12.0
- macOS 12 on a 2015 MacBook Pro, editing in Neovim (NvChad)

## What is here
### `blink.gdb`
Blinks LD3 by writing peripheral registers directly from GDB, with no program
running on the chip. The steps are the same ones a C driver will perform later:

1. Enable the GPIOB clock: set bit 1 (`GPIOBEN`) of `RCC_AHB2ENR` (`0x4002104C`)
2. Set PB3 to general-purpose output: `GPIOB_MODER` (`0x48000400`), bits 7:6
3. Set or clear the pin through `GPIOB_BSRR` (`0x48000418`):
   `0x00000008` drives PB3 high, `0x00080000` drives it low

## Running it
In one terminal, start OpenOCD:

```
openocd -f board/st_nucleo_l4.cfg
```

In another terminal, from this folder:

```
arm-none-eabi-gdb -x blink.gdb
```

Press Ctrl+C in GDB to stop the loop.

## How the values were found
| Item | Value | Source |
|---|---|---|
| LED pin | PB3 | Nucleo-32 user manual: LD3 on D13, mapped to PB3 |
| RCC base | `0x40021000` | RM0394 memory map (AHB1) |
| GPIOB base | `0x48000400` | RM0394 memory map (AHB2) |
| `RCC_AHB2ENR` | offset `0x4C` | RM0394 register map, p. 248 |
| `GPIOB_MODER` reset | `0xFFFFFEBF` | RM0394 Table 41 (pins 3 and 4 reset to alternate function for JTAG) |
| `GPIOB_BSRR` | offset `0x18` | RM0394 register map, p. 280 |

PB3 resets as `JTDO-TRACESWO`, so the mode bits have to be set explicitly.
SWD uses PA13 and PA14, so reconfiguring PB3 does not disturb the debug link.

## Documents used
- RM0394 Rev 5, reference manual for STM32L41xxx/42xxx/43xxx/44xxx/45xxx/46xxx
- STM32L432xx datasheet (pin definitions)
- Nucleo-32 board user manual (solder bridges, Arduino connector pin mapping)

## Roadmap
- [x] Toolchain, OpenOCD and GDB working against the board
- [x] Read the vector table and boot sequence from flash
- [x] Blink LD3 with raw register writes
- [ ] Own linker script and startup file
- [ ] Blink from C, running from flash with no debugger attached
- [ ] UART over the ST-LINK virtual COM port
EOF
