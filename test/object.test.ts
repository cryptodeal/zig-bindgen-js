import { expect, describe, test } from 'bun:test';
const addon = require('../zig-out/lib/example.node');

describe('NAPI - Object', () => {
  test('returns Zig `struct` as JS `object`', () => {
    const struct_val = addon.returns_struct();
    expect(struct_val).toEqual({ a: 1, b: 2, c: "Hello, World!" });
  })

  test('passes JS `object` as Zig `struct`', () => {
    const obj = { a: 1, b: 2, c: "Hello, World!" };
    const struct_val = addon.round_trip_struct(obj);
    expect(struct_val.a).toEqual(obj.a + 1);
    expect(struct_val.b).toEqual(obj.b + 1);
    expect(struct_val.c).toEqual("Hello, World!");
  })

  test('passes `*StructPtr` as Wrapped Object', () => {
    const wrapped = addon.wrapped_struct(100, BigInt(2000));
    expect(typeof wrapped).toBe('object');
    expect(addon.wrapped_struct_get_a(wrapped)).toEqual(100);
    expect(addon.wrapped_struct_get_b(wrapped)).toEqual(BigInt(2000));
  })
})