// Generated by CoffeeScript 2.7.0
// utils.coffee
var hasProp = {}.hasOwnProperty;

import {
  assert,
  croak
} from '@jdeighan/exceptions';

import {
  LOG,
  sep_dash,
  sep_eq
} from '@jdeighan/exceptions/log';

import {
  undef,
  pass,
  def,
  defined,
  notdef,
  notdefined,
  deepCopy,
  escapeStr,
  unescapeStr,
  hasChar,
  quoted,
  OL,
  isString,
  isNumber,
  isInteger,
  isHash,
  isArray,
  isBoolean,
  isConstructor,
  isFunction,
  isRegExp,
  isObject,
  getClassName,
  jsType,
  isEmpty,
  nonEmpty,
  chomp,
  rtrim,
  setCharsAt,
  words,
  getOptions
} from '@jdeighan/exceptions/utils';

export {
  undef,
  pass,
  def,
  defined,
  notdef,
  notdefined,
  LOG,
  sep_dash,
  sep_eq,
  deepCopy,
  escapeStr,
  unescapeStr,
  hasChar,
  quoted,
  OL,
  isString,
  isNumber,
  isInteger,
  isHash,
  isArray,
  isBoolean,
  isConstructor,
  isFunction,
  isRegExp,
  isObject,
  getClassName,
  jsType,
  isEmpty,
  nonEmpty,
  chomp,
  rtrim,
  setCharsAt,
  words,
  getOptions
};

// ---------------------------------------------------------------------------
export var isHashComment = (line) => {
  var lMatches;
  lMatches = line.match(/^\s*\#(\s|$)/);
  return defined(lMatches);
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
export var removeKeys = (h, lKeys) => {
  var i, item, j, key, len, len1, value;
  for (i = 0, len = lKeys.length; i < len; i++) {
    key = lKeys[i];
    delete h[key];
  }
  for (key in h) {
    if (!hasProp.call(h, key)) continue;
    value = h[key];
    if (defined(value)) {
      if (isArray(value)) {
        for (j = 0, len1 = value.length; j < len1; j++) {
          item = value[j];
          if (isHash(item)) {
            removeKeys(item, lKeys);
          }
        }
      } else if (typeof value === 'object') {
        removeKeys(value, lKeys);
      }
    }
  }
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
export var isNonEmptyArray = function(x) {
  return isArray(x) && (x.length > 0);
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
export var isArrayOfHashes = function(lItems) {
  var i, item, len;
  if (!isArray(lItems)) {
    return false;
  }
  for (i = 0, len = lItems.length; i < len; i++) {
    item = lItems[i];
    if (defined(item) && !isHash(item)) {
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
    if (defined(item) && !isString(item)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isUniqueList = function(lItems, func = undef) {
  var h, i, item, len;
  if (notdefined(lItems)) {
    return true; // empty list is unique
  }
  if (defined(func)) {
    assert(isFunction(func), `Not a function: ${OL(func)}`);
  }
  h = {};
  for (i = 0, len = lItems.length; i < len; i++) {
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
  var i, item, len;
  if (isEmpty(lItems)) {
    return true; // empty list is unique
  }
  if (defined(func)) {
    assert(isFunction(func), `Not a function: ${OL(func)}`);
  }
  for (i = 0, len = lItems.length; i < len; i++) {
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
  if (defined(convertFunc)) {
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
export var envVarsWithPrefix = function(prefix, hOptions = {}) {
  var h, i, key, len, plen, ref;
  // --- valid options:
  //        stripPrefix
  assert(prefix, "envVarsWithPrefix: empty prefix!");
  plen = prefix.length;
  h = {};
  ref = Object.keys(process.env);
  for (i = 0, len = ref.length; i < len; i++) {
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
  var i, item, len, str;
  str = '';
  for (i = 0, len = lItems.length; i < len; i++) {
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
export var timestamp = function() {
  return new Date().toLocaleTimeString("en-US");
};
