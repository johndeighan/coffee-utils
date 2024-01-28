// Generated by CoffeeScript 2.7.0
  // Section.coffee
import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  dbg,
  dbgEnter,
  dbgReturn
} from '@jdeighan/base-utils/debug';

import {
  pass,
  undef,
  defined,
  isArray,
  isEmpty,
  isFunction,
  toBlock
} from '@jdeighan/base-utils';

// ---------------------------------------------------------------------------
export var Section = class Section {
  constructor(name, replacer = undef) {
    this.name = name;
    this.replacer = replacer;
    // --- name can be undef or empty
    this.lParts = [];
    if (defined(this.replacer)) {
      assert(isFunction(this.replacer), "bad replacer");
    }
  }

  // ..........................................................
  isEmpty() {
    return this.lParts.length === 0;
  }

  // ..........................................................
  nonEmpty() {
    return this.lParts.length > 0;
  }

  // ..........................................................
  add(data) {
    var i, len, line;
    if (isArray(data)) {
      for (i = 0, len = data.length; i < len; i++) {
        line = data[i];
        this.lParts.push(line);
      }
    } else {
      this.lParts.push(data);
    }
  }

  // ..........................................................
  prepend(data) {
    if (isArray(data)) {
      this.lParts = [...data, ...this.lParts];
    } else {
      this.lParts = [data, ...this.lParts];
    }
  }

  // ..........................................................
  getParts() {
    return this.lParts;
  }

  // ..........................................................
  getBlock() {
    var block;
    dbgEnter("Section.getBlock");
    if (this.lParts.length === 0) {
      dbgReturn("Section.getBlock", undef);
      return undef;
    }
    block = toBlock(this.lParts);
    if (defined(this.replacer)) {
      block = this.replacer(block);
    }
    dbgReturn("Section.getBlock", block);
    return block;
  }

};

//# sourceMappingURL=Section.js.map
