// Generated by CoffeeScript 2.7.0
  // indent_utils.coffee
import {
  assert,
  undef,
  error,
  escapeStr,
  defined,
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
export var splitPrefix = function(line) {
  var lMatches;
  assert(isString(line), `non-string ${OL(line)}`);
  line = rtrim(line);
  lMatches = line.match(/^(\s*)(.*)$/);
  return [lMatches[1], lMatches[2]];
};

// ---------------------------------------------------------------------------
//   splitLine - separate a line into [level, line]
export var splitLine = function(line, oneIndent = "\t") {
  var prefix, str;
  [prefix, str] = splitPrefix(line);
  return [indentLevel(prefix, oneIndent), str];
};

// ---------------------------------------------------------------------------
//   indentation - return appropriate indentation string for given level
//   export only to allow unit testing
export var indentation = function(level, oneIndent = "\t") {
  assert(level >= 0, "indentation(): negative level");
  return oneIndent.repeat(level);
};

// ---------------------------------------------------------------------------
//   indentLevel - determine indent level of a string
//                 it's OK if the string is ONLY indentation
export var indentLevel = function(line, oneIndent = "\t") {
  var lMatches, len, level, prefix, prefixLen, remain;
  len = oneIndent.length;
  // --- This will always match
  if (lMatches = line.match(/^(\s*)/)) {
    prefix = lMatches[1];
    prefixLen = prefix.length;
  }
  remain = prefixLen % len;
  if (remain !== 0) {
    throw new Error(`prefix ${OL(prefix)} not a mult of ${OL(oneIndent)}`);
  }
  level = prefixLen / len;
  if (prefix !== oneIndent.repeat(level)) {
    throw new Error(`prefix ${OL(prefix)} not a mult of ${OL(oneIndent)}`);
  }
  return level;
};

// ---------------------------------------------------------------------------
//   isUndented - true iff indentLevel(line) == 0
export var isUndented = function(line) {
  var lMatches;
  assert(isString(line), `non-string ${OL(line)}`);
  lMatches = line.match(/^\s*/);
  return lMatches[0].length === 0;
};

// ---------------------------------------------------------------------------
//   indented - add indentation to each string in a block
export var indented = function(input, level = 1, oneIndent = "\t") {
  var lInputLines, lLines, line, toAdd;
  assert(level >= 0, "indented(): negative level");
  if (level === 0) {
    return input;
  }
  toAdd = indentation(level, oneIndent);
  if (isArray(input)) {
    lInputLines = input;
  } else {
    lInputLines = blockToArray(input);
  }
  lLines = (function() {
    var i, len1, results;
    results = [];
    for (i = 0, len1 = lInputLines.length; i < len1; i++) {
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
export var undented = function(text, level = undef, oneIndent = "\t") {
  var i, j, lLines, lMatches, lNewLines, len1, len2, line, nToRemove, toRemove;
  if (defined(level) && (level === 0)) {
    return text;
  }
  if (isString(text)) {
    lLines = blockToArray(text);
    if (lLines.length === 0) {
      return '';
    }
  } else if (isArray(text)) {
    lLines = text;
    for (i = 0, len1 = lLines.length; i < len1; i++) {
      line = lLines[i];
      assert(isString(line), "undented(): array not all strings");
    }
    if (lLines.length === 0) {
      return [];
    }
  } else {
    error(`undented(): Not an array or string: ${OL(text)}`);
  }
  // --- determine what to remove from beginning of each line
  if (defined(level)) {
    assert(isInteger(level), "undented(): level must be an integer");
    toRemove = indentation(level, oneIndent);
  } else {
    lMatches = lLines[0].match(/^\s*/);
    toRemove = lMatches[0];
  }
  nToRemove = indentLevel(toRemove);
  lNewLines = [];
  for (j = 0, len2 = lLines.length; j < len2; j++) {
    line = lLines[j];
    if (isEmpty(line)) {
      lNewLines.push('');
    } else {
      if (line.indexOf(toRemove) !== 0) {
        throw new Error(`remove ${OL(toRemove)} from ${OL(text)}`);
      }
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
  var _, i, lLines, len1, level, prefix, prefixLen, ref, result, theRest;
  lLines = [];
  ref = blockToArray(str);
  for (i = 0, len1 = ref.length; i < len1; i++) {
    str = ref[i];
    [_, prefix, theRest] = str.match(/^(\s*)(.*)$/);
    prefixLen = prefix.length;
    if (prefixLen === 0) {
      lLines.push(theRest);
    } else {
      assert(prefix.indexOf('\t') === -1, "found TAB");
      if (numSpaces === undef) {
        numSpaces = prefixLen;
      }
      assert(prefixLen % numSpaces === 0, "Bad prefix");
      level = prefixLen / numSpaces;
      lLines.push('\t'.repeat(level) + theRest);
    }
  }
  result = arrayToBlock(lLines);
  return result;
};

// ---------------------------------------------------------------------------
//    untabify - convert ALL TABs to spaces
export var untabify = function(str, numSpaces = 3) {
  return str.replace(/\t/g, ' '.repeat(numSpaces));
};

// ---------------------------------------------------------------------------
//    enclose - indent text, surround with pre and post
export var enclose = function(text, pre, post) {
  return pre + "\n" + indented(text) + "\n" + post;
};
