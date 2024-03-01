# fs.coffee

import os from 'os'
import pathlib from 'path'
import urllib from 'url'
import fs from 'fs'
import {
	readFile, writeFile, rm, rmdir,
	} from 'node:fs/promises'
import {execSync} from 'node:child_process'

import {
	undef, pass, defined, notdefined, rtrim, isEmpty, nonEmpty,
	isString, isArray, isHash, isRegExp, isFunction, isBoolean,
	OL, toBlock, getOptions, isArrayOfStrings, deepCopy,
	runCmd,
	} from '@jdeighan/base-utils'
import {
	fileExt, mydir, mkpath, isFile, mkDir, rmDir, rmFile,
	forEachLineInFile, isDir, parsePath, newerDestFileExists,
	barf, barfJSON, slurp, slurpJSON, withExt,
	} from '@jdeighan/base-utils/fs'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {dbg, dbgEnter, dbgReturn} from '@jdeighan/base-utils/debug'
import {fromTAML} from '@jdeighan/base-utils/taml'

export {
	fileExt, mydir, mkpath, isFile, mkDir, rmDir, rmFile,
	forEachLineInFile, isDir, parsePath, newerDestFileExists,
	barf, barfJSON, slurp, slurpJSON, withExt,
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

export fixJSON = (filepath, func) =>

	contents = fs.readFileSync(filepath, {encoding: 'utf8'})
	hJson = JSON.parse(contents)
	func(hJson)   # modify in place
	output = JSON.stringify(hJson, null, 3)
	output = fixOutput(output)
	fs.writeFileSync(filepath, output, {encoding: 'utf8'})
	return

# ---------------------------------------------------------------------------

export cloneRepo = (user, repo, dir) =>

	git_repo = "https://github.com/#{user}/#{repo}.git"
	return runCmd "git clone #{git_repo} #{dir}"

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

isHiddenDir = (dir) ->

	hFileInfo = parsePath(dir)
	base = hFileInfo.lDirs.pop()
	return (base.substring(0, 1) == '.')

# ---------------------------------------------------------------------------

isSystemDir = (dir) ->

	return dir in ['$Recycle.Bin', '$WinREAgent']

# ---------------------------------------------------------------------------
#    Get all subdirectories of a directory
#       don't return hidden or system subdirectories
#    Return value is just named, not full paths

export getSubDirs = (dir) =>

	dbgEnter 'getSubDirs', dir
	assert isDir(dir), "not a directory"

	doInclude = (d) ->
		if !d.isDirectory()
			return false
		dirName = d.name
		if isSystemDir(dirName) || (dirName.substring(0,1) == '.')
			return false
		return true

	hOptions = {
		withFileTypes: true
		recursive: false
		}
	lSubDirs = fs.readdirSync(dir, hOptions) \
			.filter(doInclude) \
			.map((d) -> d.name) \
			.sort()
	dbgReturn 'getSubDirs', lSubDirs
	return lSubDirs

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

export pathTo = (fname, searchDir, hOptions={}) =>

	dbgEnter 'pathTo', fname, searchDir, hOptions
	{direction, relative, directory} = getOptions(hOptions, {
		direction: 'down'
		relative: false
		directory: false    # return only the directory the file is in
		})
	dbg "direction = #{direction}"
	dbg "relative = #{relative}"
	dbg "directory = #{directory}"

	assert !(relative && directory),
			"relative & directory are incompatible"
	if ! searchDir
		searchDir = process.cwd()
	assert isDir(searchDir), "Not a directory: #{OL(searchDir)}"

	# --- first check if the file is in searchDir

	filepath = mkpath(searchDir, fname)
	if isFile(filepath)
		if relative
			result = "./#{fname}"
		else if directory
			result = mkpath(searchDir)
		else
			result = mkpath(filepath)
		dbgReturn 'pathTo', result
		return result

	dbg "not found in searchDir '#{searchDir}'"

	if (direction == 'down')
		# --- Search all directories in this directory
		#     getSubDirs() returns dirs sorted alphabetically
		lSubDirs = getSubDirs(searchDir)
		dbg 'lSubDirs', lSubDirs
		for subdir in lSubDirs
			# --- subdir is a simple name, not a full path
			dirPath = mkpath(searchDir, subdir)
			fpath = pathTo(fname, dirPath, hOptions)
			if defined(fpath)
				if relative
					result = fpath.replace('./', "./#{subdir}/")
				else if directory
					result = mkpath(dirPath)
				else
					result = mkpath(fpath)
				dbgReturn 'pathTo', result
				return result
	else if (direction == 'up')
		nLevels = 0
		while defined(dirPath = getParentDir(searchDir))
			nLevels += 1
			fpath = mkpath(dirPath, fname)
			if isFile(fpath)
				if relative
					result = "../".repeat(nLevels) + fname
				else if directory
					result = mkpath(dirPath)
				else
					result = mkpath(fpath)
				dbgReturn 'pathTo', result
				return result
			searchDir = dirPath
	else
		croak "pathTo(): Invalid direction '#{direction}'"
	dbgReturn 'pathTo', undef
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
