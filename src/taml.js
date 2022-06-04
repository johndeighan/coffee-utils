// Generated by CoffeeScript 2.7.0
// taml.coffee
var squote;

import yaml from 'js-yaml';

import {
  assert,
  undef,
  oneline,
  isString
} from '@jdeighan/coffee-utils';

import {
  untabify,
  tabify,
  splitLine
} from '@jdeighan/coffee-utils/indent';

import {
  slurp
} from '@jdeighan/coffee-utils/fs';

import {
  debug
} from '@jdeighan/coffee-utils/debug';

import {
  firstLine,
  blockToArray,
  arrayToBlock
} from '@jdeighan/coffee-utils/block';

// ---------------------------------------------------------------------------
//   isTAML - is the string valid TAML?
export var isTAML = function(text) {
  return isString(text) && (firstLine(text).indexOf('---') === 0);
};

// ---------------------------------------------------------------------------
squote = function(text) {
  return "'" + text.replace(/'/g, "''") + "'";
};

// ---------------------------------------------------------------------------
//   taml - convert valid TAML string to a JavaScript value
export var taml = function(text) {
  var _, key, lLines, lMatches, level, line, prefix, str;
  debug(`enter taml(${oneline(text)})`);
  if (text == null) {
    debug("return undef from taml() - text is not defined");
    return undef;
  }
  assert(isTAML(text), `taml(): string ${oneline(text)} isn't TAML`);
  lLines = (function() {
    var i, len, ref, results;
    ref = blockToArray(text);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      line = ref[i];
      [level, str] = splitLine(line);
      prefix = ' '.repeat(level);
      if (lMatches = line.match(/^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.*)$/)) { // the key
        [_, key, text] = lMatches;
        if (isEmpty(text) || text.match(/\d+(?:\.\d*)$/)) {
          results.push(prefix + str);
        } else {
          results.push(prefix + key + ':' + ' ' + squote(text));
        }
      } else {
        results.push(prefix + str);
      }
    }
    return results;
  })();
  debug("return from taml()");
  return yaml.load(arrayToBlock(lLines), {
    skipInvalid: true
  });
};

// ---------------------------------------------------------------------------
//   slurpTAML - read TAML from a file
export var slurpTAML = function(filepath) {
  var contents;
  contents = slurp(filepath);
  return taml(contents);
};
