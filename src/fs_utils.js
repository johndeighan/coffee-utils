// Generated by CoffeeScript 2.6.1
// fs_utils.coffee
var isSystemDir;

import pathlib from 'path';

import urllib from 'url';

import fs from 'fs';

import NReadLines from 'n-readlines';

import {
  assert,
  undef,
  pass,
  rtrim,
  error,
  isEmpty,
  nonEmpty,
  isString,
  isArray,
  isRegExp,
  isFunction,
  croak,
  OL
} from '@jdeighan/coffee-utils';

import {
  log,
  LOG
} from '@jdeighan/coffee-utils/log';

import {
  debug
} from '@jdeighan/coffee-utils/debug';

import {
  arrayToBlock
} from '@jdeighan/coffee-utils/block';

// ---------------------------------------------------------------------------
//    mydir() - pass argument import.meta.url and it will return
//              the directory your file is in
export var mydir = function(url) {
  var dir, final, path;
  debug(`url = ${url}`);
  path = urllib.fileURLToPath(url);
  debug(`path = ${path}`);
  dir = pathlib.dirname(path);
  debug(`dir = ${dir}`);
  final = mkpath(dir);
  debug(`final = ${final}`);
  return final;
};

// ---------------------------------------------------------------------------
//    myfile() - pass argument import.meta.url and it will return
//               the name of your file
export var myfile = function(url) {
  var filename, path;
  debug(`url = ${url}`);
  path = urllib.fileURLToPath(url);
  debug(`path = ${path}`);
  filename = pathlib.parse(path).base;
  debug(`filename = ${filename}`);
  return filename;
};

// ---------------------------------------------------------------------------
//    myfullpath() - pass argument import.meta.url and it will return
//                   the full path to your file
export var myfullpath = function(url) {
  var path;
  debug(`url = ${url}`);
  path = urllib.fileURLToPath(url);
  debug(`path = ${path}`);
  return mkpath(path);
};

// ---------------------------------------------------------------------------
export var isFile = function(fullpath) {
  return fs.lstatSync(fullpath).isFile();
};

// ---------------------------------------------------------------------------
export var isDir = function(fullpath) {
  var obj;
  try {
    obj = fs.lstatSync(fullpath);
    if (obj == null) {
      return false;
    }
    return obj.isDirectory();
  } catch (error1) {
    return false;
  }
};

// ---------------------------------------------------------------------------
export var isSimpleFileName = function(path) {
  var h;
  h = pathlib.parse(path);
  return !h.root && !h.dir && h.base;
};

// ---------------------------------------------------------------------------
export var fileStub = function(path) {
  var lMatches;
  assert(isString(path), "fileExt(): path not a string");
  if (lMatches = path.match(/^(.*)\.[A-Za-z0-9_]+$/)) {
    return lMatches[1];
  } else {
    return '';
  }
};

// ---------------------------------------------------------------------------
export var fileExt = function(path) {
  var lMatches;
  assert(isString(path), "fileExt(): path not a string");
  if (lMatches = path.match(/\.[A-Za-z0-9_]+$/)) {
    return lMatches[0];
  } else {
    return '';
  }
};

// ---------------------------------------------------------------------------
export var mkpath = function(...lParts) {
  var _, drive, i, lMatches, lNewParts, len, newPath, part, rest;
  // --- Ignore empty parts
  lNewParts = [];
  for (i = 0, len = lParts.length; i < len; i++) {
    part = lParts[i];
    if (nonEmpty(part)) {
      lNewParts.push(part);
    }
  }
  newPath = lNewParts.join('/').replace(/\\/g, '/');
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
export var forEachLineInFile = function(filepath, func) {
  var buffer, line, nLines, reader;
  reader = new NReadLines(filepath);
  nLines = 0;
  while ((buffer = reader.next())) {
    nLines += 1;
    // --- text is split on \n chars, we also need to remove \r chars
    line = buffer.toString().replace(/\r/g, '');
    if (func(line, nLines) === 'EOF') {
      reader.close(); // allow premature termination
    }
  }
};

// ---------------------------------------------------------------------------
//   slurp - read an entire file into a string
export var slurp = function(filepath, maxLines = undef) {
  var contents, lLines;
  debug(`enter slurp('${filepath}')`);
  if (maxLines != null) {
    lLines = [];
    forEachLineInFile(filepath, function(line, nLines) {
      lLines.push(line);
      if (nLines >= maxLines) {
        return 'EOF';
      } else {
        return undef;
      }
    });
    contents = lLines.join("\n");
  } else {
    filepath = filepath.replace(/\//g, "\\");
    contents = fs.readFileSync(filepath, 'utf8').toString();
  }
  debug("return from slurp()", contents);
  return contents;
};

// ---------------------------------------------------------------------------
//   barf - write a string to a file
export var barf = function(filepath, contents) {
  debug(`enter barf('${filepath}')`, contents);
  if (isEmpty(contents)) {
    debug("return from barf(): empty contents");
    return;
  }
  if (isArray(contents)) {
    contents = arrayToBlock(contents);
  } else if (!isString(contents)) {
    croak("barf(): Invalid contents");
  }
  contents = rtrim(contents) + "\n";
  fs.writeFileSync(filepath, contents, {
    encoding: 'utf8'
  });
  debug("return from barf()");
};

// ---------------------------------------------------------------------------
//   withExt - change file extention in a file name
export var withExt = function(path, newExt, hOptions = {}) {
  var dir, ext, name;
  // --- Valid options:
  //        removeLeadingUnderScore - boolean
  assert(newExt, "withExt(): No newExt provided");
  if (newExt.indexOf('.') !== 0) {
    newExt = '.' + newExt;
  }
  ({dir, name, ext} = pathlib.parse(path));
  if (hOptions.removeLeadingUnderScore && (name.indexOf('_') === 0)) {
    name = name.substr(1);
  }
  return mkpath(dir, `${name}${newExt}`);
};

// ---------------------------------------------------------------------------
//   removeFileWithExt - remove file with different ext
export var removeFileWithExt = function(path, newExt, hOptions = {}) {
  var err, fullpath, success;
  // --- Valid options:
  //        doLog
  //        removeLeadingUnderScore
  fullpath = withExt(path, newExt, hOptions);
  try {
    fs.unlinkSync(fullpath);
    if (hOptions.doLog) {
      log(`   unlink ${filename}`);
    }
    success = true;
  } catch (error1) {
    err = error1;
    log(`   UNLINK FAILED: ${err.message}`);
    success = false;
  }
  return success;
};

// ---------------------------------------------------------------------------
//   withUnderScore - add '_' to file name
export var withUnderScore = function(path) {
  var base, dir;
  ({dir, base} = pathlib.parse(path));
  return mkpath(dir, `_${base}`);
};

// ---------------------------------------------------------------------------
isSystemDir = function(dir) {
  return dir === '$Recycle.Bin' || dir === '$WinREAgent';
};

// ---------------------------------------------------------------------------
//    Get all subdirectories of a directory
export var getSubDirs = function(dir) {
  return fs.readdirSync(dir, {
    withFileTypes: true
  }).filter(function(d) {
    return d.isDirectory() && !isSystemDir(d.name);
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
export var pathTo = function(fname, searchDir, direction = "down") {
  var dirpath, filepath, fpath, i, len, ref, subdir;
  debug(`enter pathTo('${fname}','${searchDir}','${direction}')`);
  if (!searchDir) {
    searchDir = process.cwd();
  }
  assert(fs.existsSync(searchDir), `Directory ${searchDir} does not exist`);
  filepath = mkpath(searchDir, fname);
  if (fs.existsSync(filepath)) {
    debug(`return from pathTo: ${filepath} - file exists`);
    return filepath;
  } else if (direction === 'down') {
    ref = getSubDirs(searchDir);
    // --- Search all directories in this directory
    //     getSubDirs() returns dirs sorted alphabetically
    for (i = 0, len = ref.length; i < len; i++) {
      subdir = ref[i];
      dirpath = mkpath(searchDir, subdir);
      debug(`check ${dirpath}`);
      if (fpath = pathTo(fname, dirpath)) {
        debug(`return from pathTo: ${fpath}`);
        return fpath;
      }
    }
  } else if (direction === 'up') {
    while (dirpath = getParentDir(searchDir)) {
      debug(`check ${dirpath}`);
      filepath = mkpath(dirpath, fname);
      if (fs.existsSync(filepath)) {
        debug(`return from pathTo(): ${filepath}`);
        return filepath;
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
  if (!searchDir) {
    searchDir = process.cwd();
  }
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

// ---------------------------------------------------------------------------
export var parseSource = function(source) {
  var dir, hInfo, hSourceInfo;
  // --- returns {
  //        dir
  //        filename
  //        fullpath
  //        stub
  //        ext
  //        }
  // --- NOTE: source may be a file URL, e.g. import.meta.url
  debug("enter parseSource()");
  assert(isString(source), `parseSource(): source not a string: ${OL(source)}`);
  if (source === 'unit test') {
    croak("A source of 'unit test' is deprecated");
  }
  if (source.match(/^file\:\/\//)) {
    source = urllib.fileURLToPath(source);
  }
  if (isDir(source)) {
    hSourceInfo = {
      dir: source,
      fullpath: source
    };
  } else {
    hInfo = pathlib.parse(source);
    if (hInfo.dir) {
      dir = mkpath(hInfo.dir); // change \ to /
      hSourceInfo = {
        dir,
        fullpath: mkpath(dir, hInfo.base),
        filename: hInfo.base,
        stub: hInfo.name,
        ext: hInfo.ext
      };
    } else {
      hSourceInfo = {
        filename: hInfo.base,
        stub: hInfo.name,
        ext: hInfo.ext
      };
    }
  }
  debug("return from parseSource()", hSourceInfo);
  return hSourceInfo;
};

// ---------------------------------------------------------------------------
//   backup - back up a file

// --- If report is true, missing source files are not an error
//     but both missing source files and successful copies
//     are reported via LOG
export var backup = function(file, from, to, report = false) {
  var dest, src;
  src = mkpath(from, file);
  dest = mkpath(to, file);
  if (report) {
    if (fs.existsSync(src)) {
      LOG(`OK ${file}`);
      return fs.copyFileSync(src, dest);
    } else {
      return LOG(`MISSING ${src}`);
    }
  } else {
    return fs.copyFileSync(src, dest);
  }
};
