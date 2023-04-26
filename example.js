const addon = require('./zig-out/lib/example.node');

const tensor = addon.fl_tensorFromFloat32Buffer(BigInt(1), new Float32Array([1]))
console.log(addon.fl_dtype(tensor));
console.log(addon.fl_bytesUsed());
const contig = addon.fl_asContiguousTensor(tensor);
console.log(addon.fl_float32Buffer(contig));
addon.fl_dispose(tensor);
addon.fl_dispose(contig);
console.log(addon.fl_bytesUsed());