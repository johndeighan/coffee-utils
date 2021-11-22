// Generated by CoffeeScript 2.6.1
// coffee_utils.coffee
var commentRegExp;

import getline from 'readline-sync';

import {
  log
} from '@jdeighan/coffee-utils/log';

export var sep_dash = '-'.repeat(42);

export var sep_eq = '='.repeat(42);

export const undef = undefined;

// ---------------------------------------------------------------------------
//   pass - do nothing
export var pass = function() {};

// ---------------------------------------------------------------------------
//   error - throw an error
export var error = function(message) {
  throw new Error(message);
};

// ---------------------------------------------------------------------------
//   assert - mimic nodejs's assert
export var assert = function(cond, msg) {
  if (!cond) {
    error(msg);
  }
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
commentRegExp = /^\s*\#+(?:\s|$)/;

// ---------------------------------------------------------------------------
export var setCommentRegexp = function(regexp) {
  commentRegExp = regexp;
};

// ---------------------------------------------------------------------------
export var isComment = function(str) {
  if (str.match(commentRegExp)) {
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
  var i, item, len;
  if (!isArray(lItems)) {
    return false;
  }
  for (i = 0, len = lItems.length; i < len; i++) {
    item = lItems[i];
    if (!isHash(item)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isArrayOfStrings = function(lItems) {
  var i, item, len;
  if (!isArray(lItems)) {
    return false;
  }
  for (i = 0, len = lItems.length; i < len; i++) {
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
//   say - print to the console (for now)
//         later, on a web page, call alert(str)
export var say = function(str) {
  console.log(str);
};

// ---------------------------------------------------------------------------
//   ask - ask a question
//         later, on a web page, prompt the user for answer to question
export var ask = function(prompt) {
  var answer;
  answer = getline.question("{prompt}? ");
  return answer;
};

// ---------------------------------------------------------------------------
export var titleLine = function(title, char = '=', padding = 2, linelen = 42) {
  var nLeft, nRight, strLeft, strMiddle, strRight, titleLen;
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
export var escapeStr = function(str, hEscape = undef) {
  var ch, lParts;
  if (!isString(str)) {
    croak("escapeStr(): not a string", str, 'STRING');
  }
  if (hEscape != null) {
    lParts = (function() {
      var i, len, ref, results;
      ref = str.split('');
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        ch = ref[i];
        if (hEscape[ch] != null) {
          results.push(hEscape[ch]);
        } else {
          results.push(ch);
        }
      }
      return results;
    })();
  } else {
    lParts = (function() {
      var i, len, ref, results;
      ref = str.split('');
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
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
  }
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
export var removeCR = function(str) {
  return str.replace(/\r/g, '');
};

// ---------------------------------------------------------------------------
export var CWS = function(str) {
  assert(isString(str), "CWS(): parameter not a string");
  return str.trim().replace(/\s+/sg, ' ');
};

// ---------------------------------------------------------------------------
export var extractMatches = function(line, regexp, convertFunc = undef) {
  var lConverted, lStrings, str;
  lStrings = [...line.matchAll(regexp)];
  lStrings = (function() {
    var i, len, results;
    results = [];
    for (i = 0, len = lStrings.length; i < len; i++) {
      str = lStrings[i];
      results.push(str[0]);
    }
    return results;
  })();
  if (convertFunc != null) {
    lConverted = (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = lStrings.length; i < len; i++) {
        str = lStrings[i];
        results.push(convertFunc(str));
      }
      return results;
    })();
    return lConverted;
  } else {
    return lStrings;
  }
};

// ---------------------------------------------------------------------------
