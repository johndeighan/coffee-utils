// Generated by CoffeeScript 2.7.0
  // Section.coffee
import {
  assert,
  error,
  croak
} from '@jdeighan/unit-tester/utils';

import {
  pass,
  undef,
  defined,
  isArray
} from '@jdeighan/coffee-utils';

import {
  arrayToBlock
} from '@jdeighan/coffee-utils/block';

import {
  indented
} from '@jdeighan/coffee-utils/indent';

// ---------------------------------------------------------------------------
export var Section = class Section {
  constructor(name) {
    this.name = name;
    this.lParts = [];
  }

  // ..........................................................
  length() {
    return this.lParts.length;
  }

  // ..........................................................
  indent(level = 1) {
    var lNewLines, line;
    lNewLines = (function() {
      var i, len, ref, results;
      ref = this.lParts;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        line = ref[i];
        results.push(indented(line, level));
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
    if (this.lParts.length === 0) {
      return undef;
    } else {
      return arrayToBlock(this.lParts);
    }
  }

};
