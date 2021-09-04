// Generated by CoffeeScript 2.5.1
  // temp.coffee
import {
  say,
  undef,
  sep_eq
} from '@jdeighan/coffee-utils';

import {
  forEachLine,
  forEachBlock,
  forEachSetOfBlocks
} from '@jdeighan/coffee-utils/block';

// ---------------------------------------------------------------------------
(async function() {
  var callback, filepath;
  filepath = "c:/Users/johnd/coffee-utils/test/data/file2.txt";
  callback = function(line, lineNum) {
    console.log(`[${lineNum}] '${line}'`);
  };
  await forEachLine(filepath, callback);
  return say(sep_eq);
});

// ---------------------------------------------------------------------------
(async function() {
  var callback, filepath;
  filepath = "c:/Users/johnd/coffee-utils/test/data/file3.txt";
  callback = function(block, lineNum) {
    console.log(`[${lineNum}] ----------------`);
    console.log(block);
  };
  await forEachBlock(filepath, callback);
  return say(sep_eq);
});

// ---------------------------------------------------------------------------
(async function() {
  var callback, filepath;
  filepath = "c:/Users/johnd/coffee-utils/test/data/file4.txt";
  callback = function(lBlocks, lineNum) {
    var block, i, len;
    console.log(`[${lineNum}] ================`);
    for (i = 0, len = lBlocks.length; i < len; i++) {
      block = lBlocks[i];
      console.log(block);
      console.log('-'.repeat(8));
    }
  };
  await forEachSetOfBlocks(filepath, callback);
  return say(sep_eq);
})();

// ---------------------------------------------------------------------------
