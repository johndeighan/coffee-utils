// Generated by CoffeeScript 2.7.0
  // arrow.coffee
import {
  undef,
  OL,
  setCharsAt
} from '@jdeighan/coffee-utils';

// --- We use spaces here because Windows Terminal handles TAB chars badly
export var vbar = '│'; // unicode 2502

export var hbar = '─'; // unicode 2500

export var corner = '└'; // unicode 2514

export var arrowhead = '>';

export var space = ' ';

export var oneIndent = vbar + space + space + space;

export var arrow = corner + hbar + arrowhead + space;

export var clearIndent = space + space + space + space;

// ---------------------------------------------------------------------------
export var prefix = function(level, option = 'none') {
  var result;
  switch (option) {
    case 'withArrow':
      result = oneIndent.repeat(level - 1) + arrow;
      break;
    case 'noLastVbar':
      result = oneIndent.repeat(level - 1) + clearIndent;
      break;
    case 'none':
      result = oneIndent.repeat(level);
      break;
    default:
      throw new Error(`prefix(): Bad option: '${option}'`);
  }
  if (result.length % 4 !== 0) {
    throw new Error(`prefix(): Bad prefix '${result}'`);
  }
  return result;
};

// ---------------------------------------------------------------------------
export var addArrow = function(prefix) {
  var pos, result;
  pos = prefix.lastIndexOf(vbar);
  if (pos === -1) {
    result = prefix;
  } else {
    result = setCharsAt(prefix, pos, arrow);
  }
  return result;
};

// ---------------------------------------------------------------------------
export var removeLastVbar = function(prefix) {
  var pos, result;
  pos = prefix.lastIndexOf(vbar);
  if (pos === -1) {
    result = prefix;
  } else {
    result = setCharsAt(prefix, pos, ' ');
  }
  return result;
};
