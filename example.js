const addon = require('./zig-out/lib/example.node')
console.log(addon.fl_tensorFromFloat32Buffer(BigInt(1), new Float32Array([1])));
console.log(addon.fl_bytesUsed());