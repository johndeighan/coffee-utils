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

tester.equal 17, withExt('file.starbucks', 'svelte'), 'file.svelte'

# ---------------------------------------------------------------------------

(() ->
	fname = 'heredoc.test.coffee'


	tester.truthy 18, existsSync("#{dir}/#{fname}")
	tester.falsy 19, existsSync("#{dir}/nosuchfile.test.coffee")
	tester.equal 20, pathTo("#{fname}", dir), "#{dir}/#{fname}"
	)()

# ---------------------------------------------------------------------------

tester.equal 30, getSubDirs(dir), ['subdirectory']
tester.equal 31, pathTo('test.txt', dir), \
		"#{dir}/subdirectory/test.txt"
