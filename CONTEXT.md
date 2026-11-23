# Calculator

This context defines the calculator’s platform-neutral display, input, and execution vocabulary.

## Language

**Desktop Simulator**:
A host application that presents the calculator through a simulated display and keyboard.
_Avoid_: Native host executable, simulator build

**Native Backend**:
The RP2350 firmware implementation that communicates with the physical calculator display.
_Avoid_: Native executable, native build

**Display Surface**:
The platform-neutral RGB565 drawing area used for calculator display content.
_Avoid_: Framebuffer implementation, Sokol texture

**Key**:
One of the 60 logical keys in the calculator keypad.

**Key Role**:
A stable name for a keypad function, mapped to one or more physical key positions.

**Backend**:
The platform implementation that owns presentation or hardware access for the calculator.

**Changed-Pixel Command**:
A native display update that sends only pixels modified by the calculator application.

**Key Press**:
A discrete indication that a Key Role was pressed, distinct from continuously holding it.

**View**:
A retained UI element that occupies a display region and participates in layout and rendering.

**Screen**:
A View that owns one complete UI mode and manages navigation among its widgets.

**Glyph**:
A visual representation of a character within a font.

**Text Line**:
A sequence of glyphs arranged along one baseline.

**Focus**:
The one UI element that receives the next keypad command.

**Widget**:
A retained interactive View that owns state and participates in focus traversal.

**Dirty Rectangle**:
A display region that may have changed and must be redrawn.

**Layout Grid**:
A fixed display grid whose rows and columns position retained Views and text.

**Simulator Keypad**:
The desktop-only visual representation of the 60 physical calculator switches.

**Switch**:
A numbered physical calculator key, identified by SW1 through SW60.
