///////////////////////////////////////////////////////
// This file was auto-generated by zig-bindgen-js    //
//              Do not manually modify.              //
///////////////////////////////////////////////////////
const addon = import.meta.require('../zig-out/lib/example.node');

export const add = (a: number, b: number): number => {
	return addon.add(a, b);
}

