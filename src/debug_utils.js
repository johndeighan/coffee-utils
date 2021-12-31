// Generated by CoffeeScript 2.6.1
// debug_utils.coffee
var arrow, arrowhead, corner, curEnv, debugLevel, getPrefix, hbar, indent, logger, reMethod, setEnv, shouldDebug, shouldLog, stack, stdLogger, stripArrow, vbar;

import {
  assert,
  undef,
  error,
  croak,
  warn,
  isString,
  isFunction,
  isBoolean,
  oneline,
  escapeStr,
  isNumber,
  isArray,
  words
} from '@jdeighan/coffee-utils';

import {
  blockToArray
} from '@jdeighan/coffee-utils/block';

import {
  log,
  setLogger
} from '@jdeighan/coffee-utils/log';

import {
  slurp
} from '@jdeighan/coffee-utils/fs';

import {
  CallStack
} from '@jdeighan/coffee-utils/stack';

vbar = '│'; // unicode 2502

hbar = '─'; // unicode 2500

corner = '└'; // unicode 2514

arrowhead = '>';

indent = vbar + '   ';

arrow = corner + hbar + arrowhead + ' ';

debugLevel = 0; // controls amount of indentation - we ensure it's never < 0

stdLogger = false;

// --- These are saved/restored on the call stack
export var debugging = false;

shouldDebug = shouldLog = undef;

stack = new CallStack();

// ---------------------------------------------------------------------------
export var resetDebugging = function(funcDoDebug = undef, funcDoLog = undef) {
  debugging = false;
  debugLevel = 0;
  stack.reset();
  shouldDebug = function(funcName) {
    return debugging;
  };
  shouldLog = function(str) {
    return debugging;
  };
  if (funcDoDebug) {
    setDebugging(funcDoDebug, funcDoLog);
  }
};

// ---------------------------------------------------------------------------
export var setDebugging = function(funcDoDebug = undef, funcDoLog = undef) {
  var lFuncNames;
  if (isBoolean(funcDoDebug)) {
    debugging = funcDoDebug;
  } else if (isString(funcDoDebug)) {
    debugging = false;
    lFuncNames = words(funcDoDebug);
    assert(isArray(lFuncNames), `words('${funcDoDebug}') returned non-array`);
    shouldDebug = function(funcName) {
      return debugging || funcMatch(funcName, lFuncNames);
    };
  } else if (isFunction(funcDoDebug)) {
    shouldDebug = funcDoDebug;
  } else {
    croak(`setDebugging(): bad parameter ${oneline(funcDoDebug)}`);
  }
  if (funcDoLog) {
    assert(isFunction(funcDoLog), "setDebugging: arg 2 not a function");
    shouldLog = funcDoLog;
  }
};

// ---------------------------------------------------------------------------
// --- export only to allow unit tests
export var funcMatch = function(curFunc, lFuncNames) {
  var _, cls, lMatches, meth;
  assert(isString(curFunc), "funcMatch(): not a string");
  assert(isArray(lFuncNames), `funcMatch(): bad array ${lFuncNames}`);
  if (lFuncNames.includes(curFunc)) {
    return true;
  } else if ((lMatches = curFunc.match(reMethod)) && ([_, cls, meth] = lMatches) && lFuncNames.includes(meth)) {
    return true;
  } else {
    return false;
  }
};

// ---------------------------------------------------------------------------
curEnv = function() {
  return {debugging, shouldDebug, shouldLog};
};

// ---------------------------------------------------------------------------
setEnv = function(hEnv) {
  ({debugging, shouldDebug, shouldLog} = hEnv);
};

// ---------------------------------------------------------------------------
export var useStdLogger = function(flag = true) {
  stdLogger = flag;
};

// ---------------------------------------------------------------------------
logger = function(...lArgs) {
  var orgLogger;
  if (stdLogger) {
    log(...lArgs);
  } else {
    orgLogger = setLogger(console.log);
    log(...lArgs);
    setLogger(orgLogger);
  }
};

// ---------------------------------------------------------------------------
stripArrow = function(prefix) {
  return prefix.replace(arrow, '    ');
};

// ---------------------------------------------------------------------------
getPrefix = function(level) {
  if (level < 0) {
    warn("You have mismatched debug 'enter'/'return' somewhere!");
    return '';
  }
  return '   '.repeat(level);
};

// ---------------------------------------------------------------------------
export var debug = function(...lArgs) {
  var curFunc, entering, hInfo, item, lMatches, nArgs, prefix, returning, str;
  // --- either 1 or 2 args

  // --- We always need to manipulate the stack when we encounter
  //     either "enter X" or "return from X", so we can't short-circuit
  //     when debugging is off
  nArgs = lArgs.length;
  assert((nArgs === 1) || (nArgs === 2), `debug(); Bad # args ${nArgs}`);
  str = lArgs[0];
  // --- str must always be a string
  //     if 2 args, then str is meant to be a label for the item
  assert(isString(str), `debug(): 1st arg ${oneline(str)} should be a string`);
  if (nArgs === 2) {
    item = lArgs[1];
  }
  // --- determine if we're entering or returning from a function
  entering = returning = false;
  curFunc = undef;
  if ((lMatches = str.match(/^\s*enter\s+([A-Za-z_][A-Za-z0-9_\.]*)/))) {
    entering = true;
    curFunc = lMatches[1];
    stack.call(curFunc, curEnv());
    debugging = shouldDebug(curFunc, debugging);
  } else if ((lMatches = str.match(/^\s*return.*from\s+([A-Za-z_][A-Za-z0-9_\.]*)/))) {
    returning = true;
    curFunc = lMatches[1];
    hInfo = stack.returnFrom(curFunc);
  }
  if (debugging && shouldLog(str)) {
    // --- set the prefix, i.e. indentation to use
    if (returning) {
      if (debugLevel === 0) {
        prefix = arrow;
      } else {
        prefix = indent.repeat(debugLevel - 1) + arrow;
      }
    } else {
      prefix = indent.repeat(debugLevel);
    }
    if (nArgs === 1) {
      logger(str, item, {prefix});
    } else {
      logger(str, item, {
        prefix,
        logItem: true,
        itemPrefix: stripArrow(prefix)
      });
    }
  }
  // --- Adjust debug level
  if (returning) {
    if (debugLevel > 0) {
      debugLevel -= 1;
    }
    setEnv(hInfo);
  } else if (entering) {
    if (debugging) {
      debugLevel += 1;
    }
  }
};

// ---------------------------------------------------------------------------
reMethod = /^([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)$/;

// ---------------------------------------------------------------------------
export var checkTrace = function(block) {
  var funcName, i, lMatches, lStack, len, len1, line, ref;
  // --- export only to allow unit tests
  lStack = [];
  ref = blockToArray(block);
  for (i = 0, len1 = ref.length; i < len1; i++) {
    line = ref[i];
    if (lMatches = line.match(/enter\s+([A-Za-z_][A-Za-z0-9_\.]*)/)) {
      funcName = lMatches[1];
      lStack.push(funcName);
    } else if (lMatches = line.match(/return.*from\s+([A-Za-z_][A-Za-z0-9_\.]*)/)) {
      funcName = lMatches[1];
      len = lStack.length;
      if (len === 0) {
        logger(`return from ${funcName} with empty stack`);
      } else if (lStack[len - 1] === funcName) {
        lStack.pop();
      } else if (lStack[len - 2] === funcName) {
        logger(`missing return from ${lStack[len - 2]}`);
        lStack.pop();
        lStack.pop();
      } else {
        logger(`return from ${funcName} - not found on stack`);
      }
    }
  }
};

// ---------------------------------------------------------------------------
resetDebugging();
