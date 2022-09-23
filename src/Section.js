// Generated by CoffeeScript 2.7.0
  // Section.coffee
import {
  assert,
  croak
} from '@jdeighan/exceptions';

import {
  pass,
  undef,
  defined,
  isArray,
  isEmpty
} from '@jdeighan/coffee-utils';

import {
  arrayToBlock
} from '@jdeighan/coffee-utils/block';

import {
  indented
} from '@jdeighan/coffee-utils/indent';

import {
  debug
} from '@jdeighan/coffee-utils/debug';

// ---------------------------------------------------------------------------
export var Section = class Section {
  constructor(name, content = undef) {
    this.name = name;
    // --- name can be undef or empty
    this.lParts = [];
    if (defined(content)) {
      this.lParts.push(content);
    }
  }

  // ..........................................................
  length() {
    return this.lParts.length;
  }

  // ..........................................................
  indent(level = 1, oneIndent = "\t") {
    var lNewLines, line;
    lNewLines = (function() {
      var i, len, ref, results;
      ref = this.lParts;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        line = ref[i];
        results.push(indented(line, level, oneIndent));
      }
      return results;
    }).call(this);
    this.lParts = lNewLines;
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
    var result;
    debug("enter Section.getBlock()");
    if (this.lParts.length === 0) {
      debug("return undef from Section.getBlock()");
      return undef;
    } else {
      result = arrayToBlock(this.lParts);
      debug("return from Section.getBlock()", result);
      return result;
    }
  }

};
