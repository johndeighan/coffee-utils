# fs_utils.coffee

import {strict as assert} from 'assert'
import {
	dirname, resolve, parse as parse_fname,
	} from 'path';
import {fileURLToPath} from 'url';
import {
	existsSync, copyFileSync, readFileSync, writeFileSync, readdirSync,
	} from 'fs'

import {
	say, taml, undef, pass,
	rtrim, error, unitTesting,
	} from '@jdeighan/coffee-utils'
import {debug} from '@jdeighan/coffee-utils/debug'

# ---------------------------------------------------------------------------
#    mydir() - pass argument `import.meta.url` and it will return
#              the directory your file is in

export mydir = (url) ->

	return mkpath(dirname(fileURLToPath(url)));

# ---------------------------------------------------------------------------

export mkpath = (lParts...) ->

	return lParts.join('/').replace(/\\/g, '/')

# ---------------------------------------------------------------------------

export getFullPath = (filepath) ->

	return mkpath(resolve(filepath))

# ---------------------------------------------------------------------------
#   backup - back up a file

# --- If report is true, missing source files are not an error
#     but both missing source files and successful copies
#     are reported via console.log

export backup = (file, from, to, report=false) ->
	src = "#{from}/#{file}"
	dest = "#{to}/#{file}"

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

	debug "enter slurp '#{filepath}'"
	filepath = filepath.replace(/\//g, "\\")
	contents = readFileSync(filepath, 'utf8').toString()
	debug "return from slurp()"
	return contents

# ---------------------------------------------------------------------------
#   slurpTAML - read TAML from a file

export slurpTAML = (filepath) ->
	contents = slurp(filepath)
	return taml(contents)

# ---------------------------------------------------------------------------
#   barf - write a string to a file

export barf = (filepath, contents) ->

	contents = rtrim(contents) + '\n'
	filepath = filepath.replace(/\//g, "\\")
	writeFileSync(filepath, contents, {encoding: 'utf8'})

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
		.filter((d) => d.isDirectory()) \
		.map((d) => d.name) \
		.sort()

# ---------------------------------------------------------------------------
#    Get path to parent directory of a directory

export getParentDir = (dir) ->

	hParts = parse_fname(dir)
	if (hParts.dir == hParts.root)
		return undef
	return resolve(dir, '..')

# ---------------------------------------------------------------------------

export pathTo = (fname, dir, direction="down") ->

	debug "enter pathTo('#{fname}','#{dir}','#{direction}')"
	if unitTesting
		debug "return #{dir}/#{fname} - unit testing"
		return "#{dir}/#{fname}"
	assert existsSync(dir), "Directory #{dir} does not exist"
	if existsSync("#{dir}/#{fname}")
		debug "return #{dir}/#{fname} - file exists"
		return "#{dir}/#{fname}"
	else if (direction == 'down')
		# --- Search all directories in this directory
		for subdir in getSubDirs(dir)
			if fpath = pathTo(fname, "#{dir}/#{subdir}")
				debug "return #{fpath}"
				return fpath
	else if (direction == 'up')
		while dir = getParentDir(dir)
			debug "check #{dir}"
			if existsSync("#{dir}/#{fname}")
				debug "return #{dir}/#{fname}"
				return "#{dir}/#{fname}"
	else
		error "pathTo(): Invalid direction '#{direction}'"
	debug "return undef - file not found"
	return undef

# ---------------------------------------------------------------------------

hExtToEnvVar = {
	'.md':   'dir_markdown',
	'.taml': 'dir_data',
	'.txt':  'dir_data',
	}

# ---------------------------------------------------------------------------

export findFile = (fname) ->

	{root, dir, base, ext} = parse_fname(fname.trim())
	assert not root && not dir, "findFile():" \
		+ " root='#{root}', dir='#{dir}'" \
		+ " - full path not allowed"
	envvar = hExtToEnvVar[ext]
	assert envvar, "findFile() doesn't work for ext '#{ext}'"
	dir = process.env[envvar]
	assert dir, "No env var set for file extension '#{ext}'"
	fullpath = pathTo(base, dir)   # guarantees that file exists
	assert fullpath, "findFile(): Can't find file #{fname}"
	return fullpath
