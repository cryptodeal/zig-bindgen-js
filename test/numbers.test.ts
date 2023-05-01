import { expect, describe, test } from 'bun:test';
const addon = require('../zig-out/lib/example.node');

describe('NAPI - `number`', () => {
  const a = 10;
  const b = 20;

  test('returns `i8` as `number`', () => {
    expect(addon.add_i8(a, b)).toBe(a+b);
  })

  test('returns `u8` as `number`', () => {
    expect(addon.add_u8(a, b)).toBe(a+b);
  })

  test('returns `i16` as `number`', () => {
    expect(addon.add_i16(a, b)).toBe(a+b);
  })

  test('returns `u16` as `number`', () => {
    expect(addon.add_u16(a, b)).toBe(a+b);
  })

  test('returns `i32` as `number`', () => {
    expect(addon.add_i32(a, b)).toBe(a+b);
  })

  test('returns `u32` as `number`', () => {
    expect(addon.add_u32(a, b)).toBe(a+b);
  })

  test('returns `i64` as `bigint`', () => {
    expect(addon.add_i64(BigInt(a), BigInt(b))).toBe(BigInt(a+b));
  })

  test('returns `u64` as `bigint`', () => {
    expect(addon.add_i64(BigInt(a), BigInt(b))).toBe(BigInt(a+b));
  })

  test('returns `f32` as `number`', () => {
    expect(addon.add_f32(a, b)).toBe(a+b);
  })

  test('returns `f64` as `number`', () => {
    expect(addon.add_f64(a, b)).toBe(a+b);
  })
})

