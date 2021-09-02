// Generated by CoffeeScript 2.5.1
  // block_utils.coffee
import {
  existsSync,
  readFileSync,
  createReadStream
} from 'fs';

import {
  createInterface
} from 'readline';

import {
  say,
  isEmpty,
  nonEmpty,
  error
} from '@jdeighan/coffee-utils';


export async function forEachLine(filepath, func) {

const fileStream = createReadStream(filepath);
const rl = createInterface({
	input: fileStream,
	crlfDelay: Infinity
	});

// Note: we use the crlfDelay option to recognize all instances of CR LF
// ('\r\n') in input.txt as a single line break.

var lineNum = 0
for await (const line of rl) {
	lineNum += 1
	// Each line will be successively available here as 'line'
	if (func(line, lineNum)) {
		rl.close();      // close if true return value
		return;
		}
	}
} // forEachLine()
// ---------------------------------------------------------------------------
;

// ---------------------------------------------------------------------------
export var forEachBlock = async function(filepath, func, regexp = /^-{16,}$/) {
  var callback, earlyExit, firstLineNum, lLines;
  lLines = [];
  firstLineNum = 1;
  earlyExit = false;
  callback = function(line, lineNum) {
    var result;
    if (line.match(regexp)) {
      if (result = func(lLines.join('\n'), firstLineNum, line)) {
        if (result === true) {
          earlyExit = true;
          return true;
        } else if (result != null) {
          error(`forEachBlock() - callback returned '${result}'`);
        }
      }
      lLines = [];
      firstLineNum = lineNum + 1;
    } else {
      lLines.push(line);
    }
  };
  await forEachLine(filepath, callback);
  if (!earlyExit) {
    func(lLines.join('\n'), firstLineNum);
  }
};

// ---------------------------------------------------------------------------
export var forEachSetOfBlocks = async function(filepath, func, block_regexp = /^-{16,}$/, set_regexp = /^={16,}$/) {
  var callback, earlyExit, firstLineNum, lBlocks, lLines;
  lBlocks = [];
  lLines = [];
  firstLineNum = 1;
  earlyExit = false;
  callback = function(line, lineNum) {
    var result;
    if (line.match(set_regexp)) {
      lBlocks.push(lLines.join('\n'));
      lLines = [];
      if (result = func(lBlocks, firstLineNum, line)) {
        if (result === true) {
          earlyExit = true;
          return true;
        } else if (result != null) {
          error(`forEachSetOfBlocks() - callback returned '${result}'`);
        }
      }
      lBlocks = [];
      firstLineNum = lineNum + 1;
    } else if (line.match(block_regexp)) {
      lBlocks.push(lLines.join('\n'));
      lLines = [];
    } else {
      lLines.push(line);
    }
  };
  await forEachLine(filepath, callback);
  if (!earlyExit) {
    lBlocks.push(lLines.join('\n'));
    func(lBlocks, firstLineNum);
  }
};