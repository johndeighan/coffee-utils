# fs.coffee

import os from 'os'
import pathlib from 'path'
import urllib from 'url'
import fs from 'fs'
import {
	readFile, writeFile, rm, rmdir,   #  rmSync, rmdirSync,
	} from 'node:fs/promises'
import {execSync} from 'node:child_process'

import {
	undef, pass, defined, notdefined, rtrim, isEmpty, nonEmpty,
	isString, isArray, isHash, isRegExp, isFunction, isBoolean,
	OL, toBlock, getOptions, isArrayOfStrings, deepCopy,
	} from '@jdeighan/base-utils'
import {
	mydir, mkpath, isFile, isDir, rmFileSync, mkdirSync,
	forEachLineInFile,
	rmFile, rmDir, rmDirSync,
	} from '@jdeighan/base-utils/fs'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {dbg, dbgEnter, dbgReturn} from '@jdeighan/base-utils/debug'
import {fromTAML} from '@jdeighan/base-utils/ll-taml'

export {
	mydir, mkpath, isFile, isDir, rmFileSync, mkdirSync,
	forEachLineInFile, rmDir, rmDirSync, rmFile,
	}

fix = true

# ---------------------------------------------------------------------------

export doFixOutput = (flag=true) =>

	fix = flag
	return

# --------------------------------------------------------------------------

export fixOutput = (contents) =>

	if fix && isString(contents)
		return rtrim(contents) + "\n"
	else
		return contents

# --------------------------------------------------------------------------

export fixFile = (filepath, func) =>

	contents = await readFile(filepath, {encoding: 'utf8'})
	output = func(contents) # returns modified contents
	output = fixOutput(output)
	await writeFile(filepath, output, {encoding: 'utf8'})
	return

# --------------------------------------------------------------------------

export fixJson = (filepath, func) =>

	contents = await readFile(filepath, {encoding: 'utf8'})
	hJson = JSON.parse(contents)
	func(hJson)   # modify in place
	output = JSON.stringify(hJson, null, 3)
	output = fixOutput(output)
	await writeFile(filepath, output, {encoding: 'utf8'})
	return

# --------------------------------------------------------------------------

export fixFileSync = (filepath, func) =>

	contents = fs.readFileSync(filepath, {encoding: 'utf8'})
	output = func(contents) # returns modified contents
	output = fixOutput(output)
	fs.writeFileSync(filepath, output, {encoding: 'utf8'})
	return

# --------------------------------------------------------------------------

export fixJsonSync = (filepath, func) =>

	contents = fs.readFileSync(filepath, {encoding: 'utf8'})
	hJson = JSON.parse(contents)
	func(hJson)   # modify in place
	output = JSON.stringify(hJson, null, 3)
	output = fixOutput(output)
	fs.writeFileSync(filepath, output, {encoding: 'utf8'})
	return

# --------------------------------------------------------------------------

export execCmdSync = (cmdLine) =>

	execSync cmdLine, {}, (error, stdout, stderr) =>
		if (error)
			LOG "ERROR in #{cmdLine}: #{error.code}"
			process.exit 1
	return stdout

# ---------------------------------------------------------------------------

export cloneRepo = (user, repo, dir) =>

	git_repo = "https://github.com/#{user}/#{repo}.git"
	return execCmd "git clone #{git_repo} #{dir}"

# ---------------------------------------------------------------------------

export homeDir = () =>

	return mkpath(os.homedir())

# ---------------------------------------------------------------------------

export projRoot = (url) =>

	dir = mydir(url)
	rootDir = pathTo('package.json', dir, 'direction=up directory')
	assert defined(rootDir), "No project root directory found"
	return rootDir

# ---------------------------------------------------------------------------
#    myfile() - pass argument import.meta.url and it will return
#               the name of your file

export myfile = (url) =>

	path = urllib.fileURLToPath(url)
	filename = pathlib.parse(path).base
	return filename

# ---------------------------------------------------------------------------
#    myfullpath() - pass argument import.meta.url and it will return
#                   the full path to your file

export myfullpath = (url) =>

	path = urllib.fileURLToPath(url)
	return mkpath(path)

# ---------------------------------------------------------------------------

export getStats = (fullpath) =>

	return fs.lstatSync(fullpath)

# ---------------------------------------------------------------------------

export isSimpleFileName = (path) =>

	h = pathlib.parse(path)
	return ! h.root && ! h.dir && h.base

# ---------------------------------------------------------------------------

export fileStub = (path) =>

	assert isString(path), "fileStub(): path not a string"
	if lMatches = path.match(/^(.*)\.[A-Za-z0-9_]+$/)
		return lMatches[1]
	else
		return ''

# ---------------------------------------------------------------------------

export fileExt = (path) =>

	assert isString(path), "fileExt(): path not a string"
	if lMatches = path.match(/\.[A-Za-z0-9_]+$/)
		return lMatches[0]
	else
		return ''

# ---------------------------------------------------------------------------

export getFullPath = (filepath) =>

	return mkpath(pathlib.resolve(filepath))

# ---------------------------------------------------------------------------

export forEachBlock = (filepath, func, regexp = /^-{16,}$/) =>

	lLines = []
	firstLineNum = 1
	earlyExit = false

	callback = (line, lineNum) ->
		if (line.match(regexp))
			if result = func(lLines.join('\n'), firstLineNum, line)
				if (result == true)
					earlyExit = true
					return true
				else if defined(result)
					croak "forEachBlock() - callback returned '#{result}'"
			lLines = []
			firstLineNum = lineNum+1
		else
			lLines.push line
		return false

	forEachLineInFile filepath, callback
	if ! earlyExit
		func(lLines.join('\n'), firstLineNum)
	return

# ---------------------------------------------------------------------------

export forEachSetOfBlocks = (filepath, func, \
		block_regexp = /^-{16,}$/, \
		set_regexp   = /^={16,}$/) \
		=>

	dbgEnter 'forEachSetOfBlocks', filepath
	lBlocks = []
	lLines = []
	firstLineNum = 1
	earlyExit = false

	callback = (line, hContext) ->
		dbgEnter 'callback', line, hContext.lineNum
		lineNum = hContext.lineNum
		if (line.match(set_regexp))
			lBlocks.push(lLines.join('\n'))
			lLines = []
			result = func(deepCopy(lBlocks), firstLineNum, line)
			if (result == true)
				earlyExit = true
				dbgReturn 'callback', true
				return true
			lBlocks = []
			firstLineNum = lineNum+1
		else if (line.match(block_regexp))
			lBlocks.push(lLines.join('\n'))
			lLines = []
		else
			lLines.push line
		dbgReturn 'callback', false
		return false

	forEachLineInFile filepath, callback
	if ! earlyExit
		lBlocks.push(lLines.join('\n'))
		func(lBlocks, firstLineNum)
	dbgReturn 'forEachSetOfBlocks'
	return

# ---------------------------------------------------------------------------
#   withExt - change file extention in a file name

export withExt = (path, newExt) =>

	assert newExt, "withExt(): No newExt provided"
	if newExt.indexOf('.') != 0
		newExt = '.' + newExt

	{dir, name, ext} = pathlib.parse(path)
	return mkpath(dir, "#{name}#{newExt}")

# ---------------------------------------------------------------------------
#   removeFileWithExt - remove file with different ext

export removeFileWithExt = (path, newExt, hOptions={}) =>
	# --- Valid options:
	#        doLog

	{doLog} = getOptions(hOptions)
	fullpath = withExt(path, newExt)
	try
		fs.unlinkSync fullpath
		if doLog
			LOG "   unlink #{filename}"
		success = true
	catch err
		LOG "   UNLINK FAILED: #{err.message}"
		success = false
	return success

# ---------------------------------------------------------------------------

isSystemDir = (dir) ->

	return dir in ['$Recycle.Bin', '$WinREAgent']

# ---------------------------------------------------------------------------
#    Get all subdirectories of a directory

export getSubDirs = (dir) =>

	return fs.readdirSync(dir, {withFileTypes: true}) \
		.filter((d) -> d.isDirectory() && !isSystemDir(d.name)) \
		.map((d) -> mkpath(d.name)) \
		.sort()

# ---------------------------------------------------------------------------
#    Get path to parent directory of a directory

export getParentDir = (dir) =>

	hParts = pathlib.parse(dir)
	if (hParts.dir == hParts.root)
		return undef
	return mkpath(pathlib.resolve(dir, '..'))

# ---------------------------------------------------------------------------

export forEachFile = (dir, cb, filt=undef, level=0) =>
	# --- filt can be a regular expression or a function that gets:
	#        (filename, dir, level)
	#     callback will get parms (filename, dir, level)

	lSubDirectories = []
	for ent in fs.readdirSync(dir, {withFileTypes: true})
		if ent.isDirectory()
			lSubDirectories.push ent
		else if ent.isFile()
			if notdefined(filt)
				cb(ent.name, dir, level)
			else if isRegExp(filt)
				if ent.name.match(filt)
					cb(ent.name, dir, level)
			else if isFunction(filt)
				if filt(ent.name, dir, level)
					cb(ent.name, dir, level)
			else
				croak "forEachFile(): bad filter", 'filter', filt
	if nonEmpty(lSubDirectories)
		for subdir in lSubDirectories.sort()
			forEachFile(mkpath(dir, subdir.name), cb, filt, level+1)
	return

# ---------------------------------------------------------------------------

export pathTo = (fname, searchDir, options=undef) =>

	{direction, relative, directory} = getOptions(options, {
		direction: 'down'
		relative: false
		directory: false    # return only the directory the file is in
		})

	assert !(relative && directory), "relative & directory are incompatible"
	if ! searchDir
		searchDir = process.cwd()
	assert isDir(searchDir), "Not a directory: #{OL(searchDir)}"
	filepath = mkpath(searchDir, fname)
	if isFile(filepath)
		if relative
			return "./#{fname}"
		else if directory
			return searchDir
		else
			return filepath

	if (direction == 'down')
		# --- Search all directories in this directory
		#     getSubDirs() returns dirs sorted alphabetically
		for subdir in getSubDirs(searchDir)
			dirPath = mkpath(searchDir, subdir)
			if defined(fpath = pathTo(fname, dirPath, options))
				if relative
					return fpath.replace('./', "./#{subdir}/")
				else if directory
					return dirPath
				else
					return fpath
	else if (direction == 'up')
		nLevels = 0
		while defined(dirPath = getParentDir(searchDir))
			nLevels += 1
			fpath = mkpath(dirPath, fname)
			if isFile(fpath)
				if relative
					return "../".repeat(nLevels) + fname
				else if directory
					return dirPath
				else
					return fpath
			searchDir = dirPath
	else
		croak "pathTo(): Invalid direction '#{direction}'"
	return undef

# ---------------------------------------------------------------------------

export allPathsTo = (fname, searchDir) =>
	# --- Only searches upward

	if ! searchDir
		searchDir = process.cwd()
	path = pathTo(fname, searchDir, {direction: "up"})
	if defined(path)
		lPaths = [path]    # --- build an array of paths
		# --- search upward for files, but return ordered top down
		while (h = pathlib.parse(path)) \
				&& (path = pathTo(fname, pathlib.resolve(h.dir, '..'), {direction: "up"}))
			lPaths.unshift path
		return lPaths
	else
		return []

# ---------------------------------------------------------------------------

export newerDestFileExists = (srcPath, destPath) =>

	if ! fs.existsSync(destPath)
		return false
	srcModTime = fs.statSync(srcPath).mtimeMs
	destModTime = fs.statSync(destPath).mtimeMs
	if destModTime >= srcModTime
		return true
	else
		return false

# ---------------------------------------------------------------------------

export shortenPath = (path) =>
	# --- Replace user's home dir with '~'

	str = mkpath(path)
	if lMatches = str.match(///^
			[A-Za-z]:/Users/[a-z_][a-z0-9_]*/(.*)
			$///i)
		[_, tail] = lMatches
		return "~/#{tail}"
	else
		return str

# ---------------------------------------------------------------------------

export parseSource = (source) =>
	# --- returns {
	#        dir
	#        filename
	#        fullpath
	#        stub
	#        ext
	#        purpose
	#        }
	# --- NOTE: source may be a file URL, e.g. import.meta.url

	dbgEnter "parseSource", source
	assert isString(source),\
			"parseSource(): source not a string: #{OL(source)}"
	if source == 'unit test'
		croak "A source of 'unit test' is deprecated"
	if source.match(/^file\:\/\//)
		source = urllib.fileURLToPath(source)

	if isDir(source)
		hSourceInfo = {
			dir: source
			fullpath: source
			}
	else
		hInfo = pathlib.parse(source)
		if hInfo.dir
			dir = mkpath(hInfo.dir)   # change \ to /
			hSourceInfo = {
				dir
				fullpath: mkpath(dir, hInfo.base)
				filename: hInfo.base
				stub: hInfo.name
				ext: hInfo.ext
				}
		else
			hSourceInfo = {
				filename: hInfo.base
				stub: hInfo.name
				ext: hInfo.ext
				}

		# --- check for a 'purpose'
		if lMatches = hSourceInfo.stub.match(///
				\.
				([A-Za-z_]+)
				$///)
			hSourceInfo.purpose = lMatches[1]
	dbgReturn "parseSource", hSourceInfo
	return hSourceInfo

# ---------------------------------------------------------------------------
