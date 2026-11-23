# Backend-owned display surface

The selected desktop-simulator or native backend owns the display surface. The calculator application receives read/write access to that surface through the backend interface, and the native backend sends changed-pixel commands rather than a full framebuffer.
