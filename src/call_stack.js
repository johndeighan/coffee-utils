// Generated by CoffeeScript 2.7.0
// call_stack.coffee
var doDebugStack;

import {
  undef,
  defined,
  croak,
  assert,
  isBoolean
} from '@jdeighan/coffee-utils';

import {
  log,
  LOG
} from '@jdeighan/coffee-utils/log';

import {
  getPrefix
} from '@jdeighan/coffee-utils/arrow';

doDebugStack = false;

// ---------------------------------------------------------------------------
export var debugStack = function(flag = true) {
  doDebugStack = flag;
};

// ---------------------------------------------------------------------------
export var CallStack = class CallStack {
  constructor() {
    this.reset();
  }

  // ........................................................................
  reset() {
    if (doDebugStack) {
      LOG("RESET STACK");
    }
    this.lStack = [];
    this.level = 0;
  }

  // ........................................................................
  addCall(funcName, hInfo, isLogged) {
    this.lStack.push({funcName, hInfo, isLogged});
    if (isLogged) {
      this.level += 1;
    }
  }

  // ........................................................................
  removeCall(fName) {
    var funcName, hInfo, isLogged;
    ({funcName, hInfo, isLogged} = this.lStack.pop());
    if (isLogged && (this.level > 0)) {
      this.level -= 1;
    }
    while ((funcName !== fName) && (this.lStack.length > 0)) {
      LOG(`[MISSING RETURN FROM ${funcName} (return from ${fName})]`);
      ({funcName, hInfo, isLogged} = this.lStack.pop());
      if (isLogged && (this.level > 0)) {
        this.level -= 1;
      }
    }
    if (funcName === fName) {
      return hInfo;
    } else {
      this.dump();
      LOG(`BAD BAD BAD BAD returnFrom('${fName}')`);
      return undef;
    }
  }

  // ........................................................................
  // ........................................................................
  doCall(funcName, hInfo, isLogged) {
    var auxPre, mainPre, prefix;
    assert(isBoolean(isLogged), "CallStack.call(): 3 args required");
    mainPre = getPrefix(this.level);
    if (doDebugStack) {
      prefix = '   '.repeat(this.lStack.length);
      LOG(`${prefix}[--> CALL ${funcName}]`);
    }
    this.addCall(funcName, hInfo, isLogged);
    auxPre = getPrefix(this.level);
    return [mainPre, auxPre];
  }

  // ........................................................................
  logStr() {
    var pre;
    pre = getPrefix(this.level);
    return [pre, pre, undef];
  }

  // ........................................................................
  returnFrom(funcName) {
    var auxPre, hInfo, mainPre, prefix;
    // --- Prefixes are based on level before stack adjustment
    mainPre = getPrefix(this.level, 'withArrow');
    auxPre = getPrefix(this.level, 'returnVal');
    if (this.lStack.length === 0) {
      LOG(`returnFrom('${funcName}') but stack is empty`);
      return [mainPre, auxPre, undef];
    }
    hInfo = this.removeCall(funcName);
    if (doDebugStack) {
      prefix = '   '.repeat(this.lStack.length);
      LOG(`${prefix}[<-- BACK ${funcName}]`);
    }
    return [mainPre, auxPre, hInfo];
  }

  // ........................................................................
  // ........................................................................
  dump(label = 'CALL STACK') {
    var i, item, j, len, ref;
    LOG(`${label}:`);
    if (this.lStack.length === 0) {
      LOG("   <EMPTY>");
    } else {
      ref = this.lStack;
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        item = ref[i];
        LOG(`   ${i}: ${JSON.stringify(item)}`);
      }
    }
  }

};
