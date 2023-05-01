import { expect, describe, test } from 'bun:test';
const addon = require('../zig-out/lib/example.node');

describe('NAPI - `string`', () => {
  const expected = 'Hello, World!';

  test('round trip `string`', () => {
    expect(addon.round_trip_string(expected)).toBe(expected);
  })

  test('concatenates `string`', () => {
    expect(addon.concat_strings('Hello, ', 'World', '!')).toBe(expected);
  })

  test('returns new `string`', () => {
    expect(addon.new_string()).toBe(expected);
  })
});