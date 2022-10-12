# fs.coffee

import pathlib from 'path'
import urllib from 'url'
import fs from 'fs'
import NReadLines from 'n-readlines'

import {assert, croak} from '@jdeighan/exceptions'
import {LOG} from '@jdeighan/exceptions/log'
import {
	undef, pass, defined, rtrim, isEmpty, nonEmpty,
	isString, isArray, isHash, isRegExp, isFunction, OL,
	} from '@jdeighan/coffee-utils'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'

# ---------------------------------------------------------------------------
#    mydir() - pass argument import.meta.url and it will return
#              the directory your file is in

export mydir = (url) ->

	path = urllib.fileURLToPath(url)
	dir = pathlib.dirname(path)
	final = mkpath(dir)
	return final

# ---------------------------------------------------------------------------
#    myfile() - pass argument import.meta.url and it will return
#               the name of your file

export myfile = (url) ->

	path = urllib.fileURLToPath(url)
	filename = pathlib.parse(path).base
	return filename

# ---------------------------------------------------------------------------
#    myfullpath() - pass argument import.meta.url and it will return
#                   the full path to your file

export myfullpath = (url) ->

	path = urllib.fileURLToPath(url)
	return mkpath(path)

# ---------------------------------------------------------------------------

export isFile = (fullpath) ->

	return fs.lstatSync(fullpath).isFile()

# ---------------------------------------------------------------------------

export isDir = (fullpath) ->

	try
		obj = fs.lstatSync(fullpath)
		if !obj? then return false
		return obj.isDirectory()
	catch
		return false

# ---------------------------------------------------------------------------

export isSimpleFileName = (path) ->

	h = pathlib.parse(path)
	return ! h.root && ! h.dir && h.base

# ---------------------------------------------------------------------------

export fileStub = (path) ->

	assert isString(path), "fileExt(): path not a string"
	if lMatches = path.match(/^(.*)\.[A-Za-z0-9_]+$/)
		return lMatches[1]
	else
		return ''

# ---------------------------------------------------------------------------

export fileExt = (path) ->

	assert isString(path), "fileExt(): path not a string"
	if lMatches = path.match(/\.[A-Za-z0-9_]+$/)
		return lMatches[0]
	else
		return ''

# ---------------------------------------------------------------------------

export mkpath = (lParts...) ->

	# --- Ignore empty parts
	lNewParts = []
	for part in lParts
		if nonEmpty(part)
			lNewParts.push part

	newPath = lNewParts.join('/').replace(/\\/g, '/')
	if lMatches = newPath.match(/^([A-Z])\:(.*)$/)
		[_, drive, rest] = lMatches
		return "#{drive.toLowerCase()}:#{rest}"
	else
		return newPath

# ---------------------------------------------------------------------------

export getFullPath = (filepath) ->

	return mkpath(pathlib.resolve(filepath))

# ---------------------------------------------------------------------------

export forEachLineInFile = (filepath, func) ->

	reader = new NReadLines(filepath)
	nLines = 0

	while (buffer = reader.next())
		nLines += 1
		# --- text is split on \n chars, we also need to remove \r chars
		line = buffer.toString().replace(/\r/g, '')
		if func(line, nLines) == 'EOF'
			reader.close()   # allow premature termination
	return

# ---------------------------------------------------------------------------
#   slurp - read an entire file into a string

export slurp = (filepath, maxLines=undef) ->

	if maxLines?
		lLines = []
		forEachLineInFile filepath, (line, nLines) ->
			lLines.push line
			return if nLines >= maxLines then 'EOF' else undef
		contents = lLines.join("\n")
	else
		filepath = filepath.replace(/\//g, "\\")
		contents = fs.readFileSync(filepath, 'utf8').toString()
	return contents

# ---------------------------------------------------------------------------
#   barf - write a string to a file

export barf = (filepath, contents) ->

	if isEmpty(contents)
		return
	if isArray(contents)
		contents = arrayToBlock(contents)
	else if ! isString(contents)
		croak "barf(): Invalid contents"
	contents = rtrim(contents) + "\n"
	fs.writeFileSync(filepath, contents, {encoding: 'utf8'})
	return

# ---------------------------------------------------------------------------
#   withExt - change file extention in a file name

export withExt = (path, newExt, hOptions={}) ->
	# --- Valid options:
	#        removeLeadingUnderScore - boolean

	assert newExt, "withExt(): No newExt provided"
	if newExt.indexOf('.') != 0
		newExt = '.' + newExt

	{dir, name, ext} = pathlib.parse(path)
	if hOptions.removeLeadingUnderScore && (name.indexOf('_')==0)
		name = name.substr(1)
	return mkpath(dir, "#{name}#{newExt}")

# ---------------------------------------------------------------------------
#   removeFileWithExt - remove file with different ext

export removeFileWithExt = (path, newExt, hOptions={}) ->
	# --- Valid options:
	#        doLog
	#        removeLeadingUnderScore

	fullpath = withExt(path, newExt, hOptions)
	try
		fs.unlinkSync fullpath
		if hOptions.doLog
			LOG "   unlink #{filename}"
		success = true
	catch err
		LOG "   UNLINK FAILED: #{err.message}"
		success = false
	return success

# ---------------------------------------------------------------------------
#   withUnderScore - add '_' to file name

export withUnderScore = (path) ->

	{dir, base} = pathlib.parse(path)
	return mkpath(dir, "_#{base}")

# ---------------------------------------------------------------------------

isSystemDir = (dir) ->

	return dir in ['$Recycle.Bin', '$WinREAgent']

# ---------------------------------------------------------------------------
#    Get all subdirectories of a directory

export getSubDirs = (dir) ->

	return fs.readdirSync(dir, {withFileTypes: true}) \
		.filter((d) -> d.isDirectory() && !isSystemDir(d.name)) \
		.map((d) -> mkpath(d.name)) \
		.sort()

# ---------------------------------------------------------------------------
#    Get path to parent directory of a directory

export getParentDir = (dir) ->

	hParts = pathlib.parse(dir)
	if (hParts.dir == hParts.root)
		return undef
	return mkpath(pathlib.resolve(dir, '..'))

# ---------------------------------------------------------------------------

export forEachFile = (dir, cb, filt=undef, level=0) ->
	# --- filt can be a regular expression or a function that gets:
	#        (filename, dir, level)
	#     callback will get parms (filename, dir, level)

	lSubDirectories = []
	for ent in fs.readdirSync(dir, {withFileTypes: true})
		if ent.isDirectory()
			lSubDirectories.push ent
		else if ent.isFile()
			if ! filt?
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

export pathTo = (fname, searchDir, hOptions={}) ->

	{direction, relative} = hOptions
	if isEmpty(direction)
		direction = 'down'
	if isEmpty(relative)
		relative = false

	if ! searchDir
		searchDir = process.cwd()
	assert fs.existsSync(searchDir), "Dir #{searchDir} does not exist"
	filepath = mkpath(searchDir, fname)
	if fs.existsSync(filepath)
		if relative
			filepath = "./#{fname}"
		return filepath

	if (direction == 'down')
		# --- Search all directories in this directory
		#     getSubDirs() returns dirs sorted alphabetically
		for subdir in getSubDirs(searchDir)
			dirpath = mkpath(searchDir, subdir)
			if defined(fpath = pathTo(fname, dirpath, hOptions))
				if relative
					fpath = fpath.replace('./', "./#{subdir}/")
				return fpath
	else if (direction == 'up')
		nLevels = 0
		while defined(dirPath = getParentDir(searchDir))
			nLevels += 1
			fpath = mkpath(dirPath, fname)
			if fs.existsSync(fpath)
				if relative
					fpath = "../".repeat(nLevels) + fname
					return fpath
				else
					return fpath
			searchDir = dirPath
	else
		croak "pathTo(): Invalid direction '#{direction}'"
	return undef

# ---------------------------------------------------------------------------

export allPathsTo = (fname, searchDir) ->
	# --- Only searches upward

	if ! searchDir
		searchDir = process.cwd()
	path = pathTo(fname, searchDir, {direction: "up"})
	if path?
		lPaths = [path]    # --- build an array of paths
		# --- search upward for files, but return ordered top down
		while (h = pathlib.parse(path)) \
				&& (path = pathTo(fname, pathlib.resolve(h.dir, '..'), {direction: "up"}))
			lPaths.unshift path
		return lPaths
	else
		return []

# ---------------------------------------------------------------------------

export newerDestFileExists = (srcPath, destPath) ->

	if ! fs.existsSync(destPath)
		return false
	srcModTime = fs.statSync(srcPath).mtimeMs
	destModTime = fs.statSync(destPath).mtimeMs
	if destModTime >= srcModTime
		return true
	else
		return false

# ---------------------------------------------------------------------------

export shortenPath = (path) ->
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

export parseSource = (source) ->
	# --- returns {
	#        dir
	#        filename
	#        fullpath
	#        stub
	#        ext
	#        purpose
	#        }
	# --- NOTE: source may be a file URL, e.g. import.meta.url

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
	return hSourceInfo

# ---------------------------------------------------------------------------
#   backup - back up a file

# --- If report is true, missing source files are not an error
#     but both missing source files and successful copies
#     are reported via LOG

export backup = (file, from, to, report=false) ->
	src = mkpath(from, file)
	dest = mkpath(to, file)

	if report
		if fs.existsSync(src)
			LOG "OK #{file}"
			fs.copyFileSync(src, dest)
		else
			LOG "MISSING #{src}"
	else
		fs.copyFileSync(src, dest)
