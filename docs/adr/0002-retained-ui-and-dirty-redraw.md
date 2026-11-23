# Retained UI with dirty-rectangle redraw

The calculator UI will use retained Screens and Widgets rather than immediate-mode frame drawing. Widgets persist, participate in Tab-style focus traversal, and layout against a fixed display grid. Drawing text uses Iosevka Fixed rasterized through TrueType at build/demo time.

Views mark Dirty Rectangles when they change. The Desktop Simulator and Native Backend redraw only those regions; native updates are sent as changed-pixel commands.
