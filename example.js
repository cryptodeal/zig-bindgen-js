const addon = require('./zig-out/lib/example.node')
const tensor = addon.fl_tensorFromFloat32Buffer(BigInt(1), new Float32Array([1]))
console.log(addon.fl_dtype(tensor))
console.log(addon.fl_bytesUsed());