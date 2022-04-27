// Generated by CoffeeScript 2.6.1
// coffee_utils.coffee
var LOG;

export var sep_dash = '-'.repeat(42);

export var sep_eq = '='.repeat(42);

export const undef = undefined;

LOG = function(...lArgs) {
  return console.log(...lArgs); // synonym for console.log()
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
//   assert - mimic nodejs's assert
export var assert = function(cond, msg) {
  if (!cond) {
    error(msg);
  }
};

// ---------------------------------------------------------------------------
//   croak - throws an error after possibly printing useful info
export var croak = function(err, label, obj) {
  var curmsg, newmsg;
  curmsg = isString(err) ? err : err.message;
  newmsg = `ERROR (croak): ${curmsg}
${label}:
${JSON.stringify(obj)}`;
  // --- re-throw the error
  throw new Error(newmsg);
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
export var isBoolean = function(x) {
  return typeof x === 'boolean';
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
export var hashHasKey = function(x, key) {
  assert(isHash(x), "hashHasKey(): not a hash");
  assert(isString(key), "hashHasKey(): key not a string");
  return x.hasOwnProperty(key);
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
export var isUniqueList = function(lItems) {
  var h, i, item, len;
  if (lItems == null) {
    return true; // empty list is unique
  }
  h = {};
  for (i = 0, len = lItems.length; i < len; i++) {
    item = lItems[i];
    if (h[item]) {
      return false;
    }
    h[item] = 1;
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
  return JSON.parse(JSON.stringify(obj));
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
    var result;
    if (prefix) {
      result = process.env[name];
    } else if (hVars[name] == null) {
      result = 'undef';
    } else {
      result = hVars[name];
      if (!isString(result)) {
        result = JSON.stringify(result);
      }
    }
    return result;
  };
  return line.replace(rx, replacerFunc);
};

// ---------------------------------------------------------------------------
export var isIterable = function(object) {
  if ((object === undef) || (object === null)) {
    return false;
  }
  return typeof object[Symbol.iterator] === 'function';
};
