# fs.test.cielo

import {dirname, resolve} from 'path'
import {fileURLToPath} from 'url'
import {
	existsSync, copyFileSync, readFileSync, writeFileSync,
	} from 'fs'

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {say, undef, assert} from '@jdeighan/coffee-utils'
import {debug} from '@jdeighan/coffee-utils/debug'
import {
	mydir, mkpath, isFile, isDir, isSimpleFileName,
	getSubDirs, pathTo, getFullPath, parseSource, fileExt,
	withExt, withUnderScore,
	} from '@jdeighan/coffee-utils/fs'

simple = new UnitTester()

dir = mydir(`import.meta.url`)
assert existsSync(dir)

# ---------------------------------------------------------------------------

hOpt = {removeLeadingUnderScore: true}

simple.equal 21, withExt('file.py', 'svelte'), 'file.svelte'
simple.equal 21, withExt('file.py', 'svelte', hOpt), 'file.svelte'
simple.equal 21, withExt('_file.py', 'svelte', hOpt), 'file.svelte'

simple.equal 21, withExt('/bin/file.py', 'svelte'), '/bin/file.svelte'
simple.equal 21, withExt('/bin/file.py', 'svelte', hOpt), '/bin/file.svelte'
simple.equal 21, withExt('/bin/_file.py', 'svelte', hOpt), '/bin/file.svelte'

simple.equal 21, withUnderScore('file.py', 'svelte'), '_file.py'
simple.equal 21, withUnderScore('_file.py', 'svelte'), '__file.py'

simple.equal 21, withUnderScore('/bin/file.py', 'svelte'), '/bin/_file.py'
simple.equal 21, withUnderScore('/bin/_file.py', 'svelte'), '/bin/__file.py'

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

simple.equal 39, pathTo('test.txt', dir), "#{dir}/subdirectory/test.txt"

# ---------------------------------------------------------------------------

simple.equal 44, mkpath('/usr/lib', 'johnd'), '/usr/lib/johnd'
simple.equal 48, mkpath('', '/usr/lib', undef, 'johnd'), '/usr/lib/johnd'
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

if process.platform == 'win32'
	simple.truthy 108, isDir('c:/Users')
	simple.truthy 109, isDir('c:/Program Files')
	simple.falsy  110, isFile('c:/Users')
	simple.falsy  111, isFile('c:/Program Files')

	simple.falsy  113, isDir('c:/Windows/notepad.exe')
	simple.falsy  114, isDir(
		'c:/Program Files/Windows Media Player/wmplayer.exe'
		)
	simple.truthy 115, isFile('c:/Windows/notepad.exe')
	simple.truthy 116, isFile(
		'c:/Program Files/Windows Media Player/wmplayer.exe'
		)

	simple.truthy 118, isSimpleFileName('notepad.exe')
	simple.falsy  119, isSimpleFileName(
		'c:/Program Files/Windows Media Player/wmplayer.exe'
		)

simple.equal 121, fileExt('file.txt'), '.txt'
simple.equal 122, fileExt('file.'), ''
simple.equal 123, fileExt('file.99'), '.99'
simple.equal 124, fileExt('file._txt'), '._txt'
