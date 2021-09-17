// Generated by CoffeeScript 2.5.1
  // fs_utils.coffee
import {
  strict as assert
} from 'assert';

import {
  dirname,
  resolve,
  parse as parse_fname
} from 'path';

import {
  fileURLToPath
} from 'url';

import {
  existsSync,
  copyFileSync,
  readFileSync,
  writeFileSync,
  readdirSync,
  createReadStream
} from 'fs';

import {
  undef,
  pass,
  firstLine,
  rtrim,
  error,
  nonEmpty,
  isRegExp,
  isFunction,
  croak
} from '@jdeighan/coffee-utils';

import {
  log
} from '@jdeighan/coffee-utils/log';

import {
  debug
} from '@jdeighan/coffee-utils/debug';

// ---------------------------------------------------------------------------
//    mydir() - pass argument `import.meta.url` and it will return
//              the directory your file is in
export var mydir = function(url) {
  return mkpath(dirname(fileURLToPath(url)));
};

// ---------------------------------------------------------------------------
export var mkpath = function(...lParts) {
  return lParts.join('/').replace(/\\/g, '/');
};

// ---------------------------------------------------------------------------
export var getFullPath = function(filepath) {
  return mkpath(resolve(filepath));
};

// ---------------------------------------------------------------------------
//   backup - back up a file

// --- If report is true, missing source files are not an error
//     but both missing source files and successful copies
//     are reported via console.log
export var backup = function(file, from, to, report = false) {
  var dest, src;
  src = `${from}/${file}`;
  dest = `${to}/${file}`;
  if (report) {
    if (existsSync(src)) {
      console.log(`OK ${file}`);
      return copyFileSync(src, dest);
    } else {
      return console.log(`MISSING ${src}`);
    }
  } else {
    return copyFileSync(src, dest);
  }
};

// ---------------------------------------------------------------------------
//   slurp - read an entire file into a string
export var slurp = function(filepath) {
  var contents;
  debug(`enter slurp('${filepath}')`);
  filepath = filepath.replace(/\//g, "\\");
  contents = readFileSync(filepath, 'utf8').toString();
  debug("return from slurp()", contents);
  return contents;
};

// ---------------------------------------------------------------------------
//   barf - write a string to a file
export var barf = function(filepath, contents) {
  var err;
  debug(`enter barf('${filepath}')`, contents);
  contents = rtrim(contents) + "\n";
  try {
    writeFileSync(filepath, contents, {
      encoding: 'utf8'
    });
  } catch (error1) {
    err = error1;
    log(`barf(): write failed: ${err.message}`);
  }
  debug("return from barf()");
};

// ---------------------------------------------------------------------------
//   withExt - change file extention in a file name
export var withExt = function(filename, newExt) {
  var _, ext, lMatches, pre;
  assert(newExt, "withExt(): No newExt provided");
  if (newExt.indexOf('.') !== 0) {
    newExt = '.' + newExt;
  }
  if (lMatches = filename.match(/^(.*)\.([^.]+)$/)) {
    [_, pre, ext] = lMatches;
    return `${pre}${newExt}`;
  } else {
    return error(`withExt(): Invalid file name: '${filename}'`);
  }
};

// ---------------------------------------------------------------------------
//    Get all subdirectories of a directory
export var getSubDirs = function(dir) {
  return readdirSync(dir, {
    withFileTypes: true
  }).filter((d) => {
    return d.isDirectory();
  }).map((d) => {
    return mkpath(d.name);
  }).sort();
};

// ---------------------------------------------------------------------------
//    Get path to parent directory of a directory
export var getParentDir = function(dir) {
  var hParts;
  hParts = parse_fname(dir);
  if (hParts.dir === hParts.root) {
    return undef;
  }
  return mkpath(resolve(dir, '..'));
};

// ---------------------------------------------------------------------------
export var forEachFile = function(dir, cb, filt = undef, level = 0) {
  var ent, i, j, lSubDirectories, len, len1, ref, ref1, subdir;
  // --- filt can be a regular expression or a function that gets:
  //        (filename, dir, level)
  //     callback will get parms (filename, dir, level)
  lSubDirectories = [];
  ref = readdirSync(dir, {
    withFileTypes: true
  });
  for (i = 0, len = ref.length; i < len; i++) {
    ent = ref[i];
    if (ent.isDirectory()) {
      lSubDirectories.push(ent);
    } else if (ent.isFile()) {
      if (filt == null) {
        cb(ent.name, dir, level);
      } else if (isRegExp(filt)) {
        if (ent.name.match(filt)) {
          cb(ent.name, dir, level);
        } else if (isFunction(filt)) {
          if (filt(ent.name, dir, level)) {
            cb(ent.name, dir, level);
          }
        }
      } else {
        croak("forEachFile(): bad filter", 'filter', filt);
      }
    }
  }
  if (nonEmpty(lSubDirectories)) {
    ref1 = lSubDirectories.sort();
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      subdir = ref1[j];
      forEachFile(mkpath(dir, subdir.name), cb, filt, level + 1);
    }
  }
};

// ---------------------------------------------------------------------------
export var pathTo = function(fname, dir, direction = "down") {
  var fpath, i, len, ref, subdir;
  debug(`enter pathTo('${fname}','${dir}','${direction}')`);
  assert(existsSync(dir), `Directory ${dir} does not exist`);
  if (existsSync(`${dir}/${fname}`)) {
    debug(`return from pathTo: ${dir}/${fname} - file exists`);
    return mkpath(`${dir}/${fname}`);
  } else if (direction === 'down') {
    ref = getSubDirs(dir);
    // --- Search all directories in this directory
    for (i = 0, len = ref.length; i < len; i++) {
      subdir = ref[i];
      if (fpath = pathTo(fname, `${dir}/${subdir}`)) {
        debug(`return from pathTo: ${fpath}`);
        return fpath;
      }
    }
  } else if (direction === 'up') {
    while (dir = getParentDir(dir)) {
      debug(`check ${dir}`);
      if (existsSync(`${dir}/${fname}`)) {
        debug(`return from pathTo(): ${dir}/${fname}`);
        return `${dir}/${fname}`;
      }
    }
  } else {
    error(`pathTo(): Invalid direction '${direction}'`);
  }
  debug("return undef from pathTo - file not found");
  return undef;
};
