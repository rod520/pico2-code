# Calculator Sokol starter — milestone 1

A minimal Zig + Sokol desktop shell for the calculator project.

## Locked decisions

- Virtual LCD: 320 × 240 (4:3), RGB565 in the eventual controller emulator.
- Desktop window starts at 320 × 240 client size and is resizable.
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

## Pico memory budgets

The 320 × 240 RGB565 display surface is 153,600 bytes. The simulator checks this
against the RP2350's 520 KiB SRAM and 8 MiB PSRAM limits in `src/memory.zig`.

- Keep the full RGB565 framebuffer in PSRAM.
- Keep frequently changed state, input state, and UI controls in SRAM.
- Keep generated font bitmaps and other read-only assets in flash or PSRAM.
- Add new long-lived or frame-sized allocations to `src/memory.zig` before using them.

## Milestone 1 acceptance

- Opens a native desktop window with a 320 × 240 initial client area.
- Uses Sokol's application and graphics layers.
- Window is resizable.
- Clears the window every frame.
- No display-controller emulation, framebuffer, keyboard, CAS, or RP2350 code is included yet.

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
4. Sokol texture upload and 4:3 letterboxed presentation.

Do not add the hardware backend until the simulated command path is testable.
