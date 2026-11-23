# Calculator Sokol starter

A Zig + Sokol desktop simulator and future RP2350 firmware project.

## Locked decisions

- Virtual LCD: 320 × 240 (4:3), RGB565 in the eventual controller emulator.
- The LCD is 320 × 240.
- The desktop simulator opens an unbroken 692 × 240 presentation: 320 × 240 LCD at left and 372 × 240 on-screen keypad at right.
- The desktop keypad is a visual simulator panel, not part of the LCD or native hardware UI.
- The keypad mirrors the 60-switch CSV layout: 6 columns × 10 rows.
- The desktop window is resizable and letterboxes the combined simulator presentation.
- Keyboard simulation will support both physical-key mapping and clickable on-screen keys.
- The desktop build uses Sokol. Sokol must not leak into shared calculator or display-controller code.
- The hardware build will later replace the simulation bus with the RP2350B parallel GPIO bus.

## Requirements

- Zig 0.17.1
- A desktop toolchain supported by Sokol.
- On Linux, Sokol's documented X11/audio development packages may be required.

## Fetch Sokol

From this directory:

```sh
zig fetch --save=sokol git+https://github.com/floooh/sokol-zig.git
```

This writes the exact fetched package hash into `build.zig.zon`. Commit the resulting manifest so builds are reproducible.

## Build and run

```sh
zig build run
```

Build without launching:

```sh
zig build sim
```

Run the native placeholder:

```sh
zig build run-native
```

Run tests:

```sh
zig build test
```

## Pico memory budgets

The 320 × 240 RGB565 display surface is 153,600 bytes. The simulator checks this
against the RP2350's 520 KiB SRAM and 8 MiB PSRAM limits in `src/memory.zig`.

- Keep the full RGB565 framebuffer in PSRAM.
- Keep frequently changed state, input state, and UI controls in SRAM.
- Keep generated font bitmaps and other read-only assets in flash or PSRAM.
- Add new long-lived or frame-sized allocations to `src/memory.zig` before using them.

## Simulator UI

- The 320 × 240 LCD uses one RGB565 framebuffer.
- The 372 × 240 side panel uses the 60-key CSV layout.
- Iosevka Fixed is rasterized with TrueType for the LCD and key labels.
- The LCD and keypad move together as one 692 × 240 presentation when the window scales.
- Physical arrow keys, Enter, number keys, and operators map to logical keypad switches.
- Mouse clicks on the side panel generate the same logical key presses as physical key events.

## Architecture planned after milestone 1

```text
calculator application
        |
  platform-neutral APIs
        |
  +-----+-----------------------+
  |                             |
desktop simulation          RP2350B firmware
  |                             |
ILI9342C command bus         parallel GPIO bus
  |                             |
controller emulator          E26RE-RW300-N
  |
RGB565 framebuffer
  |
Sokol texture presentation
```

The ILI9342C command driver should be shared. Only the bus implementation changes:
- simulation bus: feeds command/data writes into the controller emulator;
- hardware bus: emits the required 9-bit parallel transfers to the physical display.

Sokol only presents the emulator framebuffer. It does not implement the ILI9342C protocol.

## Next milestone

Add:
1. `display/bus.zig` — small command/data write interface;
2. `display/ili9342c.zig` — shared controller driver;
3. `display/sim/controller.zig` — command interpreter and RGB565 framebuffer;
4. LCD texture upload and presentation.

Do not add the hardware backend until the simulated command path is testable.
