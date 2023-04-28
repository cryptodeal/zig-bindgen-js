const addon = require('./zig-out/lib/example.node');
const length = 100; 

// works to init tensor
const tensor = addon.fl_tensorFromFloat32Buffer(BigInt(length), new Float32Array(Array.from({ length }, () => Math.random())));

// works to return tensor shape as `BigInt`
console.log(addon.fl_dtype(tensor));

// works to return bytes as `BigInt`
console.log(addon.fl_bytesUsed());

// works to return tensor data as `TypedArray`
const contig = addon.fl_asContiguousTensor(tensor);
console.log(addon.fl_float32Buffer(contig));

// works to free tensor data
addon.fl_dispose(tensor);
addon.fl_dispose(contig);
console.log(addon.fl_bytesUsed());

// works to return slice as TypedArray
const slice = addon.testSliceOut();
console.log(slice);

// works to pass typedarray -> slice
addon.testSliceIn(slice);

