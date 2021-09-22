// Generated by CoffeeScript 2.5.1
// log_utils.coffee
var logger, maxOneLine;

import {
  strict as assert
} from 'assert';

import yaml from 'js-yaml';

import {
  undef,
  isNumber,
  isString,
  isHash,
  isFunction,
  escapeStr
} from '@jdeighan/coffee-utils';

import {
  blockToArray
} from '@jdeighan/coffee-utils/block';

import {
  tabify
} from '@jdeighan/coffee-utils/indent';

logger = console.log; // for strings


// ---------------------------------------------------------------------------
// the default stringifier
export var tamlStringify = function(obj) {
  var str;
  str = yaml.dump(obj, {
    skipInvalid: true,
    indent: 1,
    sortKeys: false,
    lineWidth: -1
  });
  str = "---\n" + tabify(str);
  str = str.replace(/\t/g, '   '); // because fr***ing Windows Terminal
  // has no way of adjusting display
  // of TAB chars
  return str;
};

// ---------------------------------------------------------------------------
export var stringify = tamlStringify; // for non-strings


// ---------------------------------------------------------------------------
export var setLogger = function(func) {
  if (func != null) {
    assert(isFunction(func), "setLogger() not a function");
    logger = func;
  } else {
    logger = console.log;
  }
};

// ---------------------------------------------------------------------------
export var setStringifier = function(func) {
  if (func != null) {
    assert(isFunction(func), "setStringifier() not a function");
    stringify = func;
  } else {
    stringify = tamlStringify;
  }
};

// ---------------------------------------------------------------------------
export var currentLogger = function() {
  return logger;
};

// ---------------------------------------------------------------------------
export var currentStringifier = function() {
  return stringify;
};

// ---------------------------------------------------------------------------
maxOneLine = 32;

// ---------------------------------------------------------------------------
export var log = function(...lArgs) {
  var esc, hOptions, i, item, itemPrefix, j, json, len, len1, line, logItem, prefix, ref, ref1, str;
  // --- (str, item, hOptions)
  //     valid options:
  //        prefix
  //        logItem
  //        itemPrefix
  if (lArgs.length === 0) {
    return;
  }
  str = lArgs[0];
  switch (lArgs.length) {
    case 1:
      logItem = false;
      break;
    case 2:
      item = lArgs[1];
      logItem = true;
      break;
    default:
      item = lArgs[1];
      hOptions = lArgs[2];
      assert(isHash(hOptions), "log(): 3rd arg must be a hash");
      if (hOptions.logItem != null) {
        logItem = hOptions.logItem;
      }
  }
  if (hOptions != null) {
    if (hOptions.prefix != null) {
      prefix = hOptions.prefix;
    } else {
      prefix = '';
    }
    if (hOptions.itemPrefix != null) {
      itemPrefix = hOptions.itemPrefix;
    } else {
      itemPrefix = '';
    }
  } else {
    prefix = itemPrefix = '';
  }
  if (!logItem) {
    logger(`${prefix}${str}`);
  } else if (item == null) {
    logger(`${prefix}${str} = undef`);
  } else if (isNumber(item)) {
    logger(`${prefix}${str} = ${item}`);
  } else if (isString(item)) {
    esc = escapeStr(item);
    if (esc.length <= maxOneLine) {
      logger(`${prefix}${str} = '${esc}'`);
    } else {
      logger(`${prefix}${str}:`);
      ref = blockToArray(item);
      for (i = 0, len = ref.length; i < len; i++) {
        line = ref[i];
        logger(`${itemPrefix}   ${escapeStr(line)}`);
      }
    }
  } else {
    // --- It's some type of object
    json = JSON.stringify(item);
    if (json.length <= maxOneLine) {
      logger(`${prefix}${str} = ${json}`);
    } else {
      logger(`${prefix}${str}:`);
      ref1 = blockToArray(stringify(item));
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        str = ref1[j];
        logger(`${itemPrefix}   ${str}`);
      }
    }
  }
};

// ---------------------------------------------------------------------------
