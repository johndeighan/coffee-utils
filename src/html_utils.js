// Generated by CoffeeScript 2.7.0
// html_utils.coffee
var hNoEnd, i, len, ref, tagName;

import {
  assert,
  croak
} from '@jdeighan/unit-tester/utils';

import {
  undef,
  pass,
  words,
  isEmpty,
  nonEmpty
} from '@jdeighan/coffee-utils';

import {
  indented,
  enclose
} from '@jdeighan/coffee-utils/indent';

import {
  arrayToBlock
} from '@jdeighan/coffee-utils/block';

import {
  debug
} from '@jdeighan/coffee-utils/debug';

hNoEnd = {};

ref = words('area base br col command embed hr img input' + ' keygen link meta param source track wbr');
for (i = 0, len = ref.length; i < len; i++) {
  tagName = ref[i];
  hNoEnd[tagName] = true;
}

// ---------------------------------------------------------------------------
export var parsetag = function(line) {
  var _, all, attrName, br_val, className, dq_val, hAttr, hToken, ident, j, lClasses, lMatches, len1, modifiers, prefix, quote, ref1, rest, sq_val, subtype, uq_val, value, varName;
  if (lMatches = line.match(/^(?:([A-Za-z][A-Za-z0-9_]*)\s*=\s*)?([A-Za-z][A-Za-z0-9_]*)(?:\:([a-z]+))?(\S*)\s*(.*)$/)) { // variable name
    // variable is optional
    // tag name
    // modifiers (class names, etc.)
    // attributes & enclosed text
    [_, varName, tagName, subtype, modifiers, rest] = lMatches;
  } else {
    croak(`parsetag(): Invalid HTML: '${line}'`);
  }
  // --- Handle classes - subtypes and added via .<class>
  lClasses = [];
  if (nonEmpty(subtype) && (tagName !== 'svelte')) {
    lClasses.push(subtype);
  }
  if (modifiers) {
    // --- currently, these are only class names
    while (lMatches = modifiers.match(/^\.([A-Za-z][A-Za-z0-9_]*)/)) {
      [all, className] = lMatches;
      lClasses.push(className);
      modifiers = modifiers.substring(all.length);
    }
    if (modifiers) {
      croak(`parsetag(): Invalid modifiers in '${line}'`);
    }
  }
  // --- Handle attributes
  hAttr = {}; // { name: { value: <value>, quote: <quote> }, ... }
  if (varName) {
    hAttr['bind:this'] = {
      value: varName,
      quote: '{'
    };
  }
  if ((tagName === 'script') && (subtype === 'startup')) {
    hAttr['context'] = {
      value: 'module',
      quote: '"'
    };
  }
  if (rest) {
    while (lMatches = rest.match(/^(?:(?:(?:(bind|on):)?([A-Za-z][A-Za-z0-9_]*))=(?:\{([^}]*)\}|"([^"]*)"|'([^']*)'|([^"'\s]+))|\{([A-Za-z][A-Za-z0-9_]*)\})\s*/)) { // prefix
      // attribute name
      // attribute value
      [all, prefix, attrName, br_val, dq_val, sq_val, uq_val, ident] = lMatches;
      if (ident) {
        hAttr[ident] = {
          value: ident,
          shorthand: true
        };
      } else {
        if (br_val) {
          value = br_val;
          quote = '{';
        } else {
          assert(prefix == null, "prefix requires use of {...}");
          if (dq_val) {
            value = dq_val;
            quote = '"';
          } else if (sq_val) {
            value = sq_val;
            quote = "'";
          } else {
            value = uq_val;
            quote = '';
          }
        }
        if (prefix) {
          attrName = `${prefix}:${attrName}`;
        }
        if (attrName === 'class') {
          ref1 = value.split(/\s+/);
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            className = ref1[j];
            lClasses.push(className);
          }
        } else {
          if (hAttr.attrName != null) {
            croak(`parsetag(): Multiple attributes named '${attrName}'`);
          }
          hAttr[attrName] = {value, quote};
        }
      }
      rest = rest.substring(all.length);
    }
  }
  // --- The rest is contained text
  rest = rest.trim();
  if (lMatches = rest.match(/^['"](.*)['"]$/)) {
    rest = lMatches[1];
  }
  // --- Add class attribute to hAttr if there are classes
  if (lClasses.length > 0) {
    hAttr.class = {
      value: lClasses.join(' '),
      quote: '"'
    };
  }
  // --- Build the return value
  hToken = {
    type: 'tag',
    tagName
  };
  if (subtype) {
    hToken.subtype = subtype;
    hToken.orgtag = `${tagName}:${subtype}`;
  } else {
    hToken.orgtag = tagName;
  }
  // --- if tagName == 'svelte', set hToken.tagName to hToken.orgtag
  if (tagName === 'svelte') {
    hToken.tagName = hToken.orgtag;
  }
  if (nonEmpty(hAttr)) {
    hToken.hAttr = hAttr;
  }
  // --- Is there contained text?
  if (rest) {
    hToken.text = rest;
  }
  return hToken;
};

// ---------------------------------------------------------------------------
// --- export only for unit testing
export var attrStr = function(hAttr) {
  var attrName, bquote, equote, j, len1, quote, ref1, shorthand, str, value;
  if (!hAttr) {
    return '';
  }
  str = '';
  ref1 = Object.getOwnPropertyNames(hAttr);
  for (j = 0, len1 = ref1.length; j < len1; j++) {
    attrName = ref1[j];
    ({value, quote, shorthand} = hAttr[attrName]);
    if (shorthand) {
      str += ` {${value}}`;
    } else {
      if (quote === '{') {
        bquote = '{';
        equote = '}';
      } else {
        bquote = equote = quote;
      }
      str += ` ${attrName}=${bquote}${value}${equote}`;
    }
  }
  return str;
};

// ---------------------------------------------------------------------------
export var tag2str = function(hToken, type = 'begin') {
  var hAttr, str;
  ({tagName, hAttr} = hToken);
  if (type === 'begin') {
    str = `<${tagName}`;
    if (nonEmpty(hAttr)) {
      str += attrStr(hAttr);
    }
    str += '>';
    return str;
  } else if (type === 'end') {
    if (hNoEnd[tagName]) {
      return undef;
    } else {
      return `</${tagName}>`;
    }
  } else {
    return croak("type must be 'begin' or 'end'");
  }
};

// ---------------------------------------------------------------------------
//    elem - indent text, surround with HTML tags
export var elem = function(tagName, hAttr = undef, text = undef, oneIndent = "\t") {
  var hToken;
  if (isEmpty(text)) {
    return undef;
  }
  hToken = {tagName, hAttr, text};
  return arrayToBlock([tag2str(hToken, 'begin'), indented(text, 1, oneIndent), tag2str(hToken, 'end')]);
};
