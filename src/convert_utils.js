// Generated by CoffeeScript 2.5.1
// convert_utils.coffee
var hExtToEnvVar;

import {
  strict as assert
} from 'assert';

import {
  dirname,
  resolve,
  parse as parse_fname
} from 'path';

import CoffeeScript from 'coffeescript';

import marked from 'marked';

import sass from 'sass';

import {
  say,
  undef,
  pass,
  error,
  isEmpty,
  taml,
  unitTesting
} from '@jdeighan/coffee-utils';

import {
  splitLine,
  indentedStr,
  indentedBlock,
  undentedBlock
} from '@jdeighan/coffee-utils/indent';

import {
  slurp,
  pathTo
} from '@jdeighan/coffee-utils/fs';

import {
  setDebugging
} from '@jdeighan/coffee-utils/debug';

import {
  svelteHtmlEsc
} from '../src/svelte_utils.js';

import {
  StringInput
} from '@jdeighan/string-input';

/* -------------------------------------------------------------------------

- removes blank lines and comments

- converts
		<varname> <== <expr>
	to:
		`$: <varname> = <expr>;`

- converts
		<== <expr>
	to:
		`$: <expr>;`

- converts
		<===
			<code>
	to:
		```
		$: {
			<code>
			}
*/
// ---------------------------------------------------------------------------
// --- export to allow unit testing
export var CoffeeMapper = class CoffeeMapper extends StringInput {
  mapLine(orgLine) {
    var _, code, err, expr, jsCode, jsExpr, lMatches, level, line, result, varname;
    [level, line] = splitLine(orgLine);
    if (isEmpty(line) || line.match(/^#\s/)) {
      return undef;
    }
    if (lMatches = line.match(/^(?:([A-Za-z][A-Za-z0-9_]*)\s*)?\<\=\=\s*(.*)$/)) { // variable name
      [_, varname, expr] = lMatches;
      if (expr) {
        try {
          // --- convert to JavaScript if not unit testing ---
          jsExpr = brewCoffee(expr).trim(); // will have trailing ';'
        } catch (error1) {
          err = error1;
          error(err.message);
        }
        if (varname) {
          result = indentedStr(`\`\$\: ${varname} = ${jsExpr}\``, level);
        } else {
          result = indentedStr(`\`\$\: ${jsExpr}\``, level);
        }
      } else {
        if (varname) {
          error("Invalid syntax - variable name not allowed");
        }
        code = this.fetchBlock(level + 1);
        try {
          jsCode = brewCoffee(code);
        } catch (error1) {
          err = error1;
          error(err.message);
        }
        result = `\`\`\`
\$\: {
${indentedBlock(jsCode, 1)}
${indentedStr('}', 1)}
\`\`\``;
      }
      return indentedBlock(result, level);
    } else {
      return orgLine;
    }
  }

};

// ---------------------------------------------------------------------------
export var brewExpr = function(expr) {
  var err, newexpr, pos;
  if (unitTesting) {
    return expr;
  }
  try {
    newexpr = CoffeeScript.compile(expr, {
      bare: true
    }).trim();
    pos = newexpr.length - 1;
    if (newexpr.substr(pos, 1) === ';') {
      newexpr = newexpr.substr(0, pos);
    }
  } catch (error1) {
    err = error1;
    say("CoffeeScript error!");
    say(expr, "expr:");
    error(`CoffeeScript error: ${err.message}`);
  }
  return newexpr;
};

// ---------------------------------------------------------------------------
export var brewCoffee = function(text) {
  var err, newtext, oInput, script;
  if (unitTesting) {
    return text;
  }
  try {
    oInput = new CoffeeMapper(text);
    newtext = oInput.getAllText();
    script = CoffeeScript.compile(newtext, {
      bare: true
    });
  } catch (error1) {
    err = error1;
    say("CoffeeScript error!");
    say(text, "Original Text:");
    say(newtext, "Mapped Text:");
    error(`CoffeeScript error: ${err.message}`);
  }
  return script;
};

// ---------------------------------------------------------------------------
export var markdownify = function(text) {
  var html;
  if (unitTesting) {
    return text;
  }
  html = marked(undentedBlock(text), {
    grm: true,
    headerIds: false
  });
  return svelteHtmlEsc(html);
};

// ---------------------------------------------------------------------------
// --- export to allow unit testing
export var SassMapper = class SassMapper extends StringInput {
  mapLine(line) {
    if (line.match(/^\s*$/) || line.match(/^\s*#\s/)) {
      return undef;
    }
    return line;
  }

};

// ---------------------------------------------------------------------------
export var sassify = function(text) {
  var newtext, oInput, result;
  if (unitTesting) {
    return text;
  }
  oInput = new SassMapper(text);
  newtext = oInput.getAllText();
  result = sass.renderSync({
    data: newtext,
    indentedSyntax: true,
    indentType: "tab"
  });
  return result.css.toString();
};

// ---------------------------------------------------------------------------
hExtToEnvVar = {
  '.md': 'DIR_MARKDOWN',
  '.taml': 'DIR_DATA',
  '.txt': 'DIR_DATA'
};

// ---------------------------------------------------------------------------
export var getFileContents = function(fname, convert = false) {
  var base, contents, dir, envvar, ext, fullpath, root;
  if (unitTesting) {
    return `Contents of ${fname}`;
  }
  ({root, dir, base, ext} = parse_fname(fname.trim()));
  assert(!root && !dir, "getFileContents():" + ` root='${root}', dir='${dir}'` + " - full path not allowed");
  envvar = hExtToEnvVar[ext];
  assert(envvar, `getFileContents() doesn't work for ext '${ext}'`);
  dir = process.env[envvar];
  assert(dir, `No env var set for file extension '${ext}'`);
  fullpath = pathTo(base, dir); // guarantees that file exists
  contents = slurp(fullpath);
  if (!convert) {
    return contents;
  }
  switch (ext) {
    case '.md':
      return markdownify(contents);
    case '.taml':
      return taml(contents);
    case '.txt':
      return contents;
    default:
      return error(`getFileContents(): No handler for ext '${ext}'`);
  }
};
