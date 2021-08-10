// Generated by CoffeeScript 2.5.1
  // indent_utils.coffee
import {
  undef,
  error,
  arrayToString
} from './coffee_utils.js';

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
//   indentedStr - add indentation to a string
export var indentedStr = function(str, level = 0) {
  if (typeof str !== 'string') {
    throw new Error("indentedStr(): not a string");
  }
  return indentation(level) + str;
};

// ---------------------------------------------------------------------------
//   indentation - return appropriate indentation string for given level
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
//   undentedStr - remove indentation from a simple string
//                 i.e. it should NOT include any newline chars
//      if level is provided, only that level of indentation is removed
export var undentedStr = function(str, level = undef) {
  var lMatches;
  if (level != null) {
    return str.substring(level);
  } else {
    // --- this will always match
    lMatches = str.match(/^\s*(.*)$/);
    return lMatches[1];
  }
};

// ---------------------------------------------------------------------------
//   undentedBlock - string with 1st line indentation removed for each line
//            - you can pass in an array, but result is always a string
export var undentedBlock = function(strOrArray) {
  var isType, lLines, lMatches, lStripped, prefix, prefixLen, str;
  if (strOrArray == null) {
    return '';
  }
  isType = typeof strOrArray;
  if (isType === 'object') {
    lLines = strOrArray; // it's really an array
    if (lLines.length === 0) {
      return '';
    }
    // --- Check for a prefix on the 1st line
    lMatches = lLines[0].match(/^(\s+)/);
    if (lMatches == null) {
      return arrayToString(lLines);
    }
    prefix = lMatches[1];
    prefixLen = prefix.length;
    lStripped = (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = lLines.length; i < len; i++) {
        str = lLines[i];
        if (str.indexOf(prefix) === 0) {
          results.push(str.substring(prefixLen));
        } else {
          results.push(str);
        }
      }
      return results;
    })();
    return arrayToString(lStripped);
  } else if (isType === 'string') {
    // --- It's a string - split, undent, then reassemble
    return undentedBlock(strOrArray.split(/\r?\n/));
  } else {
    throw new Error(`undentedBlock(): ${isType} is not an array or string`);
  }
};

// ---------------------------------------------------------------------------
//   indentedBlock - add indentation to each string in a block
export var indentedBlock = function(content, level = 0) {
  var indent, lLines, line, result;
  if (typeof content !== 'string') {
    error("indentedBlock(): not a string");
  }
  if (level === 0) {
    return content;
  }
  indent = '\t'.repeat(level);
  lLines = (function() {
    var i, len, ref, results;
    ref = content.split(/\r?\n/);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      line = ref[i];
      if (line) {
        results.push(`${indent}${line}`);
      } else {
        results.push("");
      }
    }
    return results;
  })();
  result = lLines.join('\n');
  return result;
};