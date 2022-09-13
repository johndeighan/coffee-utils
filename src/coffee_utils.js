// Generated by CoffeeScript 2.7.0
// coffee_utils.coffee
var LOG;

import {
  assert,
  error,
  croak
} from '@jdeighan/unit-tester/utils';

export var sep_dash = '-'.repeat(42);

export var sep_eq = '='.repeat(42);

export const undef = undefined;

LOG = function(...lArgs) {
  return console.log(...lArgs); // synonym for console.log()
};


// ---------------------------------------------------------------------------
// TEMP!!!!!
export var isComment = function(line) {
  var lMatches;
  lMatches = line.match(/^\s*\#(\s|$)/);
  return defined(lMatches);
};

// ---------------------------------------------------------------------------
export var chomp = function(str) {
  var len, tail;
  len = str.length;
  if (len === 0) {
    return '';
  } else if (len === 1) {
    if ((str === "\r") || (str === "\n")) {
      return '';
    } else {
      return str;
    }
  } else {
    // --- check the last 2 characters
    tail = str.substring(len - 2);
    if (tail === "\r\n") {
      return str.substring(0, len - 2);
    } else {
      tail = str.substring(len - 1);
      if (tail === "\n") {
        return str.substring(0, len - 1);
      } else {
        return str;
      }
    }
  }
};

// ---------------------------------------------------------------------------
export var isSubclassOf = function(subClass, superClass) {
  return (subClass === superClass) || (subClass.prototype instanceof superClass);
};

// ---------------------------------------------------------------------------
export var eval_expr = function(str) {
  str = str.replace(/\bundef\b/g, 'undefined');
  return Function('"use strict";return (' + str + ')')();
};

// ---------------------------------------------------------------------------
//   pass - do nothing
export var pass = function() {};

// ---------------------------------------------------------------------------
export var patchStr = function(bigstr, pos, str) {
  var endpos;
  endpos = pos + str.length;
  if (endpos < bigstr.length) {
    return bigstr.substring(0, pos) + str + bigstr.substring(endpos);
  } else {
    return bigstr.substring(0, pos) + str;
  }
};

// ---------------------------------------------------------------------------
export var charCount = function(str, ch) {
  var count, pos;
  count = 0;
  pos = str.indexOf(ch, 0);
  while (pos >= 0) {
    count += 1;
    pos = str.indexOf(ch, pos + 1);
  }
  return count;
};

// ---------------------------------------------------------------------------
export var oneof = function(word, ...lWords) {
  return lWords.indexOf(word) >= 0;
};

// ---------------------------------------------------------------------------
export var isConstructor = function(f) {
  var err;
  try {
    new f();
  } catch (error1) {
    err = error1;
    if (err.message.indexOf('is not a constructor') >= 0) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var jsType = function(x) {
  var lKeys;
  if (notdefined(x)) {
    return [undef, undef];
  } else if (isString(x)) {
    if (x.match(/^\s*$/)) {
      return ['string', 'empty'];
    } else {
      return ['string', undef];
    }
  } else if (isNumber(x)) {
    if (Number.isInteger(x)) {
      return ['number', 'integer'];
    } else {
      return ['number', undef];
    }
  } else if (isBoolean(x)) {
    return ['boolean', undef];
  } else if (isHash(x)) {
    lKeys = Object.keys(x);
    if (lKeys.length === 0) {
      return ['hash', 'empty'];
    } else {
      return ['hash', undef];
    }
  } else if (isArray(x)) {
    if (x.length === 0) {
      return ['array', 'empty'];
    } else {
      return ['array', undef];
    }
  } else if (isConstructor(x)) {
    return ['function', 'constructor'];
  } else if (isFunction(x)) {
    return ['function', undef];
  } else if (isObject(x)) {
    return ['object', undef];
  } else {
    return croak(`Unknown type: ${OL(x)}`);
  }
};

// ---------------------------------------------------------------------------
export var isString = function(x) {
  return (typeof x === 'string') || (x instanceof String);
};

// ---------------------------------------------------------------------------
export var isNonEmptyString = function(x) {
  if (typeof x !== 'string' && !(x instanceof String)) {
    return false;
  }
  if (x.match(/^\s*$/)) {
    return false;
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isBoolean = function(x) {
  return typeof x === 'boolean';
};

// ---------------------------------------------------------------------------
export var isObject = function(x) {
  return (typeof x === 'object') && !isString(x) && !isArray(x) && !isHash(x) && !isNumber(x);
};

// ---------------------------------------------------------------------------
export var getClassName = function(obj) {
  if (typeof obj !== 'object') {
    return undef;
  }
  return obj.constructor.name;
};

// ---------------------------------------------------------------------------
export var isArray = function(x) {
  return Array.isArray(x);
};

// ---------------------------------------------------------------------------
export var isNonEmptyArray = function(x) {
  return isArray(x) && (x.length > 0);
};

// ---------------------------------------------------------------------------
export var isHash = function(x, lKeys) {
  var i, key, len1;
  if (!x || (getClassName(x) !== 'Object')) {
    return false;
  }
  if (defined(lKeys)) {
    assert(isArray(lKeys), "isHash(): lKeys not an array");
    for (i = 0, len1 = lKeys.length; i < len1; i++) {
      key = lKeys[i];
      if (!x.hasOwnProperty(key)) {
        return false;
      }
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isNonEmptyHash = function(x) {
  return isHash(x) && (Object.keys(x).length > 0);
};

// ---------------------------------------------------------------------------
export var hashHasKey = function(x, key) {
  assert(isHash(x), "hashHasKey(): not a hash");
  assert(isString(key), "hashHasKey(): key not a string");
  return x.hasOwnProperty(key);
};

// ---------------------------------------------------------------------------
//   isEmpty
//      - string is whitespace, array has no elements, hash has no keys
export var isEmpty = function(x) {
  if ((x === undef) || (x === null)) {
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
    return false;
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
export var notInArray = function(lItems, item) {
  return lItems.indexOf(item) === -1;
};

// ---------------------------------------------------------------------------
export var pushCond = function(lItems, item, doPush = notInArray) {
  if (doPush(lItems, item)) {
    lItems.push(item);
    return true;
  } else {
    return false;
  }
};

// ---------------------------------------------------------------------------
export var words = function(str) {
  str = str.trim();
  if (str === '') {
    return [];
  }
  return str.split(/\s+/);
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
export var isNumber = function(x, hOptions = undef) {
  var max, min, result;
  result = (typeof x === 'number') || (x instanceof Number);
  if (result && defined(hOptions)) {
    assert(isHash(hOptions), `2nd arg not a hash: ${OL(hOptions)}`);
    ({min, max} = hOptions);
    if (defined(min) && (x < min)) {
      result = false;
    }
    if (defined(max) && (x > max)) {
      result = false;
    }
  }
  return result;
};

// ---------------------------------------------------------------------------
export var isInteger = function(x, hOptions = {}) {
  var result;
  if (typeof x === 'number') {
    result = Number.isInteger(x);
  } else if (x instanceof Number) {
    result = Number.isInteger(x.valueOf());
  } else {
    result = false;
  }
  if (result) {
    if (defined(hOptions.min) && (x < hOptions.min)) {
      result = false;
    }
    if (defined(hOptions.max) && (x > hOptions.max)) {
      result = false;
    }
  }
  return result;
};

// ---------------------------------------------------------------------------
export var isUniqueList = function(lItems, func = undef) {
  var h, i, item, len1;
  if (lItems == null) {
    return true; // empty list is unique
  }
  if (defined(func)) {
    assert(isFunction(func), `Not a function: ${OL(func)}`);
  }
  h = {};
  for (i = 0, len1 = lItems.length; i < len1; i++) {
    item = lItems[i];
    if (defined(func) && !func(item)) {
      return false;
    }
    if (defined(h[item])) {
      return false;
    }
    h[item] = 1;
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isUniqueTree = function(lItems, func = undef, hFound = {}) {
  var i, item, len1;
  if (isEmpty(lItems)) {
    return true; // empty list is unique
  }
  if (defined(func)) {
    assert(isFunction(func), `Not a function: ${OL(func)}`);
  }
  for (i = 0, len1 = lItems.length; i < len1; i++) {
    item = lItems[i];
    if (isArray(item)) {
      if (!isUniqueTree(item, func, hFound)) {
        return false;
      }
    } else {
      if (defined(func) && !func(item)) {
        return false;
      }
      if (defined(hFound[item])) {
        return false;
      }
      hFound[item] = 1;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var uniq = function(lItems) {
  return [...new Set(lItems)];
};

// ---------------------------------------------------------------------------
//   warn - issue a warning
export var warn = function(message) {
  return say(`WARNING: ${message}`);
};

// ---------------------------------------------------------------------------
//   hashToStr - stringify a hash
export var hashToStr = function(h) {
  return JSON.stringify(h, Object.keys(h).sort(), 3);
};

// ---------------------------------------------------------------------------
//   say - print to the console (for now)
//         later, on a web page, call alert(str)
export var say = function(x) {
  if (isHash(x)) {
    LOG(hashToStr(x));
  } else {
    LOG(x);
  }
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
  assert(isString(line), "rtrim(): line is not a string");
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
  var err, newObj, objStr;
  if (obj === undef) {
    return undef;
  }
  objStr = JSON.stringify(obj);
  try {
    newObj = JSON.parse(objStr);
  } catch (error1) {
    err = error1;
    croak("ERROR: err.message", objStr);
  }
  return newObj;
};

// ---------------------------------------------------------------------------
//   escapeStr - escape newlines, TAB chars, etc.
export var hDefEsc = {
  "\n": '®',
  "\t": '→',
  " ": '˳'
};

export var escapeStr = function(str, hEscape = hDefEsc) {
  var ch, lParts;
  assert(isString(str), "escapeStr(): not a string");
  lParts = (function() {
    var i, len1, ref, results;
    ref = str.split('');
    results = [];
    for (i = 0, len1 = ref.length; i < len1; i++) {
      ch = ref[i];
      if (hEscape[ch] != null) {
        results.push(hEscape[ch]);
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
    var i, len1, results;
    results = [];
    for (i = 0, len1 = lStrings.length; i < len1; i++) {
      str = lStrings[i];
      results.push(str[0]);
    }
    return results;
  })();
  if (convertFunc != null) {
    lConverted = (function() {
      var i, len1, results;
      results = [];
      for (i = 0, len1 = lStrings.length; i < len1; i++) {
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
export var envVarsWithPrefix = function(prefix, hOptions = {}) {
  var h, i, key, len1, plen, ref;
  // --- valid options:
  //        stripPrefix
  assert(prefix, "envVarsWithPrefix: empty prefix!");
  plen = prefix.length;
  h = {};
  ref = Object.keys(process.env);
  for (i = 0, len1 = ref.length; i < len1; i++) {
    key = ref[i];
    if (key.indexOf(prefix) === 0) {
      if (hOptions.stripPrefix) {
        h[key.substr(plen)] = process.env[key];
      } else {
        h[key] = process.env[key];
      }
    }
  }
  return h;
};

// ---------------------------------------------------------------------------
export var getTimeStr = function(date = undef) {
  if (date === undef) {
    date = new Date();
  }
  return date.toLocaleTimeString('en-US');
};

// ---------------------------------------------------------------------------
export var getDateStr = function(date = undef) {
  if (date === undef) {
    date = new Date();
  }
  return date.toLocaleDateString('en-US');
};

// ---------------------------------------------------------------------------
export var strcat = function(...lItems) {
  var i, item, len1, str;
  str = '';
  for (i = 0, len1 = lItems.length; i < len1; i++) {
    item = lItems[i];
    str += item.toString();
  }
  return str;
};

// ---------------------------------------------------------------------------
export var replaceVars = function(line, hVars = {}, rx = /__(env\.)?([A-Za-z_]\w*)__/g) {
  var replacerFunc;
  assert(isHash(hVars), "replaceVars() hVars is not a hash");
  replacerFunc = (match, prefix, name) => {
    var value;
    if (prefix) {
      return process.env[name];
    } else {
      value = hVars[name];
      if (defined(value)) {
        if (isString(value)) {
          return value;
        } else {
          return JSON.stringify(value);
        }
      } else {
        return `__${name}__`;
      }
    }
  };
  return line.replace(rx, replacerFunc);
};

// ---------------------------------------------------------------------------
export var defined = function(obj) {
  return (obj !== undef) && (obj !== null);
};

// ---------------------------------------------------------------------------
export var notdefined = function(obj) {
  return (obj === undef) || (obj === null);
};

// ---------------------------------------------------------------------------
export var isIterable = function(obj) {
  if ((obj === undef) || (obj === null)) {
    return false;
  }
  return typeof obj[Symbol.iterator] === 'function';
};

// ---------------------------------------------------------------------------
export var className = function(aClass) {
  var lMatches;
  if (lMatches = aClass.toString().match(/class\s+(\w+)/)) {
    return lMatches[1];
  } else {
    return croak("className(): Bad input class");
  }
};

// ---------------------------------------------------------------------------
export var range = function(n) {
  var ref;
  return (function() {
    var results = [];
    for (var i = 0, ref = n - 1; 0 <= ref ? i <= ref : i >= ref; 0 <= ref ? i++ : i--){ results.push(i); }
    return results;
  }).apply(this);
};

// ---------------------------------------------------------------------------
export var setCharsAt = function(str, pos, str2) {
  assert(pos >= 0, `negative pos ${pos} not allowed`);
  assert(pos < str.length, `pos ${pos} not in ${OL(str)}`);
  if (pos + str2.length >= str.length) {
    return str.substring(0, pos) + str2;
  } else {
    return str.substring(0, pos) + str2 + str.substring(pos + str2.length);
  }
};

// ---------------------------------------------------------------------------
export var getOptions = function(hOptions, hDefault = {}) {
  var h, i, len1, ref, word;
  // --- If hOptions is a string, break into words and set each to true
  if (isString(hOptions)) {
    h = {};
    ref = words(hOptions);
    for (i = 0, len1 = ref.length; i < len1; i++) {
      word = ref[i];
      h[word] = true;
    }
    return h;
  } else if (isHash(hOptions)) {
    return hOptions;
  } else {
    return hDefault;
  }
};
