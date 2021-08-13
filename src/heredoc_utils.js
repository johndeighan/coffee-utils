// Generated by CoffeeScript 2.5.1
// heredoc_utils.coffee
var stdCallback;

import {
  say,
  isTAML,
  taml,
  warn,
  error
} from '@jdeighan/coffee-utils';

import {
  debug
} from '@jdeighan/coffee-utils/debug';

import {
  undentedBlock
} from '@jdeighan/coffee-utils/indent';

// ---------------------------------------------------------------------------
export var numHereDocs = function(str) {
  var n, pos;
  n = 0;
  pos = str.indexOf('<<<');
  while (pos !== -1) {
    n += 1;
    pos = str.indexOf('<<<', pos + 3);
  }
  return n;
};

// ---------------------------------------------------------------------------
export var patch = function(line, lSections, callBack = stdCallback) {
  var i, lLines, lParts, len, n, pos, start;
  lParts = []; // joined at the end
  pos = 0;
  for (i = 0, len = lSections.length; i < len; i++) {
    lLines = lSections[i];
    start = line.indexOf('<<<', pos);
    if (start === -1) {
      error("patch(): No HEREDOC marker found");
    }
    lParts.push(line.substring(pos, start));
    lParts.push(callBack(lLines));
    pos = start + 3;
  }
  if (line.indexOf('<<<', pos) !== -1) {
    n = numHereDocs(line);
    error(`patch(): Not all ${n} HEREDOC markers were replaced` + `in '${line}'`);
  }
  lParts.push(line.substring(pos, line.length));
  return lParts.join('');
};

// ---------------------------------------------------------------------------
stdCallback = function(lLines) {
  return JSON.stringify(build(lLines));
};

// ---------------------------------------------------------------------------
export var build = function(lLines) {
  var str;
  // --- if lLines is empty or of length 0:
  //        returns empty string
  if (lLines == null) {
    debug("build(): lLines undefined - return ''");
    return '';
  }
  if (lLines.length === 0) {
    debug("build(): lLines len = 0 - return ''");
    return '';
  }
  // --- This removes whatever indentation is found on
  //     the first line from ALL lines
  debug(JSON.stringify(lLines), "   UNDENT:");
  str = undentedBlock(lLines);
  if (isTAML(str)) {
    debug("   TAML found - converting");
    return taml(str);
  } else {
    return str;
  }
};
