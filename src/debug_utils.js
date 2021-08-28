// Generated by CoffeeScript 2.5.1
// debug_utils.coffee
var arrow, arrowhead, corner, debugLevel, hbar, ifMatches, indent, stringifier, vbar;

import {
  undef,
  say,
  pass,
  error,
  isString,
  stringToArray,
  tamlStringify,
  setLogger,
  escapeStr
} from '@jdeighan/coffee-utils';

vbar = '│'; // unicode 2502

hbar = '─'; // unicode 2500

corner = '└'; // unicode 2514

arrowhead = '>';

indent = vbar + '   ';

arrow = corner + hbar + arrowhead + ' ';

debugLevel = 0; // controls amount of indentation

export var debugging = false;

stringifier = tamlStringify;

ifMatches = undef;

// ---------------------------------------------------------------------------
export var setStringifier = function(func) {
  stringifier = func;
};

// ---------------------------------------------------------------------------
export var setDebugging = function(flag, hOptions = {}) {
  var dumperFunc, loggerFunc, regexp;
  debugging = flag;
  debugLevel = 0;
  if (flag) {
    ({
      loggerFunc,
      dumperFunc,
      ifMatches: regexp
    } = hOptions);
    if (loggerFunc && dumperFunc) {
      setLogger(loggerFunc, dumperFunc);
    }
    if (regexp) {
      ifMatches = regexp;
    }
  } else {
    ifMatches = undef;
  }
};

// ---------------------------------------------------------------------------
export var debug = function(item, label = undef) {
  var entering, exiting, i, len, prefix, ref, str, toTest;
  if (!debugging) {
    return;
  }
  toTest = label || item;
  if (isString(toTest) && (ifMatches != null) && !toTest.match(ifMatches)) {
    return;
  }
  // --- determine if we're entering or returning from a function
  entering = exiting = false;
  if (label) {
    if (!isString(label)) {
      error("debug(): label must be a string");
    }
    entering = label.indexOf('enter') === 0;
    exiting = label.indexOf('return') === 0;
  } else {
    if (!isString(item)) {
      error("debug(): single parameter must be a string");
    }
    entering = item.indexOf('enter') === 0;
    exiting = item.indexOf('return') === 0;
  }
  if (exiting) {
    prefix = indent.repeat(debugLevel - 1) + arrow;
  } else {
    prefix = indent.repeat(debugLevel);
  }
  if (item == null) {
    if (label) {
      say(prefix + label + " undef");
    } else {
      say(prefix + " undef");
    }
  } else if (isString(item)) {
    if (label) {
      say(prefix + label + " '" + escapeStr(item) + "'");
    } else {
      say(prefix + escapeStr(item));
    }
  } else {
    if (label) {
      say(prefix + label);
    }
    ref = stringToArray(stringifier(item));
    for (i = 0, len = ref.length; i < len; i++) {
      str = ref[i];
      // --- We're exiting, but we want the normal prefix
      prefix = indent.repeat(debugLevel);
      say(prefix + '   ' + str.replace(/\t/g, '   '));
    }
  }
  if (entering) {
    debugLevel += 1;
  }
  if (exiting && (debugLevel > 0)) {
    debugLevel -= 1;
  }
};
