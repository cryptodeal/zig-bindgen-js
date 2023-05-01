import { expect, describe, it } from 'bun:test';
const addon = require('../zig-out/lib/example.node');

describe('NAPI - `TypedArray`', () => {
  // base data
  const base = Array.from(Array(100).keys());
  
  it('returns `[]i8` as `Int8Array`', () => {
    const int8_array = addon.slice_to_Int8Array();
    expect(int8_array).toBeInstanceOf(Int8Array);
    expect(int8_array).toStrictEqual(new Int8Array(base));
  })

  it('returns `[]u8` as `Uint8Array`', () => {
    const uint8_array = addon.slice_to_Uint8Array();
    expect(uint8_array).toBeInstanceOf(Uint8Array);
    expect(uint8_array).toStrictEqual(new Uint8Array(base));
  })

  it('returns `[]i16` as `Int16Array`', () => {
    const int16_array = addon.slice_to_Int16Array();
    expect(int16_array).toBeInstanceOf(Int16Array);
    expect(int16_array).toStrictEqual(new Int16Array(base));
  })

  it('returns `[]u16` as `Uint16Array`', () => {
    const uint16_array = addon.slice_to_Uint16Array();
    expect(uint16_array).toBeInstanceOf(Uint16Array);
    expect(uint16_array).toStrictEqual(new Uint16Array(base));
  })

  it('returns `[]i32` as `Int32Array`', () => {
    const int32_array = addon.slice_to_Int32Array();
    expect(int32_array).toBeInstanceOf(Int32Array);
    expect(int32_array).toStrictEqual(new Int32Array(base));
  })

  it('returns `[]u32` as `Uint32Array`', () => {
    const uint32_array = addon.slice_to_Uint32Array();
    expect(uint32_array).toBeInstanceOf(Uint32Array);
    expect(uint32_array).toStrictEqual(new Uint32Array(base));
  })

  it('returns `[]i64` as `BigInt64Array`', () => {
    const bigint64_array = addon.slice_to_BigInt64Array();
    expect(bigint64_array).toBeInstanceOf(BigInt64Array);
    expect(bigint64_array).toStrictEqual(new BigInt64Array(base.map(v => BigInt(v))));
  })

  it('returns `[]u64` as `BigUint64Array`', () => {
    const biguint64_array = addon.slice_to_BigUint64Array();
    expect(biguint64_array).toBeInstanceOf(BigUint64Array);
    expect(biguint64_array).toStrictEqual(new BigUint64Array(base.map(v => BigInt(v))));
  })

  it('returns `[]f32` as `Float32Array`', () => {
    const float32_array = addon.slice_to_Float32Array();
    expect(float32_array).toBeInstanceOf(Float32Array);
    expect(float32_array).toStrictEqual(new Float32Array(base));
  })

  it('returns `[]f64` as `Float64Array`', () => {
    const float64_array = addon.slice_to_Float64Array();
    expect(float64_array).toBeInstanceOf(Float64Array);
    expect(float64_array).toStrictEqual(new Float64Array(base));
  })
})

