# fs.test.coffee

import assert from 'assert'
import {dirname, resolve} from 'path';
import {fileURLToPath} from 'url';
import {
	existsSync, copyFileSync, readFileSync, writeFileSync,
	} from 'fs'

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {say, undef} from '@jdeighan/coffee-utils'
import {debug} from '@jdeighan/coffee-utils/debug'
import {
	mydir, mkpath, withExt,
	getSubDirs, pathTo, getFullPath, parseSource,
	} from '@jdeighan/coffee-utils/fs'

simple = new UnitTester()

dir = mydir(`import.meta.url`)
assert existsSync(dir)

# ---------------------------------------------------------------------------

simple.equal 21, withExt('file.starbucks', 'svelte'), 'file.svelte'

# ---------------------------------------------------------------------------

(() ->
	fname = 'debug.test.coffee'

	simple.truthy 29, existsSync("#{dir}/#{fname}")
	simple.falsy 30, existsSync("#{dir}/nosuchfile.test.coffee")
	simple.equal 31, pathTo("#{fname}", dir), "#{dir}/#{fname}"
	)()

# ---------------------------------------------------------------------------

# --- dirs are returned in alphabetical order
simple.equal 37, getSubDirs(dir), ['data','markdown','subdirectory']

simple.equal 39, pathTo('test.txt', dir), \
		"#{dir}/subdirectory/test.txt"

# ---------------------------------------------------------------------------

simple.equal 44, mkpath('/usr/lib', 'johnd'), '/usr/lib/johnd'
simple.equal 45, mkpath("c:", 'local/user'), 'c:/local/user'
simple.equal 46, mkpath('/usr', 'lib', 'local', 'johnd'), '/usr/lib/local/johnd'

simple.equal 48, mkpath('\\usr\\lib', 'johnd'), '/usr/lib/johnd'
simple.equal 49, mkpath("c:", 'local\\user'), 'c:/local/user'
simple.equal 50, mkpath('\\usr', 'lib', 'local', 'johnd'), '/usr/lib/local/johnd'

simple.equal 55, mkpath('C:\\Users\\johnd', 'cielo'), 'c:/Users/johnd/cielo'

# ---------------------------------------------------------------------------
# test getFullPath()

# --- current working directory is the root dir, i.e. parent of this directory
wd = mkpath(process.cwd())

myfname = 'fs.test.coffee'
mypath = mkpath(dir, myfname)
rootdir = mkpath(resolve(dir, '..'))
assert rootdir == wd, "#{rootdir} should equal #{wd}"

debug "Current Working Directory = '#{wd}'"
debug "dir = '#{dir}'"
debug "myfname = '#{myfname}'"
debug "mypath = '#{mypath}'"
debug "rootdir = '#{rootdir}'"

# --- given a full path, only change \ to /
simple.equal 72, getFullPath(mypath), mypath

# --- given a simple file name, prepend the current working directory
simple.equal 75, getFullPath(myfname), mkpath(rootdir, myfname)

# --- leading . should be resolved
simple.equal 78, getFullPath("./#{myfname}"), mkpath(rootdir, myfname)

# --- leading .. should be resolved
simple.equal 81, getFullPath("./test/../#{myfname}"), mkpath(rootdir, myfname)

simple.equal 86, parseSource('unit test'), {
	filename: 'unit test'
	stub: 'unit test'
	}

simple.equal 91, parseSource("c:/Users/johnd/oz/src/test.js"), {
	dir: 'c:/Users/johnd/oz/src'
	fullpath: 'c:/Users/johnd/oz/src/test.js'
	filename: 'test.js'
	stub: 'test'
	ext: '.js'
	}

simple.equal 91, parseSource("c:\\Users\\johnd\\oz\\src\\test.js"), {
	dir: 'c:/Users/johnd/oz/src'
	fullpath: 'c:/Users/johnd/oz/src/test.js'
	filename: 'test.js'
	stub: 'test'
	ext: '.js'
	}
