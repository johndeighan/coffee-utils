// Generated by CoffeeScript 2.5.1
// coffee_utils.coffee
import yaml from 'js-yaml';

export var sep_dash = '-'.repeat(42);

export var sep_eq = '='.repeat(42);

export const undef = undefined;

export var getHello = function() {
  return "Hello, CoffeeScript!";
};

export var unitTesting = false;

export var setUnitTesting = function(flag = true) {
  return unitTesting = flag;
};

export var debugging = false;

export var setDebugging = function(flag = false) {
  return debugging = flag;
};

// ---------------------------------------------------------------------------
export var defined = function(item) {
  return (item !== undef) && (item !== null);
};

// ---------------------------------------------------------------------------
export var debug = function(item, label = undef) {
  if (debugging) {
    if (isString(item)) {
      say(escapeStr(item), label);
    } else {
      say(item, label);
    }
  }
};

// ---------------------------------------------------------------------------
export var localStore = function(key, value = undef) {
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
export var isString = function(x) {
  return typeof x === 'string' || x instanceof String;
};

// ---------------------------------------------------------------------------
export var isObject = function(x) {
  return typeof x === 'object';
};

// ---------------------------------------------------------------------------
export var isArray = function(x) {
  return Array.isArray(x);
};

// ---------------------------------------------------------------------------
export var isHash = function(x) {
  return typeof x === 'object';
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
//   warn - issue a warning
export var warn = function(message) {
  return say(`WARNING: ${message}`);
};

// ---------------------------------------------------------------------------
//   say - print to the console
export var say = function(str, label = '') {
  if (label) {
    console.log(label);
  }
  if (typeof str === 'object') {
    return console.dir(str);
  } else {
    return console.log(str);
  }
};

// ---------------------------------------------------------------------------
//   ask - ask a question
export var ask = function(prompt) {
  return 'yes';
};

// ---------------------------------------------------------------------------
//   isTAML - is the string valid TAML?
export var isTAML = function(str) {
  if (typeof str === 'object') {
    if (!str || str.length === 0) {
      return false;
    }
    return str[0].indexOf('---') === 0;
  }
  return str.indexOf('---') === 0;
};

// ---------------------------------------------------------------------------
//   taml - convert valid TAML string to a data structure
export var taml = function(strOrArray) {
  if (!strOrArray) {
    return 'null';
  }
  if (typeof strOrArray === 'object') {
    strOrArray = arrayToString(strOrArray);
  }
  return yaml.load(strOrArray.replace(/\t/g, '  '));
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
    return rtrim(lLines.join('\n')) + '\n';
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
//   dumpOutput - for debugging
//      --- output can be a string or an array
export var dumpOutput = function(output, label = "output", logger = console.log) {
  var i, len1, line, results;
  logger(sep_eq);
  logger(titleLine(label));
  logger(sep_eq);
  if (typeof output === 'string') {
    return logger(output);
  } else if (typeof output === 'object') {
    results = [];
    for (i = 0, len1 = output.length; i < len1; i++) {
      line = output[i];
      results.push(logger(line));
    }
    return results;
  }
};

// ---------------------------------------------------------------------------
export var titleLine = function(title, char = '=', padding = 2, linelen = 42) {
  var nLeft, nRight, strLeft, strMiddle, strRight, titleLen;
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
    say(`STRING: '${str}'`);
    error("escapeStr(): not a string");
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
// truncateBlock - limit block to a certain number of lines
export var truncateBlock = function(str, numLines) {
  var lLines;
  lLines = stringToArray(str);
  lLines.length = numLines;
  return arrayToString(lLines);
};
