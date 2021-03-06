// Generated by CoffeeScript 2.7.0
// call_stack.coffee
var doDebugStack;

import {
  undef,
  defined,
  croak,
  assert,
  OL,
  escapeStr,
  deepCopy,
  isArray,
  isBoolean
} from '@jdeighan/coffee-utils';

import {
  LOG
} from '@jdeighan/coffee-utils/log';

doDebugStack = false;

// ---------------------------------------------------------------------------
export var debugStack = function(flag = true) {
  doDebugStack = flag;
};

// ---------------------------------------------------------------------------
export var CallStack = class CallStack {
  constructor() {
    this.lStack = [];
  }

  // ........................................................................
  reset() {
    if (doDebugStack) {
      LOG("RESET STACK");
    }
    this.lStack = [];
  }

  // ........................................................................
  indent() {
    return '   '.repeat(this.lStack.length);
  }

  // ........................................................................
  enter(funcName, lArgs = [], isLogged) {
    var _, hStackItem, ident1, ident2, lMatches;
    // --- funcName might be <object>.<method>
    assert(isArray(lArgs), "missing lArgs");
    assert(isBoolean(isLogged), "missing isLogged");
    if (doDebugStack) {
      LOG(this.indent() + `[--> ENTER ${funcName}]`);
    }
    lMatches = funcName.match(/^([A-Za-z_][A-Za-z0-9_]*)(?:\.([A-Za-z_][A-Za-z0-9_]*))?$/);
    assert(defined(lMatches), `Bad funcName: ${OL(funcName)}`);
    [_, ident1, ident2] = lMatches;
    if (ident2) {
      hStackItem = {
        fullName: funcName, //    "#{ident1}.#{ident2}"
        funcName: ident2,
        isLogged,
        lArgs: deepCopy(lArgs)
      };
    } else {
      hStackItem = {
        fullName: funcName,
        funcName: ident1,
        isLogged,
        lArgs: deepCopy(lArgs)
      };
    }
    this.lStack.push(hStackItem);
    return hStackItem;
  }

  // ........................................................................
  getLevel() {
    var item, j, len, level, ref;
    level = 0;
    ref = this.lStack;
    for (j = 0, len = ref.length; j < len; j++) {
      item = ref[j];
      if (item.isLogged) {
        level += 1;
      }
    }
    return level;
  }

  // ........................................................................
  isLogging() {
    if (this.lStack.length === 0) {
      return false;
    } else {
      return this.lStack[this.lStack.length - 1].isLogged;
    }
  }

  // ........................................................................
  // --- if stack is empty, log the error, but continue
  returnFrom(fName) {
    var fullName, isLogged;
    if (this.lStack.length === 0) {
      LOG(`ERROR: returnFrom('${fName}') but stack is empty`);
      return;
    }
    ({fullName, isLogged} = this.lStack.pop());
    if (doDebugStack) {
      LOG(this.indent() + `[<-- BACK ${fName}]`);
    }
    if (fullName !== fName) {
      LOG(`ERROR: returnFrom('${fName}') but TOS is ${fullName}`);
      return;
    }
  }

  // ........................................................................
  curFunc() {
    if (this.lStack.length === 0) {
      return 'main';
    } else {
      return this.lStack[this.lStack.length - 1].funcName;
    }
  }

  // ........................................................................
  isActive(funcName) {
    var h, j, len, ref;
    ref = this.lStack;
    // --- funcName won't be <obj>.<method>
    //     but the stack might contain that form
    for (j = 0, len = ref.length; j < len; j++) {
      h = ref[j];
      if (h.funcName === funcName) {
        return true;
      }
    }
    return false;
  }

  // ........................................................................
  dump(label = "CALL STACK") {
    var i, item, j, lLines, len, ref;
    lLines = [label];
    if (this.lStack.length === 0) {
      lLines.push("   <EMPTY>");
    } else {
      ref = this.lStack;
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        item = ref[i];
        lLines.push("   " + this.callStr(i, item));
      }
    }
    return lLines.join("\n");
  }

  // ........................................................................
  callStr(i, item) {
    var arg, j, len, ref, str, sym;
    sym = item.isLogged ? '*' : '-';
    str = `${i}: ${sym}${item.fullName}`;
    ref = item.lArgs;
    for (j = 0, len = ref.length; j < len; j++) {
      arg = ref[j];
      str += ` ${OL(arg)}`;
    }
    return str;
  }

  // ........................................................................
  sdump(label = 'CALL STACK') {
    var item, j, lFuncNames, len, ref;
    lFuncNames = [];
    ref = this.lStack;
    for (j = 0, len = ref.length; j < len; j++) {
      item = ref[j];
      if (item.isLogged) {
        lFuncNames.push('*' + item.fullName);
      } else {
        lFuncNames.push(item.fullName);
      }
    }
    if (this.lStack.length === 0) {
      return `${label} <EMPTY>`;
    } else {
      return `${label} ${lFuncNames.join(' ')}`;
    }
  }

};
