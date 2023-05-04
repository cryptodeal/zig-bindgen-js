import { expect, describe, test } from 'bun:test';
const addon = require('../zig-out/lib/example.node');

describe('NAPI - Object', () => {
  test('returns Zig `struct` as JS `object`', () => {
    const struct_val = addon.returns_struct();
    expect(struct_val).toEqual({ a: 1, b: 2, c: "Hello, World!" });
  })
})