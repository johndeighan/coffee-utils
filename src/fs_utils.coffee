# fs_utils.coffee

import {strict as assert} from 'assert'
import {
	dirname, resolve, parse as parse_fname,
	} from 'path';
import {fileURLToPath} from 'url';
import {
	existsSync, copyFileSync, readFileSync, writeFileSync, readdirSync,
	createReadStream,
	} from 'fs'
import {createInterface} from 'readline'

import {
	say, undef, pass, firstLine,
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
#   barf - write a string to a file

export barf = (filepath, contents) ->

	debug "enter barf('#{filepath}', #{contents.length} chars)"
	contents = rtrim(contents) + "\n"
	try
		writeFileSync(filepath, contents, {encoding: 'utf8'})
	catch err
		say "barf(): write failed: #{err.message}"
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
		.filter((d) => d.isDirectory()) \
		.map((d) => mkpath(d.name)) \
		.sort()

# ---------------------------------------------------------------------------
#    Get path to parent directory of a directory

export getParentDir = (dir) ->

	hParts = parse_fname(dir)
	if (hParts.dir == hParts.root)
		return undef
	return mkpath(resolve(dir, '..'))

# ---------------------------------------------------------------------------

export pathTo = (fname, dir, direction="down") ->

	debug "enter pathTo('#{fname}','#{dir}','#{direction}')"
	if unitTesting
		debug "return #{dir}/#{fname} - unit testing"
		return "#{dir}/#{fname}"
	assert existsSync(dir), "Directory #{dir} does not exist"
	if existsSync("#{dir}/#{fname}")
		debug "return #{dir}/#{fname} - file exists"
		return mkpath("#{dir}/#{fname}")
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

```
export async function forEachLine(filepath, func) {

const fileStream = createReadStream(filepath);
const rl = createInterface({
	input: fileStream,
	crlfDelay: Infinity
	});

// Note: we use the crlfDelay option to recognize all instances of CR LF
// ('\r\n') in input.txt as a single line break.

for await (const line of rl) {
	// Each line in input.txt will be successively available here as `line`.
	if (func(line)) {
		rl.close();      // close if true return value
		return;
		}
	}
} // forEachLine()
```
# ---------------------------------------------------------------------------

export forEachBlock = (filepath, func, sep='='.repeat(78)) ->

	lLines = []

	callback = (line) ->
		if (line == sep)
			result = func(lLines.join('\n'))
			lLines = []
			if result
				return true    # close the file
		else
			lLines.push line
		return undef

	await forEachLine filepath, callback
	func(lLines.join('\n'))
	return
