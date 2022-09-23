// Generated by CoffeeScript 2.7.0
  // fsa.coffee
import {
  LOG,
  assert,
  croak
} from '@jdeighan/exceptions';

import {
  undef,
  defined,
  notdefined,
  words,
  isEmpty,
  nonEmpty,
  isString,
  OL
} from '@jdeighan/coffee-utils';

import {
  toArray
} from '@jdeighan/coffee-utils/block';

import {
  debug
} from '@jdeighan/coffee-utils/debug';

// ---------------------------------------------------------------------------
export var FSA = class FSA {
  constructor(block) {
    var bState, eState, hTrans, i, j, lLines, lWords, len, line, output, token;
    debug("enter FSA()");
    assert(isString(block), "block not a string");
    this.hTransitions = {};
    lLines = toArray(block, 'noEmptyLines');
    debug('lLines', lLines);
    for (i = j = 0, len = lLines.length; j < len; i = ++j) {
      line = lLines[i];
      debug(`LINE ${i}`, line);
      lWords = words(line);
      if (lWords.length === 3) {
        [bState, token, eState] = lWords;
        output = undef;
      } else if (lWords.length === 4) {
        [bState, token, eState, output] = lWords;
      } else {
        croak(`Invalid desc: ${OL(line)}`);
      }
      debug(`LINE ${i}: ${OL(bState)} ${OL(token)} ${OL(eState)} ${OL(output)}`);
      assert(nonEmpty(eState), `Invalid FSA description ${i}`);
      // --- tokens may be quoted (but may not contain whitespace),
      //     but the quotes are stripped
      if (i === 0) {
        assert(bState === 'start', `Invalid FSA description ${i}`);
      }
      token = this.fixToken(token);
      debug('token', token);
      if (isEmpty(output)) {
        output = undef;
      }
      hTrans = this.hTransitions[bState];
      if (notdefined(hTrans)) {
        hTrans = this.hTransitions[bState] = {};
      }
      assert(notdefined(hTrans[token]), "Duplicate transition");
      hTrans[token] = [eState, output];
    }
    debug('hTransitions', this.hTransitions);
    this.curState = 'start';
    debug("return from FSA()");
  }

  // ..........................................................
  fixToken(token) {
    var lMatches;
    if (lMatches = token.match(/^\'(.*)\'$/)) {
      return lMatches[1];
    } else if (lMatches = token.match(/^\"(.*)\"$/)) {
      return lMatches[1];
    } else {
      return token;
    }
  }

  // ..........................................................
  got(token) {
    var hTrans, newState, output, result;
    // --- returns pair [newState, output]
    hTrans = this.hTransitions[this.curState];
    if (notdefined(hTrans)) {
      return [undef, undef];
    }
    result = hTrans[token];
    if (notdefined(result)) {
      return [undef, undef];
    }
    [newState, output] = result;
    assert(nonEmpty(newState), `Failed: ${this.curState} -> ${token}`);
    this.curState = newState;
    return result;
  }

  // ..........................................................
  state() {
    return this.curState;
  }

};
