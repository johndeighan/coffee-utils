// Generated by CoffeeScript 2.7.0
// debug_utils.coffee
var callStack, doDebugDebug, reMethod, resetDebugging;

import {
  assert,
  undef,
  error,
  croak,
  warn,
  defined,
  isString,
  isFunction,
  isBoolean,
  sep_dash,
  OL,
  escapeStr,
  isNumber,
  isArray,
  words,
  pass
} from '@jdeighan/coffee-utils';

import {
  blockToArray
} from '@jdeighan/coffee-utils/block';

import {
  untabify
} from '@jdeighan/coffee-utils/indent';

import {
  slurp
} from '@jdeighan/coffee-utils/fs';

import {
  CallStack
} from '@jdeighan/coffee-utils/stack';

import {
  getPrefix,
  addArrow,
  removeLastVbar
} from '@jdeighan/coffee-utils/arrow';

import {
  log,
  logItem,
  LOG,
  shortEnough
} from '@jdeighan/coffee-utils/log';

callStack = new CallStack();

doDebugDebug = false;

export var shouldLog = undef; // set in resetDebugging() and setDebugging()

export var lFuncList = [];

// ---------------------------------------------------------------------------
export var debug = function(label, ...lObjects) {
  var doLog, funcName, i, j, k, l, len1, len2, len3, level, nObjects, obj, prefix, type;
  assert(isString(label), `1st arg ${OL(label)} should be a string`);
  // --- We want to allow objects to be undef. Therefore, we need to
  //     distinguish between 1 arg sent vs. 2 or more args sent
  nObjects = lObjects.length;
  // --- funcName is only set for types 'enter' and 'return'
  [type, funcName] = getType(label, nObjects);
  if (doDebugDebug) {
    LOG(`debug(): type = ${OL(type)}`);
    LOG(`debug(): funcName = ${OL(funcName)}`);
  }
  switch (type) {
    case 'enter':
      callStack.enter(funcName);
      label = shouldLog(label, type, funcName, callStack);
      break;
    case 'return':
      label = shouldLog(label, type, funcName, callStack);
      break;
    case 'string':
      label = shouldLog(label, type, undef, callStack);
      assert(nObjects === 0, `multiple objects only not allowed for ${OL(type)}`);
      break;
    case 'objects':
      label = shouldLog(label, type, undef, callStack);
      assert(nObjects > 0, `multiple objects only not allowed for ${OL(type)}`);
  }
  doLog = defined(label);
  if (doDebugDebug) {
    if (nObjects === 0) {
      LOG(`debug(${OL(label)}) - 1 arg`);
    } else {
      LOG(`debug(${OL(label)}), ${nObjects} args`);
    }
    LOG(`doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    level = callStack.getLevel();
    prefix = getPrefix(level);
    if (doDebugDebug) {
      LOG("callStack", callStack);
      LOG(`level = ${OL(level)}`);
      LOG(`prefix = ${OL(prefix)}`);
    }
    switch (type) {
      case 'enter':
        log(label, {prefix});
        for (i = j = 0, len1 = lObjects.length; j < len1; i = ++j) {
          obj = lObjects[i];
          if (i > 0) {
            log(sep_dash, {
              prefix: removeLastVbar(prefix)
            });
          }
          logItem(undef, obj, {
            prefix: removeLastVbar(prefix)
          });
        }
        break;
      case 'return':
        log(label, {
          prefix: addArrow(prefix)
        });
        for (i = k = 0, len2 = lObjects.length; k < len2; i = ++k) {
          obj = lObjects[i];
          if (i > 0) {
            log(sep_dash, {
              prefix: removeLastVbar(prefix)
            });
          }
          logItem(undef, obj, {
            prefix: removeLastVbar(prefix)
          });
        }
        break;
      case 'string':
        log(label, {prefix});
        break;
      case 'objects':
        if ((nObjects === 1) && shortEnough(label, lObjects[0])) {
          logItem(label, lObjects[0], {prefix});
        } else {
          if (label.indexOf(':') !== label.length - 1) {
            label += ':';
          }
          log(label, {prefix});
          for (l = 0, len3 = lObjects.length; l < len3; l++) {
            obj = lObjects[l];
            logItem(undef, obj, {prefix});
          }
        }
    }
  }
  if ((type === 'enter') && doLog) {
    callStack.logCurFunc();
  } else if (type === 'return') {
    callStack.returnFrom(funcName);
  }
  return true; // allow use in boolean expressions
};


// ---------------------------------------------------------------------------
export var stdShouldLog = function(label, type, funcName, stack) {
  // --- if type is 'enter', then funcName won't be on the stack yet
  //     returns the (possibly modified) label to log

  // --- If we're logging now,
  //     but we won't be logging when funcName is activated
  //     then change 'enter' to 'call'
  assert(isString(label), `label ${OL(label)} not a string`);
  assert(isString(type), `type ${OL(type)} not a string`);
  if ((type === 'enter') || (type === 'return')) {
    assert(isString(funcName), `func name ${OL(funcName)} not a string`);
  } else {
    assert(funcName === undef, `func name ${OL(funcName)} not undef`);
  }
  assert(stack instanceof CallStack, "not a call stack object");
  if (doDebugDebug) {
    LOG(`stdShouldLog(${OL(label)}, ${OL(type)}, ${OL(funcName)}, stack)`);
    LOG("stack", stack);
    LOG("lFuncList", lFuncList);
  }
  switch (type) {
    case 'enter':
      if (funcMatch(stack, lFuncList)) {
        return label;
      // --- As a special case, if we enter a function where we will not
      //     be logging, but we were logging in the calling function,
      //     we'll log out the call itself
      } else if (stack.isLoggingPrev()) {
        return label.replace('enter', 'call');
      }
      break;
    default:
      if (funcMatch(stack, lFuncList)) {
        return label;
      }
  }
  return undef;
};

// ---------------------------------------------------------------------------
export var debugDebug = function(flag = true) {
  doDebugDebug = flag;
  if (doDebugDebug) {
    LOG(`doDebugDebug = ${flag}`);
  }
};

// ---------------------------------------------------------------------------
resetDebugging = function() {
  if (doDebugDebug) {
    LOG("resetDebugging()");
  }
  callStack.reset();
  shouldLog = function(label, type, funcName, stack) {
    return undef;
  };
};

// ---------------------------------------------------------------------------
export var setDebugging = function(option) {
  resetDebugging();
  if (isBoolean(option)) {
    if (option) {
      shouldLog = function(label, type, funcName, stack) {
        return label;
      };
    } else {
      shouldLog = function(label, type, funcName, stack) {
        return undef;
      };
    }
    if (doDebugDebug) {
      LOG(`setDebugging = ${option}`);
    }
  } else if (isString(option)) {
    lFuncList = getFuncList(option);
    shouldLog = stdShouldLog;
    if (doDebugDebug) {
      LOG(`setDebugging FUNCS: ${option}`);
      LOG('lFuncList', lFuncList);
    }
  } else if (isFunction(option)) {
    shouldLog = option;
    if (doDebugDebug) {
      LOG("setDebugging to custom func");
    }
  } else {
    croak(`bad parameter ${OL(option)}`);
  }
};

// ---------------------------------------------------------------------------
// --- export only to allow unit tests
export var getFuncList = function(str) {
  var _, ident1, ident2, j, lMatches, len1, plus, ref, word;
  lFuncList = [];
  ref = words(str);
  for (j = 0, len1 = ref.length; j < len1; j++) {
    word = ref[j];
    if (lMatches = word.match(/^([A-Za-z_][A-Za-z0-9_]*)(?:\.([A-Za-z_][A-Za-z0-9_]*))?(\+)?$/)) {
      [_, ident1, ident2, plus] = lMatches;
      if (ident2) {
        lFuncList.push({
          name: ident2,
          object: ident1,
          plus: plus === '+'
        });
      } else {
        lFuncList.push({
          name: ident1,
          plus: plus === '+'
        });
      }
    } else {
      croak(`Bad word in func list: ${OL(word)}`);
    }
  }
  return lFuncList;
};

// ---------------------------------------------------------------------------
// --- export only to allow unit tests
export var funcMatch = function(stack, lFuncList) {
  var curFunc, h, j, len1, name, object, plus;
  assert(isArray(lFuncList), `not an array ${OL(lFuncList)}`);
  curFunc = stack.curFunc();
  if (doDebugDebug) {
    LOG(`funcMatch(): curFunc = ${OL(curFunc)}`);
    stack.dump('   ');
    LOG('lFuncList', lFuncList);
  }
  for (j = 0, len1 = lFuncList.length; j < len1; j++) {
    h = lFuncList[j];
    ({name, object, plus} = h);
    if (name === curFunc) {
      if (doDebugDebug) {
        LOG("   curFunc in lFuncList - match successful");
      }
      return true;
    }
    if (plus && stack.isActive(name)) {
      if (doDebugDebug) {
        LOG(`   func ${OL(name)} is active - match successful`);
      }
      return true;
    }
  }
  if (doDebugDebug) {
    LOG("   - no match");
  }
  return false;
};

// ---------------------------------------------------------------------------
// --- type is one of: 'enter', 'return', 'string', 'object'
export var getType = function(str, nObjects) {
  var lMatches;
  if (lMatches = str.match(/^\s*enter\s+([A-Za-z_][A-Za-z0-9_\.]*)/)) {
    // --- We are entering function curFunc
    return ['enter', lMatches[1]];
  } else if (lMatches = str.match(/^\s*return.+from\s+([A-Za-z_][A-Za-z0-9_\.]*)/)) {
    return ['return', lMatches[1]];
  } else if (nObjects > 0) {
    return ['objects', undef];
  } else {
    return ['string', undef];
  }
};

// ---------------------------------------------------------------------------
reMethod = /^([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)$/;

// ---------------------------------------------------------------------------
export var checkTrace = function(block) {
  var funcName, j, lMatches, lStack, len, len1, line, ref;
  // --- export only to allow unit tests
  lStack = [];
  ref = blockToArray(block);
  for (j = 0, len1 = ref.length; j < len1; j++) {
    line = ref[j];
    if (lMatches = line.match(/enter\s+([A-Za-z_][A-Za-z0-9_\.]*)/)) {
      funcName = lMatches[1];
      lStack.push(funcName);
    } else if (lMatches = line.match(/return.*from\s+([A-Za-z_][A-Za-z0-9_\.]*)/)) {
      funcName = lMatches[1];
      len = lStack.length;
      if (len === 0) {
        log(`return from ${funcName} with empty stack`);
      } else if (lStack[len - 1] === funcName) {
        lStack.pop();
      } else if (lStack[len - 2] === funcName) {
        log(`missing return from ${lStack[len - 2]}`);
        lStack.pop();
        lStack.pop();
      } else {
        log(`return from ${funcName} - not found on stack`);
      }
    }
  }
};

// ---------------------------------------------------------------------------
resetDebugging();
