# fs_utils.coffee

import {strict as assert} from 'assert'
import {
	dirname, resolve, parse as parsePath,
	} from 'path'
import {fileURLToPath} from 'url'
import {
	existsSync, copyFileSync, readFileSync, writeFileSync, readdirSync,
	createReadStream, mkdirSync, renameSync, statSync,
	} from 'fs'

import {
	undef, pass, rtrim, error, nonEmpty,
	isRegExp, isFunction, croak,
	} from '@jdeighan/coffee-utils'
import {log} from '@jdeighan/coffee-utils/log'
import {debug} from '@jdeighan/coffee-utils/debug'

# ---------------------------------------------------------------------------

export parseSource = (source) ->
	# --- returns {
	#        dir
	#        filename   # only this is guaranteed to be set
	#        stub
	#        ext
	#        }

	debug "enter parseSource()"
	if source == 'unit test'
		debug "return 'unit test' from parseSource()"
		return {
			filename: 'unit test'
			stub: 'unit test'
			}
	try
		hInfo = parsePath(source)
		debug "return from parseSource()", hInfo
		if hInfo.root
			dir = mkpath(hInfo.dir)   # change \ to /
			return {
				dir: dir
				fullpath: mkpath(dir, hInfo.base)
				filename: hInfo.base
				stub: hInfo.name
				ext: hInfo.ext
				}
		else
			return {
				dir: mkpath(hInfo.dir)   # change \ to /
				filename: hInfo.base
				stub: hInfo.name
				ext: hInfo.ext
				}
	catch err
		debug "return '#{err.message} from parseSource()"
		return {
			filename: source
			stub: source
			error: err.message
			}

# ---------------------------------------------------------------------------
#    mydir() - pass argument `import.meta.url` and it will return
#              the directory your file is in

export mydir = (url) ->

	return mkpath(dirname(fileURLToPath(url.replace(/\@/g, '%40'))))

# ---------------------------------------------------------------------------

export mkpath = (lParts...) ->

	newPath = lParts.join('/').replace(/\\/g, '/')
	if lMatches = newPath.match(/^([A-Z])\:(.*)$/)
		[_, drive, rest] = lMatches
		return "#{drive.toLowerCase()}:#{rest}"
	else
		return newPath

# ---------------------------------------------------------------------------

export getFullPath = (filepath) ->

	return mkpath(resolve(filepath))

# ---------------------------------------------------------------------------
#   backup - back up a file

# --- If report is true, missing source files are not an error
#     but both missing source files and successful copies
#     are reported via console.log

export backup = (file, from, to, report=false) ->
	src = mkpath(from, file)
	dest = mkpath(to, file)

	if report
		if existsSync(src)
			console.log "OK #{file}"
			copyFileSync(src, dest)
		else
			console.log "MISSING #{src}"
	else
		copyFileSync(src, dest)

# ---------------------------------------------------------------------------
#   slurp - read an entire file into a string

export slurp = (filepath) ->

	debug "enter slurp('#{filepath}')"
	filepath = filepath.replace(/\//g, "\\")
	contents = readFileSync(filepath, 'utf8').toString()
	debug "return from slurp()", contents
	return contents

# ---------------------------------------------------------------------------
#   barf - write a string to a file

export barf = (filepath, contents) ->

	debug "enter barf('#{filepath}')", contents
	contents = rtrim(contents) + "\n"
	try
		writeFileSync(filepath, contents, {encoding: 'utf8'})
	catch err
		log "barf(): write failed: #{err.message}"
	debug "return from barf()"
	return

# ---------------------------------------------------------------------------
#   withExt - change file extention in a file name

export withExt = (filename, newExt) ->

	assert newExt, "withExt(): No newExt provided"
	if newExt.indexOf('.') != 0
		newExt = '.' + newExt
	if lMatches = filename.match(/^(.*)\.([^.]+)$/)
		[_, pre, ext] = lMatches
		return "#{pre}#{newExt}"
	else
		error "withExt(): Invalid file name: '#{filename}'"

# ---------------------------------------------------------------------------
#    Get all subdirectories of a directory

export getSubDirs = (dir) ->

	return readdirSync(dir, {withFileTypes: true}) \
		.filter((d) -> d.isDirectory()) \
		.map((d) -> mkpath(d.name)) \
		.sort()

# ---------------------------------------------------------------------------
#    Get path to parent directory of a directory

export getParentDir = (dir) ->

	hParts = parsePath(dir)
	if (hParts.dir == hParts.root)
		return undef
	return mkpath(resolve(dir, '..'))

# ---------------------------------------------------------------------------

export forEachFile = (dir, cb, filt=undef, level=0) ->
	# --- filt can be a regular expression or a function that gets:
	#        (filename, dir, level)
	#     callback will get parms (filename, dir, level)

	lSubDirectories = []
	for ent in readdirSync(dir, {withFileTypes: true})
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

export pathTo = (fname, dir, direction="down") ->

	debug "enter pathTo('#{fname}','#{dir}','#{direction}')"
	assert existsSync(dir), "Directory #{dir} does not exist"
	if existsSync("#{dir}/#{fname}")
		debug "return from pathTo: #{dir}/#{fname} - file exists"
		return mkpath("#{dir}/#{fname}")
	else if (direction == 'down')
		# --- Search all directories in this directory
		for subdir in getSubDirs(dir)
			if fpath = pathTo(fname, "#{dir}/#{subdir}")
				debug "return from pathTo: #{fpath}"
				return fpath
	else if (direction == 'up')
		while dir = getParentDir(dir)
			debug "check #{dir}"
			if existsSync("#{dir}/#{fname}")
				debug "return from pathTo(): #{dir}/#{fname}"
				return "#{dir}/#{fname}"
	else
		error "pathTo(): Invalid direction '#{direction}'"
	debug "return undef from pathTo - file not found"
	return undef

# ---------------------------------------------------------------------------

export allPathsTo = (fname, searchDir) ->
	# --- Only searches upward

	path = pathTo(fname, searchDir, "up")
	if path?
		lPaths = [path]    # --- build an array of paths
		# --- search upward for files, but return ordered top down
		while (h = parsePath(path)) \
				&& (path = pathTo(fname, resolve(h.dir, '..'), "up"))
			lPaths.unshift path
		return lPaths
	else
		return []

# ---------------------------------------------------------------------------

export newerDestFileExists = (srcPath, destPath) ->

	debug "enter newerDestFileExists()"
	if ! existsSync(destPath)
		debug "return false from newerDestFileExists() - no file"
		return false
	srcModTime = statSync(srcPath).mtimeMs
	destModTime = statSync(destPath).mtimeMs
	debug "srcModTime = #{srcModTime}"
	debug "destModTime = #{destModTime}"
	if destModTime >= srcModTime
		debug "#{destPath} is up to date"
		debug "return true from newerDestFileExists()"
		return true
	else
		debug "#{destPath} is old"
		debug "return false from newerDestFileExists()"
		return false
