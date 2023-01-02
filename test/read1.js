// Generated by CoffeeScript 2.7.0
// read1.coffee
var block, filepath, lLines;

import fs from 'fs';

import readline from 'readline';

import {
  undef,
  LOG,
  LOGVALUE
} from '@jdeighan/coffee-utils';

import {
  arrayToBlock
} from '@jdeighan/coffee-utils/block';

import {
  slurp,
  forEachLine
} from '@jdeighan/coffee-utils/fs';

// ---------------------------------------------------------------------------
filepath = 'c:/Users/johnd/coffee-utils/test/temp.txt';

console.time('func');

lLines = [];

await forEachLine(filepath, function(line, lineNum) {
  lLines.push(line);
  if (lineNum >= 10) {
    return 'EOF';
  }
});

console.timeEnd('func');

block = arrayToBlock(lLines);

LOGVALUE('block', block);