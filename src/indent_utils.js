// Generated by CoffeeScript 2.6.1
  // indent_utils.coffee
import {
  assert,
  undef,
  error,
  escapeStr,
  OL,
  isInteger,
  isString,
  isArray,
  isEmpty,
  rtrim
} from '@jdeighan/coffee-utils';

import {
  arrayToBlock,
  blockToArray
} from '@jdeighan/coffee-utils/block';

// ---------------------------------------------------------------------------
//        NOTE: Currently, only TAB indentation is supported
// ---------------------------------------------------------------------------
//   splitLine - separate a line into {level, line}
export var splitLine = function(line) {
  var lMatches;
  assert(line != null, "splitLine(): line is undef");
  assert(isString(line), "splitLine(): line is not a string");
  line = rtrim(line);
  lMatches = line.match(/^(\s*)(.*)$/);
  return [lMatches[1].length, lMatches[2]];
};

// ---------------------------------------------------------------------------
//   indentation - return appropriate indentation string for given level
//   export only to allow unit testing
export var indentation = function(level) {
  assert(level >= 0, "indentation(): negative level");
  return '\t'.repeat(level);
};

// ---------------------------------------------------------------------------
//   indentLevel - determine indent level of a string
//                 it's OK if the string is ONLY indentation
export var indentLevel = function(str) {
  var lMatches;
  assert(isString(str), "indentLevel(): not a string");
  lMatches = str.match(/^\t*/);
  return lMatches[0].length;
};

// ---------------------------------------------------------------------------
//   indented - add indentation to each string in a block
export var indented = function(input, level = 1) {
  var lInputLines, lLines, line, toAdd;
  assert(level >= 0, "indented(): negative level");
  if (level === 0) {
    return input;
  }
  toAdd = indentation(level);
  if (isArray(input)) {
    lInputLines = input;
  } else {
    lInputLines = blockToArray(input);
  }
  lLines = (function() {
    var i, len, results;
    results = [];
    for (i = 0, len = lInputLines.length; i < len; i++) {
      line = lInputLines[i];
      if (isEmpty(line)) {
        results.push("");
      } else {
        results.push(`${toAdd}${line}`);
      }
    }
    return results;
  })();
  return arrayToBlock(lLines);
};

// ---------------------------------------------------------------------------
//   undented - string with 1st line indentation removed for each line
//            - unless level is set, in which case exactly that
//              indentation is removed
//            - returns same type as text, i.e. either string or array
export var undented = function(text, level = undef) {
  var i, j, lLines, lMatches, lNewLines, len, len1, line, nToRemove, toRemove;
  if ((level != null) && (level === 0)) {
    return text;
  }
  if (isString(text)) {
    lLines = blockToArray(text);
    if (lLines.length === 0) {
      return '';
    }
  } else if (isArray(text)) {
    lLines = text;
    for (i = 0, len = lLines.length; i < len; i++) {
      line = lLines[i];
      assert(isString(line), "undented(): input array is not all strings");
    }
    if (lLines.length === 0) {
      return [];
    }
  } else {
    error(`undented(): Not an array or string: ${OL(text)}`);
  }
  // --- determine what to remove from beginning of each line
  if (level != null) {
    assert(isInteger(level), "undented(): level must be an integer");
    toRemove = indentation(level);
  } else {
    lMatches = lLines[0].match(/^\s*/);
    toRemove = lMatches[0];
  }
  nToRemove = toRemove.length;
  lNewLines = [];
  for (j = 0, len1 = lLines.length; j < len1; j++) {
    line = lLines[j];
    if (isEmpty(line)) {
      lNewLines.push('');
    } else {
      assert(line.indexOf(toRemove) === 0, `undented(): Error removing '${escapeStr(toRemove)}' from ${OL(text)}`);
      lNewLines.push(line.substr(nToRemove));
    }
  }
  if (isString(text)) {
    return arrayToBlock(lNewLines);
  } else {
    return lNewLines;
  }
};

// ---------------------------------------------------------------------------
//    tabify - convert leading spaces to TAB characters
//             if numSpaces is not defined, then the first line
//             that contains at least one space sets it
export var tabify = function(str, numSpaces = undef) {
  var _, i, lLines, len, prefix, prefixLen, ref, theRest;
  lLines = [];
  ref = blockToArray(str);
  for (i = 0, len = ref.length; i < len; i++) {
    str = ref[i];
    [_, prefix, theRest] = str.match(/^(\s*)(.*)$/);
    prefixLen = prefix.length;
    if (prefixLen === 0) {
      lLines.push(theRest);
    } else {
      if (prefix.indexOf('\t') !== -1) {
        error("tabify(): leading TAB characters not allowed");
      }
      if (numSpaces === undef) {
        numSpaces = prefixLen;
      }
      assert(prefixLen % numSpaces === 0, "Bad prefix");
      lLines.push('\t'.repeat(prefixLen) + theRest);
    }
  }
  return arrayToBlock(lLines);
};

// ---------------------------------------------------------------------------
//    untabify - convert ALL TABs to spaces
export var untabify = function(str, numSpaces = 3) {
  return str.replace(/\t/g, ' '.repeat(numSpaces));
};
