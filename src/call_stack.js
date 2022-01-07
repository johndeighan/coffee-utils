// Generated by CoffeeScript 2.6.1
  // call_stack.coffee
import {
  undef,
  croak
} from '@jdeighan/coffee-utils';

import {
  log
} from '@jdeighan/coffee-utils/log';

// ---------------------------------------------------------------------------
export var CallStack = class CallStack {
  constructor() {
    this.reset();
  }

  // ........................................................................
  call(funcName, hInfo) {
    this.lStack.push({funcName, hInfo});
  }

  // ........................................................................
  returnFrom(fName) {
    var funcName, hInfo;
    if (this.lStack.length === 0) {
      croak(`returnFrom('${fName}') but stack is empty`);
    }
    ({funcName, hInfo} = this.lStack.pop());
    if (funcName !== fName) {
      this.dump();
      croak(`returnFrom('${fName}') but TOS is '${funcName}'`);
    }
    return hInfo;
  }

  // ........................................................................
  reset() {
    return this.lStack = [];
  }

  // ........................................................................
  dump(label = 'CALL STACK') {
    var i, item, j, len, ref;
    console.log(`${label}:`);
    ref = this.lStack;
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      item = ref[i];
      console.log(`${i}: ${JSON.stringify(item)}`);
    }
  }

};