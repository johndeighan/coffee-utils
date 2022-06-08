// Generated by CoffeeScript 2.7.0
// log_utils.coffee
var doDebugLog, escReplacer, fixForTerminal, fourSpaces, loaded, maxOneLine, putBlock, putstr;

import yaml from 'js-yaml';

import {
  assert,
  undef,
  isNumber,
  isInteger,
  isString,
  isHash,
  isFunction,
  escapeStr,
  sep_eq,
  sep_dash,
  pass,
  OL
} from '@jdeighan/coffee-utils';

import {
  blockToArray
} from '@jdeighan/coffee-utils/block';

import {
  tabify,
  untabify,
  indentation,
  indented
} from '@jdeighan/coffee-utils/indent';

// --- This logger only ever gets passed a single string argument
putstr = undef;

doDebugLog = false;

export var stringify = undef;

fourSpaces = '    ';

// ---------------------------------------------------------------------------
export var debugLog = function(flag = true) {
  doDebugLog = flag;
  if (doDebugLog) {
    LOG(`doDebugLog = ${flag}`);
  }
};

// ---------------------------------------------------------------------------
// This is useful for debugging
export var LOG = function(...lArgs) {
  var item, label;
  [label, item] = lArgs;
  if (lArgs.length > 1) {
    // --- There's both a label and an item
    if (item === undef) {
      console.log(`${label}: UNDEFINED`);
    } else if (item === null) {
      console.log(`${label}: NULL`);
    } else {
      console.log(sep_dash);
      console.log(`${label}:`);
      if (isString(item)) {
        console.log(untabify(item));
      } else {
        console.log(untabify(orderedStringify(item)));
      }
      console.log(sep_dash);
    }
  } else {
    console.log(label);
  }
  return true; // to allow use in boolean expressions
};


// --- Use this instead to make it easier to remove all instances
export var DEBUG = LOG; // synonym


// ---------------------------------------------------------------------------
export var setStringifier = function(func) {
  var orgStringifier;
  orgStringifier = stringify;
  assert(isFunction(func), "setStringifier() arg is not a function");
  stringify = func;
  return orgStringifier;
};

// ---------------------------------------------------------------------------
export var resetStringifier = function() {
  return setStringifier(orderedStringify);
};

// ---------------------------------------------------------------------------
export var setLogger = function(func) {
  var orgLogger;
  assert(isFunction(func), "setLogger() arg is not a function");
  orgLogger = putstr;
  putstr = func;
  return orgLogger;
};

// ---------------------------------------------------------------------------
export var resetLogger = function() {
  return setLogger(console.log);
};

// ---------------------------------------------------------------------------
escReplacer = function(name, value) {
  if (!isString(value)) {
    return value;
  }
  return escapeStr(value);
};

// ---------------------------------------------------------------------------
export var tamlStringify = function(obj, escape = false) {
  var str;
  str = yaml.dump(obj, {
    skipInvalid: true,
    indent: 1,
    sortKeys: false,
    lineWidth: -1,
    replacer: escape ? escReplacer : function(name, value) {
      return value;
    }
  });
  return "---\n" + tabify(str, 1);
};

// ---------------------------------------------------------------------------
export var orderedStringify = function(obj, escape = false) {
  var str;
  str = yaml.dump(obj, {
    skipInvalid: true,
    indent: 1,
    sortKeys: true,
    lineWidth: 40,
    replacer: escape ? escReplacer : function(name, value) {
      return value;
    }
  });
  return "---\n" + tabify(str, 1);
};

// ---------------------------------------------------------------------------
maxOneLine = 32;

// ---------------------------------------------------------------------------
export var log = function(str, hOptions = {}) {
  var prefix;
  // --- valid options:
  //   prefix
  assert(isFunction(putstr), "putstr not properly set");
  assert(isString(str), "log(): not a string");
  assert(isHash(hOptions), "log(): arg 2 not a hash");
  prefix = fixForTerminal(hOptions.prefix);
  if (doDebugLog) {
    LOG(`CALL log(${OL(str)}), prefix = ${OL(prefix)}`);
  }
  putstr(`${prefix}${str}`);
  return true; // to allow use in boolean expressions
};


// ---------------------------------------------------------------------------
export var logItem = function(label, item, hOptions = {}) {
  var i, labelStr, len, prefix, ref, str;
  // --- valid options:
  //   prefix
  assert(isFunction(putstr), "putstr not properly set");
  assert(!label || isString(label), "label a non-string");
  assert(isHash(hOptions), "arg 3 not a hash");
  label = fixForTerminal(label);
  prefix = fixForTerminal(hOptions.prefix);
  assert(prefix.indexOf("\t") === -1, "prefix has TAB");
  if (doDebugLog) {
    LOG(`CALL logItem(${OL(label)}, ${OL(item)})`);
    LOG(`prefix = ${OL(prefix)}`);
  }
  labelStr = label ? `${label} = ` : "";
  if (item === undef) {
    putstr(`${prefix}${labelStr}undef`);
  } else if (item === null) {
    putstr(`${prefix}${labelStr}null`);
  } else if (isString(item)) {
    if (item.length <= maxOneLine) {
      putstr(`${prefix}${labelStr}'${escapeStr(item)}'`);
    } else {
      if (label) {
        putstr(`${prefix}${label}:`);
      }
      putBlock(item, prefix + fourSpaces);
    }
  } else if (isNumber(item)) {
    putstr(`${prefix}${labelStr}${item}`);
  } else {
    if (label) {
      putstr(`${prefix}${label}:`);
    }
    ref = blockToArray(stringify(item, true));
    // escape special chars
    for (i = 0, len = ref.length; i < len; i++) {
      str = ref[i];
      putstr(`${prefix + fourSpaces}${fixForTerminal(str)}`);
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var shortEnough = function(label, value) {
  return value === undef;
};

// ---------------------------------------------------------------------------
// --- needed because Windows Terminal handles TAB chars badly
fixForTerminal = function(str) {
  if (!str) {
    return '';
  }
  // --- convert TAB char to 4 spaces
  return str.replace(/\t/g, fourSpaces);
};

// ---------------------------------------------------------------------------
putBlock = function(item, prefix = '') {
  var i, len, line, ref;
  putstr(`${prefix}${sep_eq}`);
  ref = blockToArray(item);
  for (i = 0, len = ref.length; i < len; i++) {
    line = ref[i];
    putstr(`${prefix}${escapeStr(line)}`);
  }
  putstr(`${prefix}${sep_eq}`);
};

if (!loaded) {
  setStringifier(orderedStringify);
  resetLogger();
}

loaded = true;
