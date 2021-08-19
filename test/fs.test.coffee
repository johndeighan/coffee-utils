# fs.test.coffee

import {strict as assert} from 'assert'
import {dirname} from 'path';
import {fileURLToPath} from 'url';
import {existsSync, copyFileSync, readFileSync, writeFileSync} from 'fs'

import {AvaTester} from '@jdeighan/ava-tester'
import {say, undef} from '@jdeighan/coffee-utils'
import {
	mydir, mkpath, withExt,
	getSubDirs, pathTo,
	} from '@jdeighan/coffee-utils/fs'

simple = new AvaTester()

dir = mydir(`import.meta.url`)

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
