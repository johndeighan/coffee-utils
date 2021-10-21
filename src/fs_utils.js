// Generated by CoffeeScript 2.6.1
// fs_utils.coffee
var withUnderScore;

import pathlib from 'path';

import urllib from 'url';

import fs from 'fs';

import {
  assert,
  undef,
  pass,
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
export var parseSource = function(source) {
  var dir, err, hInfo;
  // --- returns {
  //        dir
  //        filename   # only this is guaranteed to be set
  //        stub
  //        ext
  //        }
  debug("enter parseSource()");
  if (source === 'unit test') {
    debug("return 'unit test' from parseSource()");
    return {
      filename: 'unit test',
      stub: 'unit test'
    };
  }
  try {
    hInfo = pathlib.parse(source);
    debug("return from parseSource()", hInfo);
    if (hInfo.root) {
      dir = mkpath(hInfo.dir); // change \ to /
      return {
        dir: dir,
        fullpath: mkpath(dir, hInfo.base),
        filename: hInfo.base,
        stub: hInfo.name,
        ext: hInfo.ext
      };
    } else {
      return {
        dir: mkpath(hInfo.dir), // change \ to /
        filename: hInfo.base,
        stub: hInfo.name,
        ext: hInfo.ext
      };
    }
  } catch (error1) {
    err = error1;
    debug(`return '${err.message} from parseSource()`);
    return {
      filename: source,
      stub: source,
      error: err.message
    };
  }
};

// ---------------------------------------------------------------------------
//    mydir() - pass argument `import.meta.url` and it will return
//              the directory your file is in
export var mydir = function(url) {
  var dir;
  dir = pathlib.dirname(urllib.fileURLToPath(url));
  return mkpath(dir);
};

// ---------------------------------------------------------------------------
export var mkpath = function(...lParts) {
  var _, drive, lMatches, newPath, rest;
  newPath = lParts.join('/').replace(/\\/g, '/');
  if (lMatches = newPath.match(/^([A-Z])\:(.*)$/)) {
    [_, drive, rest] = lMatches;
    return `${drive.toLowerCase()}:${rest}`;
  } else {
    return newPath;
  }
};

// ---------------------------------------------------------------------------
export var getFullPath = function(filepath) {
  return mkpath(pathlib.resolve(filepath));
};

// ---------------------------------------------------------------------------
//   backup - back up a file

// --- If report is true, missing source files are not an error
//     but both missing source files and successful copies
//     are reported via console.log
export var backup = function(file, from, to, report = false) {
  var dest, src;
  src = mkpath(from, file);
  dest = mkpath(to, file);
  if (report) {
    if (fs.existsSync(src)) {
      console.log(`OK ${file}`);
      return fs.copyFileSync(src, dest);
    } else {
      return console.log(`MISSING ${src}`);
    }
  } else {
    return fs.copyFileSync(src, dest);
  }
};

// ---------------------------------------------------------------------------
//   slurp - read an entire file into a string
export var slurp = function(filepath) {
  var contents;
  debug(`enter slurp('${filepath}')`);
  filepath = filepath.replace(/\//g, "\\");
  contents = fs.readFileSync(filepath, 'utf8').toString();
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
    fs.writeFileSync(filepath, contents, {
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
//   withUnderScore - add '_' to file name
withUnderScore = function(path) {
  var h;
  h = pathlib.parse(path);
  return mkpath(h.dir, `_${h.base}`);
};

// ---------------------------------------------------------------------------
//    Get all subdirectories of a directory
export var getSubDirs = function(dir) {
  return fs.readdirSync(dir, {
    withFileTypes: true
  }).filter(function(d) {
    return d.isDirectory();
  }).map(function(d) {
    return mkpath(d.name);
  }).sort();
};

// ---------------------------------------------------------------------------
//    Get path to parent directory of a directory
export var getParentDir = function(dir) {
  var hParts;
  hParts = pathlib.parse(dir);
  if (hParts.dir === hParts.root) {
    return undef;
  }
  return mkpath(pathlib.resolve(dir, '..'));
};

// ---------------------------------------------------------------------------
export var forEachFile = function(dir, cb, filt = undef, level = 0) {
  var ent, i, j, lSubDirectories, len, len1, ref, ref1, subdir;
  // --- filt can be a regular expression or a function that gets:
  //        (filename, dir, level)
  //     callback will get parms (filename, dir, level)
  lSubDirectories = [];
  ref = fs.readdirSync(dir, {
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
  assert(fs.existsSync(dir), `Directory ${dir} does not exist`);
  if (fs.existsSync(`${dir}/${fname}`)) {
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
      if (fs.existsSync(`${dir}/${fname}`)) {
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

// ---------------------------------------------------------------------------
export var allPathsTo = function(fname, searchDir) {
  var h, lPaths, path;
  // --- Only searches upward
  path = pathTo(fname, searchDir, "up");
  if (path != null) {
    lPaths = [path]; // --- build an array of paths
    // --- search upward for files, but return ordered top down
    while ((h = pathlib.parse(path)) && (path = pathTo(fname, pathlib.resolve(h.dir, '..'), "up"))) {
      lPaths.unshift(path);
    }
    return lPaths;
  } else {
    return [];
  }
};

// ---------------------------------------------------------------------------
export var newerDestFileExists = function(srcPath, destPath) {
  var destModTime, srcModTime;
  debug("enter newerDestFileExists()");
  if (!fs.existsSync(destPath)) {
    debug("return false from newerDestFileExists() - no file");
    return false;
  }
  srcModTime = fs.statSync(srcPath).mtimeMs;
  destModTime = fs.statSync(destPath).mtimeMs;
  debug(`srcModTime = ${srcModTime}`);
  debug(`destModTime = ${destModTime}`);
  if (destModTime >= srcModTime) {
    debug(`${destPath} is up to date`);
    debug("return true from newerDestFileExists()");
    return true;
  } else {
    debug(`${destPath} is old`);
    debug("return false from newerDestFileExists()");
    return false;
  }
};

// ---------------------------------------------------------------------------
export var shortenPath = function(path) {
  var _, lMatches, str, tail;
  // --- Replace user's home dir with '~'
  str = mkpath(path);
  if (lMatches = str.match(/^[A-Za-z]:\/Users\/[a-z_][a-z0-9_]*\/(.*)$/i)) {
    [_, tail] = lMatches;
    return `~/${tail}`;
  } else {
    return str;
  }
};
