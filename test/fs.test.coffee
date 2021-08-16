# fs.test.coffee

import {strict as assert} from 'assert'
import {dirname} from 'path';
import {fileURLToPath} from 'url';
import {existsSync, copyFileSync, readFileSync, writeFileSync} from 'fs'

import {AvaTester} from '@jdeighan/ava-tester'
import {say, undef} from '@jdeighan/coffee-utils'
import {mydir, withExt, getSubDirs, pathTo} from '@jdeighan/coffee-utils/fs'

tester = new AvaTester()

dir = mydir(`import.meta.url`)

# ---------------------------------------------------------------------------

tester.equal 18, withExt('file.starbucks', 'svelte'), 'file.svelte'

# ---------------------------------------------------------------------------

(() ->
	fname = 'heredoc.test.coffee'


	tester.truthy 26, existsSync("#{dir}/#{fname}")
	tester.falsy 27, existsSync("#{dir}/nosuchfile.test.coffee")
	tester.equal 28, pathTo("#{fname}", dir), "#{dir}/#{fname}"
	)()

# ---------------------------------------------------------------------------

# --- dirs are returned in alphabetical order
tester.equal 34, getSubDirs(dir), ['data','markdown','subdirectory']

tester.equal 36, pathTo('test.txt', dir), \
		"#{dir}/subdirectory/test.txt"
