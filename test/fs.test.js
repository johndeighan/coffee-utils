// Generated by CoffeeScript 2.5.1
// fs.test.coffee
var tester;

import {
  withExt
} from '../fs_utils.js';

import {
  AvaTester
} from '@jdeighan/ava-tester';

tester = new AvaTester();

// ---------------------------------------------------------------------------
tester.equal(75, withExt('file.starbucks', 'svelte'), 'file.svelte');
