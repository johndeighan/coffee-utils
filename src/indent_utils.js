// Generated by CoffeeScript 2.5.1
  // indent_utils.coffee
import {
  strict as assert
} from 'assert';

import {
  undef,
  error,
  arrayToString,
  stringToArray,
  escapeStr,
  oneline,
  isInteger,
  isString,
  isArray
} from '@jdeighan/coffee-utils';

// ---------------------------------------------------------------------------
//        NOTE: Currently, only TAB indentation is supported
// ---------------------------------------------------------------------------
//   splitLine - separate a line into {level, line}
export var splitLine = function(line) {
  var lMatches;
  if (line == null) {
    throw new Error("splitLine(): line is undef");
  }
  if (typeof line !== 'string') {
    throw new Error("splitLine(): line is not a string");
  }
  lMatches = line.match(/^(\s*)(.*)$/);
  return [lMatches[1].length, lMatches[2].trim()];
};

// ---------------------------------------------------------------------------
//   indentation - return appropriate indentation string for given level
//   export only to allow unit testing
export var indentation = function(level) {
  return '\t'.repeat(level);
};

// ---------------------------------------------------------------------------
//   indentLevel - determine indent level of a string
export var indentLevel = function(str) {
  var lMatches;
  lMatches = /^\t*/.exec(str);
  return lMatches[0].length;
};

// ---------------------------------------------------------------------------
//   indented - add indentation to each string in a block
export var indented = function(input, level = 0) {
  var lLines, line, toAdd;
  if (level === 0) {
    return input;
  }
  toAdd = indentation(level);
  if (isArray(input)) {
    lLines = (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = input.length; i < len; i++) {
        line = input[i];
        results.push(`${toAdd}${line}`);
      }
      return results;
    })();
    return lLines;
  } else {
    lLines = (function() {
      var i, len, ref, results;
      ref = stringToArray(input);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        line = ref[i];
        results.push(`${toAdd}${line}`);
      }
      return results;
    })();
    return arrayToString(lLines);
  }
};

// ---------------------------------------------------------------------------
//   undented - string with 1st line indentation removed for each line
//            - unless level is set, in which case exactly that
//              indentation is removed
export var undented = function(input, level = undef) {
  var lLines, lMatches, lNewLines, line, nToRemove, toRemove;
  if ((level != null) && (level === 0)) {
    return input;
  }
  if (isString(input)) {
    lLines = stringToArray(input);
    if (lLines.length === 0) {
      return '';
    }
  } else if (isArray(input)) {
    lLines = input;
    if (lLines.length === 0) {
      return [];
    }
  } else {
    error(`undented(): Not an array or string: ${oneline(input)}`);
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
  lNewLines = (function() {
    var i, len, results;
    results = [];
    for (i = 0, len = lLines.length; i < len; i++) {
      line = lLines[i];
      assert(line.indexOf(toRemove) === 0, `undented(): '${escapeStr(line)}' does not start with '${escapeStr(toRemove)}'`);
      results.push(line.substr(nToRemove));
    }
    return results;
  })();
  if (isString(input)) {
    return arrayToString(lNewLines);
  } else {
    return lNewLines;
  }
};

// ---------------------------------------------------------------------------
//    tabify - convert leading spaces to TAB characters
//             if numSpaces is not defined, then the first line
//             that contains at least one space sets it
export var tabify = function(str, numSpaces = undef) {
  var _, i, lLines, lMatches, len, n, prefix, ref, theRest;
  lLines = [];
  ref = stringToArray(str);
  for (i = 0, len = ref.length; i < len; i++) {
    str = ref[i];
    lMatches = str.match(/^(\s*)(.*)$/);
    [_, prefix, theRest] = lMatches;
    if (prefix === '') {
      lLines.push(theRest);
    } else {
      n = prefix.length;
      if (prefix.indexOf('\t') !== -1) {
        error("tabify(): leading TAB characters not allowed");
      }
      if (numSpaces == null) {
        numSpaces = n;
      }
      if (n % numSpaces !== 0) {
        error("tabify(): Invalid # of leading space chars");
      }
      lLines.push('\t'.repeat(n / numSpaces) + theRest);
    }
  }
  return arrayToString(lLines);
};

// ---------------------------------------------------------------------------
//    untabify - convert leading TABs to spaces
export var untabify = function(str, numSpaces = 3) {
  var _, i, lLines, lMatches, len, n, prefix, ref, theRest;
  lLines = [];
  ref = stringToArray(str);
  for (i = 0, len = ref.length; i < len; i++) {
    str = ref[i];
    lMatches = str.match(/^(\s*)(.*)$/);
    [_, prefix, theRest] = lMatches;
    if (prefix === '') {
      lLines.push(theRest);
    } else {
      n = prefix.length;
      if (prefix !== '\t'.repeat(n)) {
        error(`untabify(): not all TABs: prefix='${escapeStr(prefix)}'`);
      }
      lLines.push(' '.repeat(n * numSpaces) + theRest);
    }
  }
  return arrayToString(lLines);
};
