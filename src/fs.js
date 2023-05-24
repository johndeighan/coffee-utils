// Generated by CoffeeScript 2.7.0
// fs.coffee
var fix, isSystemDir;

import os from 'os';

import pathlib from 'path';

import urllib from 'url';

import fs from 'fs';

import {
  readFile,
  writeFile,
  rm,
  rmdir //  rmSync, rmdirSync,
} from 'node:fs/promises';

import {
  execSync
} from 'node:child_process';

import readline from 'readline';

import NReadLines from 'n-readlines';

import {
  undef,
  pass,
  defined,
  notdefined,
  rtrim,
  isEmpty,
  nonEmpty,
  isString,
  isArray,
  isHash,
  isRegExp,
  isFunction,
  isBoolean,
  OL,
  toBlock,
  getOptions,
  isArrayOfStrings
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

import {
  dbg,
  dbgEnter,
  dbgReturn
} from '@jdeighan/base-utils/debug';

import {
  fromTAML
} from '@jdeighan/base-utils/taml';

fix = true;

// ---------------------------------------------------------------------------
export var doFixOutput = (flag = true) => {
  fix = flag;
};

// ---------------------------------------------------------------------------
export var mkpath = (...lParts) => {
  var _, drive, i, lMatches, lNewParts, len, newPath, part, rest;
  // --- Ignore empty parts
  lNewParts = [];
  for (i = 0, len = lParts.length; i < len; i++) {
    part = lParts[i];
    if (nonEmpty(part)) {
      lNewParts.push(part);
    }
  }
  newPath = lNewParts.join('/').replaceAll('\\', '/');
  if (lMatches = newPath.match(/^([A-Z])\:(.*)$/)) {
    [_, drive, rest] = lMatches;
    return `${drive.toLowerCase()}:${rest}`;
  } else {
    return newPath;
  }
};

// ---------------------------------------------------------------------------
export var mkdirSync = (dirpath) => {
  var err;
  try {
    fs.mkdirSync(dirpath);
  } catch (error1) {
    err = error1;
    if (err.code === 'EEXIST') {
      console.log('Directory exists. Please choose another name');
    } else {
      console.log(err);
    }
    process.exit(1);
  }
};

// ---------------------------------------------------------------------------
export var rmDir = async(dirpath) => {
  await rmdir(dirpath, {
    recursive: true
  });
};

// ---------------------------------------------------------------------------
export var rmDirSync = (dirpath) => {
  fs.rmdirSync(dirpath, {
    recursive: true
  });
};

// ---------------------------------------------------------------------------
export var rmFile = async(filepath) => {
  await rm(filepath);
};

// ---------------------------------------------------------------------------
export var rmFileSync = (filepath) => {
  fs.rmSync(filepath);
};

// --------------------------------------------------------------------------
export var fixOutput = (contents) => {
  if (fix && isString(contents)) {
    return rtrim(contents) + "\n";
  } else {
    return contents;
  }
};

// --------------------------------------------------------------------------
export var fixFile = async(filepath, func) => {
  var contents, output;
  contents = (await readFile(filepath, {
    encoding: 'utf8'
  }));
  output = func(contents); // returns modified contents
  output = fixOutput(output);
  await writeFile(filepath, output, {
    encoding: 'utf8'
  });
};

// --------------------------------------------------------------------------
export var fixJson = async(filepath, func) => {
  var contents, hJson, output;
  contents = (await readFile(filepath, {
    encoding: 'utf8'
  }));
  hJson = JSON.parse(contents);
  func(hJson); // modify in place
  output = JSON.stringify(hJson, null, 3);
  output = fixOutput(output);
  await writeFile(filepath, output, {
    encoding: 'utf8'
  });
};

// --------------------------------------------------------------------------
export var fixFileSync = (filepath, func) => {
  var contents, output;
  contents = fs.readFileSync(filepath, {
    encoding: 'utf8'
  });
  output = func(contents); // returns modified contents
  output = fixOutput(output);
  fs.writeFileSync(filepath, output, {
    encoding: 'utf8'
  });
};

// --------------------------------------------------------------------------
export var fixJsonSync = (filepath, func) => {
  var contents, hJson, output;
  contents = fs.readFileSync(filepath, {
    encoding: 'utf8'
  });
  hJson = JSON.parse(contents);
  func(hJson); // modify in place
  output = JSON.stringify(hJson, null, 3);
  output = fixOutput(output);
  fs.writeFileSync(filepath, output, {
    encoding: 'utf8'
  });
};

// --------------------------------------------------------------------------
export var execCmdSync = (cmdLine) => {
  execSync(cmdLine, {}, (error, stdout, stderr) => {
    if (error) {
      LOG(`ERROR in ${cmdLine}: ${error.code}`);
      return process.exit(1);
    }
  });
  return stdout;
};

// ---------------------------------------------------------------------------
export var cloneRepo = (user, repo, dir) => {
  var git_repo;
  git_repo = `https://github.com/${user}/${repo}.git`;
  return execCmd(`git clone ${git_repo} ${dir}`);
};

// ---------------------------------------------------------------------------
//    mydir() - pass argument import.meta.url and it will return
//              the directory your file is in
export var mydir = (url) => {
  var dir, final, path;
  path = urllib.fileURLToPath(url);
  dir = pathlib.dirname(path);
  final = mkpath(dir);
  return final;
};

// ---------------------------------------------------------------------------
export var homeDir = () => {
  return mkpath(os.homedir());
};

// ---------------------------------------------------------------------------
export var projRoot = (url) => {
  var dir, rootDir;
  dir = mydir(url);
  rootDir = pathTo('package.json', dir, 'direction=up directory');
  assert(defined(rootDir), "No project root directory found");
  return rootDir;
};

// ---------------------------------------------------------------------------
//    myfile() - pass argument import.meta.url and it will return
//               the name of your file
export var myfile = (url) => {
  var filename, path;
  path = urllib.fileURLToPath(url);
  filename = pathlib.parse(path).base;
  return filename;
};

// ---------------------------------------------------------------------------
//    myfullpath() - pass argument import.meta.url and it will return
//                   the full path to your file
export var myfullpath = (url) => {
  var path;
  path = urllib.fileURLToPath(url);
  return mkpath(path);
};

// ---------------------------------------------------------------------------
export var getStats = (fullpath) => {
  return fs.lstatSync(fullpath);
};

// ---------------------------------------------------------------------------
export var isFile = (fullpath) => {
  try {
    return getStats(fullpath).isFile();
  } catch (error1) {
    return false;
  }
};

// ---------------------------------------------------------------------------
export var isDir = (fullpath) => {
  try {
    return getStats(fullpath).isDirectory();
  } catch (error1) {
    return false;
  }
};

// ---------------------------------------------------------------------------
export var isSimpleFileName = (path) => {
  var h;
  h = pathlib.parse(path);
  return !h.root && !h.dir && h.base;
};

// ---------------------------------------------------------------------------
export var fileStub = (path) => {
  var lMatches;
  assert(isString(path), "fileExt(): path not a string");
  if (lMatches = path.match(/^(.*)\.[A-Za-z0-9_]+$/)) {
    return lMatches[1];
  } else {
    return '';
  }
};

// ---------------------------------------------------------------------------
export var fileExt = (path) => {
  var lMatches;
  assert(isString(path), "fileExt(): path not a string");
  if (lMatches = path.match(/\.[A-Za-z0-9_]+$/)) {
    return lMatches[0];
  } else {
    return '';
  }
};

// ---------------------------------------------------------------------------
export var getFullPath = (filepath) => {
  return mkpath(pathlib.resolve(filepath));
};

// ---------------------------------------------------------------------------
export var forEachLineInFile = (filepath, func) => {
  var buffer, line, nLines, reader, result;
  reader = new NReadLines(filepath);
  nLines = 0;
  while ((buffer = reader.next())) {
    nLines += 1;
    // --- text is split on \n chars,
    //     we also need to remove \r chars
    line = buffer.toString().replace(/\r/g, '');
    result = func(line, nLines);
    assert(isBoolean(result));
    if (result) {
      reader.close(); // allow premature termination
      return;
    }
  }
};

// ---------------------------------------------------------------------------
export var mapEachLineInFile = (filepath, func) => {
  var buffer, lLines, line, nLines, reader, result;
  reader = new NReadLines(filepath);
  nLines = 0;
  lLines = [];
  while ((buffer = reader.next())) {
    nLines += 1;
    // --- text is split on \n chars,
    //     we also need to remove \r chars
    line = buffer.toString().replace(/\r/g, '');
    result = func(line, nLines);
    if (defined(result)) {
      lLines.push(result);
    }
  }
  return lLines;
};

// ---------------------------------------------------------------------------
export var forEachBlock = (filepath, func, regexp = /^-{16,}$/) => {
  var callback, earlyExit, firstLineNum, lLines;
  lLines = [];
  firstLineNum = 1;
  earlyExit = false;
  callback = function(line, lineNum) {
    var result;
    if (line.match(regexp)) {
      if (result = func(lLines.join('\n'), firstLineNum, line)) {
        if (result === true) {
          earlyExit = true;
          return true;
        } else if (defined(result)) {
          croak(`forEachBlock() - callback returned '${result}'`);
        }
      }
      lLines = [];
      firstLineNum = lineNum + 1;
    } else {
      lLines.push(line);
    }
    return false;
  };
  forEachLineInFile(filepath, callback);
  if (!earlyExit) {
    func(lLines.join('\n'), firstLineNum);
  }
};

// ---------------------------------------------------------------------------
export var forEachSetOfBlocks = (filepath, func, block_regexp = /^-{16,}$/, set_regexp = /^={16,}$/) => {
  var callback, earlyExit, firstLineNum, lBlocks, lLines;
  lBlocks = [];
  lLines = [];
  firstLineNum = 1;
  earlyExit = false;
  callback = function(line, lineNum) {
    var result;
    if (line.match(set_regexp)) {
      lBlocks.push(lLines.join('\n'));
      lLines = [];
      if (result = func(lBlocks, firstLineNum, line)) {
        if (result === true) {
          earlyExit = true;
          return true;
        } else if (defined(result)) {
          croak(`forEachSetOfBlocks() - callback returned '${result}'`);
        }
      }
      lBlocks = [];
      firstLineNum = lineNum + 1;
    } else if (line.match(block_regexp)) {
      lBlocks.push(lLines.join('\n'));
      lLines = [];
    } else {
      lLines.push(line);
    }
    return false;
  };
  forEachLineInFile(filepath, callback);
  if (!earlyExit) {
    lBlocks.push(lLines.join('\n'));
    func(lBlocks, firstLineNum);
  }
};

// ---------------------------------------------------------------------------
//   slurp - read a file into a string
export var slurp = (filepath, hOptions = {}) => {
  var contents, format, lLines, maxLines;
  ({maxLines, format} = getOptions(hOptions));
  if (defined(maxLines)) {
    lLines = [];
    forEachLineInFile(filepath, function(line, nLines) {
      lLines.push(line);
      return nLines >= maxLines;
    });
    contents = toBlock(lLines);
  } else {
    filepath = filepath.replace(/\//g, "\\");
    contents = fs.readFileSync(filepath, 'utf8').toString();
  }
  switch (format) {
    case 'TAML':
      return fromTAML(contents);
    case 'JSON':
      return JSON.parse(contents);
    default:
      assert(notdefined(format), `Unknown format: ${format}`);
      return contents;
  }
};

// ---------------------------------------------------------------------------
//   barf - write a string to a file
export var barf = (filepath, contents = '', hOptions = {}) => {
  var format;
  ({format} = getOptions(hOptions));
  switch (format) {
    case 'TAML':
      contents = toTAML(contents);
      break;
    case 'JSON':
      contents = JSON.stringify(contents, null, 3);
      break;
    default:
      assert(notdefined(format), `Unknown format: ${format}`);
      if (isArrayOfStrings(contents)) {
        contents = fixOutput(toBlock(contents));
      } else if (isString(contents)) {
        contents = fixOutput(contents);
      }
  }
  fs.writeFileSync(filepath, contents);
};

// ---------------------------------------------------------------------------
//   withExt - change file extention in a file name
export var withExt = (path, newExt) => {
  var dir, ext, name;
  assert(newExt, "withExt(): No newExt provided");
  if (newExt.indexOf('.') !== 0) {
    newExt = '.' + newExt;
  }
  ({dir, name, ext} = pathlib.parse(path));
  return mkpath(dir, `${name}${newExt}`);
};

// ---------------------------------------------------------------------------
//   removeFileWithExt - remove file with different ext
export var removeFileWithExt = (path, newExt, hOptions = {}) => {
  var doLog, err, fullpath, success;
  // --- Valid options:
  //        doLog
  ({doLog} = getOptions(hOptions));
  fullpath = withExt(path, newExt);
  try {
    fs.unlinkSync(fullpath);
    if (doLog) {
      LOG(`   unlink ${filename}`);
    }
    success = true;
  } catch (error1) {
    err = error1;
    LOG(`   UNLINK FAILED: ${err.message}`);
    success = false;
  }
  return success;
};

// ---------------------------------------------------------------------------
isSystemDir = function(dir) {
  return dir === '$Recycle.Bin' || dir === '$WinREAgent';
};

// ---------------------------------------------------------------------------
//    Get all subdirectories of a directory
export var getSubDirs = (dir) => {
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
export var getParentDir = (dir) => {
  var hParts;
  hParts = pathlib.parse(dir);
  if (hParts.dir === hParts.root) {
    return undef;
  }
  return mkpath(pathlib.resolve(dir, '..'));
};

// ---------------------------------------------------------------------------
export var forEachFile = (dir, cb, filt = undef, level = 0) => {
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
      if (notdefined(filt)) {
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
export var pathTo = (fname, searchDir, options = undef) => {
  var dirPath, direction, directory, filepath, fpath, i, len, nLevels, ref, relative, subdir;
  ({direction, relative, directory} = getOptions(options, {
    direction: 'down',
    relative: false,
    directory: false // return only the directory the file is in
  }));
  assert(!(relative && directory), "relative & directory are incompatible");
  if (!searchDir) {
    searchDir = process.cwd();
  }
  assert(isDir(searchDir), `Not a directory: ${OL(searchDir)}`);
  filepath = mkpath(searchDir, fname);
  if (isFile(filepath)) {
    if (relative) {
      return `./${fname}`;
    } else if (directory) {
      return searchDir;
    } else {
      return filepath;
    }
  }
  if (direction === 'down') {
    ref = getSubDirs(searchDir);
    // --- Search all directories in this directory
    //     getSubDirs() returns dirs sorted alphabetically
    for (i = 0, len = ref.length; i < len; i++) {
      subdir = ref[i];
      dirPath = mkpath(searchDir, subdir);
      if (defined(fpath = pathTo(fname, dirPath, options))) {
        if (relative) {
          return fpath.replace('./', `./${subdir}/`);
        } else if (directory) {
          return dirPath;
        } else {
          return fpath;
        }
      }
    }
  } else if (direction === 'up') {
    nLevels = 0;
    while (defined(dirPath = getParentDir(searchDir))) {
      nLevels += 1;
      fpath = mkpath(dirPath, fname);
      if (isFile(fpath)) {
        if (relative) {
          return "../".repeat(nLevels) + fname;
        } else if (directory) {
          return dirPath;
        } else {
          return fpath;
        }
      }
      searchDir = dirPath;
    }
  } else {
    croak(`pathTo(): Invalid direction '${direction}'`);
  }
  return undef;
};

// ---------------------------------------------------------------------------
export var allPathsTo = (fname, searchDir) => {
  var h, lPaths, path;
  if (!searchDir) {
    searchDir = process.cwd();
  }
  path = pathTo(fname, searchDir, {
    direction: "up"
  });
  if (defined(path)) {
    lPaths = [path]; // --- build an array of paths
    // --- search upward for files, but return ordered top down
    while ((h = pathlib.parse(path)) && (path = pathTo(fname, pathlib.resolve(h.dir, '..'), {
        direction: "up"
      }))) {
      lPaths.unshift(path);
    }
    return lPaths;
  } else {
    return [];
  }
};

// ---------------------------------------------------------------------------
export var newerDestFileExists = (srcPath, destPath) => {
  var destModTime, srcModTime;
  if (!fs.existsSync(destPath)) {
    return false;
  }
  srcModTime = fs.statSync(srcPath).mtimeMs;
  destModTime = fs.statSync(destPath).mtimeMs;
  if (destModTime >= srcModTime) {
    return true;
  } else {
    return false;
  }
};

// ---------------------------------------------------------------------------
export var shortenPath = (path) => {
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
export var parseSource = (source) => {
  var dir, hInfo, hSourceInfo, lMatches;
  // --- returns {
  //        dir
  //        filename
  //        fullpath
  //        stub
  //        ext
  //        purpose
  //        }
  // --- NOTE: source may be a file URL, e.g. import.meta.url
  dbgEnter("parseSource", source);
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
    // --- check for a 'purpose'
    if (lMatches = hSourceInfo.stub.match(/\.([A-Za-z_]+)$/)) {
      hSourceInfo.purpose = lMatches[1];
    }
  }
  dbgReturn("parseSource", hSourceInfo);
  return hSourceInfo;
};

// ---------------------------------------------------------------------------
//   slurpTAML - read TAML from a file
export var slurpTAML = (filepath) => {
  return slurp(filepath, {
    format: 'TAML'
  });
};
