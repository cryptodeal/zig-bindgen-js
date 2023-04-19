# zig-bindgen-js

## Build OSx

Buid flashlight and shumai and move `libflashlight_binding.dylib` to root of project.

**Install Zig Latest**

```bash
brew install zig --HEAD
```

**Build `example.node`**

```bash
zig build
```

**Run Example via Bun/Node**

```bash
bun example.js
```
