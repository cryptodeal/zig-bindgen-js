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
})