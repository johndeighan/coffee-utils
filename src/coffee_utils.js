// Generated by CoffeeScript 2.5.1
// coffee_utils.coffee
var commentRegexp;

import {
  strict as assert
} from 'assert';

import {
  log
} from '@jdeighan/coffee-utils/log';

export var sep_dash = '-'.repeat(42);

export var sep_eq = '='.repeat(42);

export const undef = undefined;

// ---------------------------------------------------------------------------
//   say - print to the console (for now)
//         later, on a web page, call alert(str)
export var say = function(str, obj = undef) {
  log(str, obj);
};

// ---------------------------------------------------------------------------
//   pass - do nothing
export var pass = function() {};

// ---------------------------------------------------------------------------
//   error - throw an error
export var error = function(message) {
  throw new Error(message);
};

// ---------------------------------------------------------------------------
//   croak - throws an error after possibly printing useful info
export var croak = function(err, label, obj) {
  var message;
  message = (typeof err === 'object') ? err.message : err;
  log(`ERROR: ${message}`);
  log(label, obj);
  if (typeof err === 'object') {
    throw err;
  } else {
    throw new Error(message);
  }
};

// ---------------------------------------------------------------------------
export var localStore = function(key, value = undef) {
  // --- if value is undef, returns the current value
  if (typeof localStorage === 'undefined') {
    return;
  }
  if (value != null) {
    localStorage.setItem(key, JSON.stringify(value));
  } else {
    value = localStorage.getItem(key);
    if (value != null) {
      return JSON.parse(localStorage.getItem(key));
    } else {
      return undef;
    }
  }
};

// ---------------------------------------------------------------------------
export var getClassName = function(obj) {
  if (typeof obj !== 'object') {
    return undef;
  }
  return obj.constructor.name;
};

// ---------------------------------------------------------------------------
export var isString = function(x) {
  return typeof x === 'string' || x instanceof String;
};

// ---------------------------------------------------------------------------
export var isNumber = function(x) {
  return typeof x === 'number' || x instanceof Number;
};

// ---------------------------------------------------------------------------
export var isObject = function(x) {
  return (typeof x === 'object') && !isString(x) && !isArray(x) && !isHash(x) && !isNumber(x);
};

// ---------------------------------------------------------------------------
export var isArray = function(x) {
  return Array.isArray(x);
};

// ---------------------------------------------------------------------------
export var isHash = function(x) {
  return getClassName(x) === 'Object';
};

// ---------------------------------------------------------------------------
//   isEmpty
//      - string is whitespace, array has no elements, hash has no keys
export var isEmpty = function(x) {
  if (x == null) {
    return true;
  }
  if (isString(x)) {
    return x.match(/^\s*$/);
  }
  if (isArray(x)) {
    return x.length === 0;
  }
  if (isHash(x)) {
    return Object.keys(x).length === 0;
  } else {
    return error("isEmpty(): Invalid parameter");
  }
};

// ---------------------------------------------------------------------------
//   nonEmpty
//      - string has non-whitespace, array has elements, hash has keys
export var nonEmpty = function(x) {
  if (x == null) {
    return false;
  }
  if (isString(x)) {
    return !x.match(/^\s*$/);
  }
  if (isArray(x)) {
    return x.length > 0;
  }
  if (isHash(x)) {
    return Object.keys(x).length > 0;
  } else {
    return error("isEmpty(): Invalid parameter");
  }
};

// ---------------------------------------------------------------------------
commentRegexp = /^\s*\#+(?:\s|$)/;

// ---------------------------------------------------------------------------
export var setCommentRegexp = function(regexp) {
  commentRegexp = regexp;
};

// ---------------------------------------------------------------------------
export var isComment = function(str) {
  if (str.match(commentRegexp)) {
    return true;
  } else {
    return false;
  }
};

// ---------------------------------------------------------------------------
export var words = function(str) {
  return str.trim().split(/\s+/);
};

// ---------------------------------------------------------------------------
export var isArrayOfHashes = function(lItems) {
  var i, item, len1;
  if (!isArray(lItems)) {
    return false;
  }
  for (i = 0, len1 = lItems.length; i < len1; i++) {
    item = lItems[i];
    if (!isHash(item)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isArrayOfStrings = function(lItems) {
  var i, item, len1;
  if (!isArray(lItems)) {
    return false;
  }
  for (i = 0, len1 = lItems.length; i < len1; i++) {
    item = lItems[i];
    if (!isString(item)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isFunction = function(x) {
  return typeof x === 'function';
};

// ---------------------------------------------------------------------------
export var isRegExp = function(x) {
  return x instanceof RegExp;
};

// ---------------------------------------------------------------------------
export var isInteger = function(x) {
  if (typeof x === 'number') {
    return Number.isInteger(x);
  } else if (getClassName(x) === 'Number') {
    return Number.isInteger(x.valueOf());
  } else {
    return false;
  }
};

// ---------------------------------------------------------------------------
//   warn - issue a warning
export var warn = function(message) {
  return log(`WARNING: ${message}`);
};

// ---------------------------------------------------------------------------
//   ask - ask a question
//         later, on a web page, prompt the user for answer to question
export var ask = function(prompt) {
  return 'yes';
};

// ---------------------------------------------------------------------------
export var firstLine = function(input) {
  var pos;
  if (isArray(input)) {
    if (input.length === 0) {
      return undef;
    }
    return input[0];
  }
  assert(isString(input), "firstLine(): Not an array or string");
  pos = input.indexOf('\n');
  if (pos === -1) {
    return input;
  } else {
    return input.substring(0, pos);
  }
};

// ---------------------------------------------------------------------------
//   stringToArray - split a string into lines
export var stringToArray = function(str) {
  var lLines, len;
  if (isEmpty(str)) {
    return [];
  } else {
    lLines = str.split(/\r?\n/);
    len = lLines.length;
    while ((len > 0) && isEmpty(lLines[len - 1])) {
      lLines.pop();
      len -= 1;
    }
    return lLines;
  }
};

// ---------------------------------------------------------------------------
//   arrayToString - every line has trailing newline
export var arrayToString = function(lLines) {
  if (lLines.length === 0) {
    return '';
  } else {
    return rtrim(lLines.join('\n'));
  }
};

// ---------------------------------------------------------------------------
//   normalize - remove blank lines, trim each line
//             - collapse internal whitespace to ' '
export var normalize = function(content) {
  var lLines, line;
  if (typeof content !== 'string') {
    throw new Error("normalize(): not a string");
  }
  lLines = (function() {
    var i, len1, ref, results;
    ref = stringToArray(content);
    results = [];
    for (i = 0, len1 = ref.length; i < len1; i++) {
      line = ref[i];
      line = line.trim();
      results.push(line.replace(/\s+/g, ' '));
    }
    return results;
  })();
  lLines = lLines.filter(function(line) {
    return line !== '';
  });
  return lLines.join('\n');
};

// ---------------------------------------------------------------------------
export var titleLine = function(title, char = '=', padding = 2, linelen = 42) {
  var nLeft, nRight, strLeft, strMiddle, strRight, titleLen;
  // --- used in logger
  if (!title) {
    return char.repeat(linelen);
  }
  titleLen = title.length + 2 * padding;
  nLeft = Math.floor((linelen - titleLen) / 2);
  nRight = linelen - nLeft - titleLen;
  strLeft = char.repeat(nLeft);
  strMiddle = ' '.repeat(padding) + title + ' '.repeat(padding);
  strRight = char.repeat(nRight);
  return strLeft + strMiddle + strRight;
};

// ---------------------------------------------------------------------------
//   rtrim - strip trailing whitespace
export var rtrim = function(line) {
  var lMatches, n;
  lMatches = line.match(/\s+$/);
  if (lMatches != null) {
    n = lMatches[0].length; // num chars to remove
    return line.substring(0, line.length - n);
  } else {
    return line;
  }
};

// ---------------------------------------------------------------------------
//   rtrunc - strip nChars chars from right of a string
export var rtrunc = function(str, nChars) {
  return str.substring(0, str.length - nChars);
};

// ---------------------------------------------------------------------------
//   ltrunc - strip nChars chars from left of a string
export var ltrunc = function(str, nChars) {
  return str.substring(nChars);
};

// ---------------------------------------------------------------------------
//   deepCopy - deep copy an array or object
export var deepCopy = function(obj) {
  return JSON.parse(JSON.stringify(obj));
};

// ---------------------------------------------------------------------------
//   escapeStr - escape newlines, TAB chars, etc.
export var escapeStr = function(str) {
  var ch, lParts;
  if (str == null) {
    return 'undef';
  }
  if (typeof str !== 'string') {
    croak("escapeStr(): not a string", str, 'STRING');
  }
  lParts = (function() {
    var i, len1, ref, results;
    ref = str.split('');
    results = [];
    for (i = 0, len1 = ref.length; i < len1; i++) {
      ch = ref[i];
      if (ch === '\n') {
        results.push('\\n');
      } else if (ch === '\t') {
        results.push('\\t');
      } else {
        results.push(ch);
      }
    }
    return results;
  })();
  return lParts.join('');
};

// ---------------------------------------------------------------------------
export var oneline = function(obj) {
  if (obj != null) {
    if (isString(obj)) {
      return `'${escapeStr(obj)}'`;
    } else {
      return JSON.stringify(obj);
    }
  } else {
    return 'undef';
  }
};

export var OL = oneline;

// ---------------------------------------------------------------------------
// truncateBlock - limit block to a certain number of lines
export var truncateBlock = function(str, numLines) {
  var lLines;
  lLines = stringToArray(str);
  lLines.length = numLines;
  return arrayToString(lLines);
};

// ---------------------------------------------------------------------------
export var removeCR = function(block) {
  return block.replace(/\r/g, '');
};

// ---------------------------------------------------------------------------
export var splitBlock = function(block) {
  var pos;
  block = removeCR(block);
  if (pos = block.indexOf("\n")) {
    // --- pos is also the length of the 1st line
    //     2nd arg to substr() is number of characters to return
    return [block.substr(0, pos), block.substr(pos + 1)];
  } else {
    return [block, ''];
  }
};

// ---------------------------------------------------------------------------
export var CWS = function(block) {
  return block.trim().replace(/\s+/g, ' ');
};

// ---------------------------------------------------------------------------
