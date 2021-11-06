// temp.cielo
var main, testDir;

import {
  log
} from '@jdeighan/coffee-utils/log';

import {
  mydir,
  forEachFile
} from '@jdeighan/coffee-utils/fs';

import {
  debug,
  setDebugging,
  checkTraceFile
} from '@jdeighan/coffee-utils/debug';

testDir = mydir(import.meta.url);

// ---------------------------------------------------------------------------
main = function() {
  return checkTraceFile("c:/Users/johnd/coffee-utils/test/temp.txt");
};

// ---------------------------------------------------------------------------
main();
