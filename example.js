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
const i8_slice = addon.slice_to_Int8Array();
console.log(i8_slice);

const i16_slice = addon.slice_to_Int16Array();
console.log(i16_slice);

const i32_slice = addon.slice_to_Int32Array();
console.log(i32_slice);

const i64_slice = addon.slice_to_BigInt64Array();
console.log(i64_slice);

const u8_slice = addon.slice_to_Uint8Array();
console.log(u8_slice);

const u16_slice = addon.slice_to_Uint16Array();
console.log(u16_slice);

const u32_slice = addon.slice_to_Uint32Array();
console.log(u32_slice);

const u64_slice = addon.slice_to_BigUint64Array();
console.log(u64_slice);

const wrapped = addon.wrapped_struct(100, BigInt(2000));
console.log(wrapped);
console.log(addon.wrapped_struct_get_a(wrapped));
console.log(addon.wrapped_struct_get_b(wrapped));