// Generated by CoffeeScript 2.5.1
  // UnitTester.coffee
import {
  strict as assert
} from 'assert';

import test from 'ava';

import {
  undef,
  error,
  stringToArray,
  isString,
  isFunction,
  isInteger,
  isArray
} from '@jdeighan/coffee-utils';

import {
  log,
  currentLogger,
  setLogger
} from '@jdeighan/coffee-utils/log';

import {
  debug,
  debugging,
  setDebugging
} from '@jdeighan/coffee-utils/debug';

// ---------------------------------------------------------------------------
export var UnitTester = class UnitTester {
  constructor(whichTest = 'deepEqual', fulltest = false) {
    this.fulltest = fulltest;
    this.hFound = {};
    this.setWhichTest(whichTest);
    this.justshow = false;
    this.testing = true;
    this.maxLineNum = undef;
  }

  // ........................................................................
  justshow(flag) {
    this.justshow = flag;
  }

  // ........................................................................
  just_show(flag) {
    this.justshow = flag;
  }

  // ........................................................................
  setMaxLineNum(n) {
    this.maxLineNum = n;
  }

  // ........................................................................
  setWhichTest(testName) {
    this.whichTest = testName;
  }

  // ........................................................................
  truthy(lineNum, input, expected) {
    this.setWhichTest('truthy');
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  falsy(lineNum, input, expected) {
    this.setWhichTest('falsy');
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  equal(lineNum, input, expected) {
    if (isString(input) && isString(expected)) {
      this.setWhichTest('is');
    } else {
      this.setWhichTest('deepEqual');
    }
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  notequal(lineNum, input, expected) {
    this.setWhichTest('notDeepEqual');
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  same(lineNum, input, expected) {
    this.setWhichTest('is');
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  different(lineNum, input, expected) {
    this.setWhichTest('not');
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  fails(lineNum, func, expected) {
    var err, logger, ok;
    assert(expected == null, "UnitTester: fails doesn't allow expected");
    assert(isFunction(func), "UnitTester: fails requires a function");
    // --- disable logging
    logger = currentLogger();
    setLogger(function(x) {
      return pass;
    });
    try {
      func();
      ok = true;
    } catch (error1) {
      err = error1;
      ok = false;
    }
    setLogger(logger);
    this.setWhichTest('falsy');
    this.test(lineNum, ok, expected);
  }

  // ........................................................................
  succeeds(lineNum, func, expected) {
    var err, ok;
    assert(expected == null, "UnitTester: succeeds doesn't allow expected");
    assert(isFunction(func), "UnitTester: succeeds requires a function");
    try {
      func();
      ok = true;
    } catch (error1) {
      err = error1;
      ok = false;
    }
    this.setWhichTest('truthy');
    this.test(lineNum, ok, expected);
  }

  // ........................................................................
  same_list(lineNum, list, expected) {
    assert((list == null) || isArray(list), "UnitTester: not an array");
    assert((expected == null) || isArray(expected), "UnitTester: expected is not an array");
    this.setWhichTest('deepEqual');
    this.test(lineNum, list.sort(), expected.sort());
  }

  // ........................................................................
  not_same_list(lineNum, list, expected) {
    assert((list == null) || isArray(list), "UnitTester: not an array");
    assert((expected == null) || isArray(expected), "UnitTester: expected is not an array");
    this.setWhichTest('notDeepEqual');
    this.test(lineNum, list.sort(), expected.sort());
  }

  // ........................................................................
  normalize(input) {
    var lLines, line;
    // --- Convert all whitespace to single space character
    //     Remove empty lines
    if (isString(input)) {
      lLines = (function() {
        var i, len, ref, results;
        ref = stringToArray(input);
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          line = ref[i];
          line = line.trim();
          results.push(line.replace(/\s+/g, ' '));
        }
        return results;
      })();
      lLines = lLines.filter(function(line) {
        return line !== '';
      });
      return lLines.join('\n');
    } else {
      return input;
    }
  }

  // ........................................................................
  test(lineNum, input, expected) {
    var err, errMsg, got, whichTest;
    this.lineNum = lineNum; // set an object property
    if ((lineNum < 0) && process.env.FINALTEST) {
      error("Negative line numbers not allowed in FINALTEST");
    }
    if (!this.testing || (this.maxLineNum && (lineNum > this.maxLineNum))) {
      return;
    }
    if (lineNum < -100000) {
      setDebugging(true);
    }
    assert(isInteger(lineNum), "UnitTester.test(): arg 1 must be an integer");
    lineNum = this.getLineNum(lineNum); // corrects for duplicates
    errMsg = undef;
    try {
      got = this.transformValue(input);
      if (isString(got)) {
        got = this.normalize(got);
      }
    } catch (error1) {
      err = error1;
      errMsg = err.message || 'UNKNOWN ERROR';
      log(`got ERROR: ${errMsg}`);
    }
    if (isString(expected)) {
      expected = this.normalize(expected);
    }
    if (this.justshow) {
      log(`line ${lineNum}`);
      if (errMsg) {
        log(`GOT ERROR ${errMsg}`);
      } else {
        log(got, "GOT:");
      }
      log(expected, "EXPECTED:");
      if (lineNum < -100000) {
        setDebugging(false);
      }
      return;
    }
    // --- We need to save this here because in the tests themselves,
    //     'this' won't be correct
    whichTest = this.whichTest;
    if (lineNum < 0) {
      test.only(`line ${lineNum}`, function(t) {
        return t[whichTest](got, expected);
      });
      this.testing = false;
    } else {
      test(`line ${lineNum}`, function(t) {
        return t[whichTest](got, expected);
      });
    }
    if (lineNum < -100000) {
      setDebugging(false);
    }
  }

  // ........................................................................
  transformValue(input) {
    return input;
  }

  // ........................................................................
  getLineNum(lineNum) {
    if (this.fulltest && (lineNum < 0)) {
      error("UnitTester(): negative line number during full test!!!");
    }
    // --- patch lineNum to avoid duplicates
    while (this.hFound[lineNum]) {
      if (lineNum < 0) {
        lineNum -= 1000;
      } else {
        lineNum += 1000;
      }
    }
    this.hFound[lineNum] = true;
    return lineNum;
  }

};

// ---------------------------------------------------------------------------
