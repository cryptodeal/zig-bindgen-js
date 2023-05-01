import { expect, describe, test } from 'bun:test';
const addon = require('../zig-out/lib/example.node');

describe('NAPI - `boolean`', () => {
  test('returns `boolean`', () => {
    expect(addon.bool_true()).toBe(true);
    expect(addon.bool_false()).toBe(false);
  })

  test('returns negated `boolean`', () => {
    expect(addon.negate_bool(true)).toBe(false);
    expect(addon.negate_bool(false)).toBe(true);
  })
})