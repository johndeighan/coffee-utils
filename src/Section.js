// Generated by CoffeeScript 2.7.0
  // Section.coffee
import {
  assert,
  pass,
  undef,
  defined,
  croak,
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
  constructor() {
    this.lLines = [];
  }

  // ..........................................................
  length() {
    return this.lLines.length;
  }

  // ..........................................................
  indent(level = 1) {
    var lNewLines, line;
    lNewLines = (function() {
      var i, len, ref, results;
      ref = this.lLines;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        line = ref[i];
        results.push(indented(line, level));
      }
      return results;
    }).call(this);
    this.lLines = lNewLines;
  }

  // ..........................................................
  isEmpty() {
    return this.lLines.length === 0;
  }

  // ..........................................................
  nonEmpty() {
    return this.lLines.length > 0;
  }

  // ..........................................................
  add(data) {
    var i, len, line;
    if (isArray(data)) {
      for (i = 0, len = data.length; i < len; i++) {
        line = data[i];
        this.lLines.push(line);
      }
    } else {
      this.lLines.push(data);
    }
  }

  // ..........................................................
  prepend(data) {
    if (isArray(data)) {
      this.lLines = [...data, ...this.lLines];
    } else {
      this.lLines = [data, ...this.lLines];
    }
  }

  // ..........................................................
  getBlock() {
    return arrayToBlock(this.lLines);
  }

};
