# fs.test.coffee

import {strict as assert} from 'assert'
import {dirname} from 'path';
import {fileURLToPath} from 'url';
import {existsSync, copyFileSync, readFileSync, writeFileSync} from 'fs'

import {AvaTester} from '@jdeighan/ava-tester'
import {withExt, getSubDirs, pathTo} from '@jdeighan/coffee-utils/fs'

tester = new AvaTester()

__dirname = dirname(fileURLToPath(`import.meta.url`));

# ---------------------------------------------------------------------------

tester.equal 17, withExt('file.starbucks', 'svelte'), 'file.svelte'

# ---------------------------------------------------------------------------

(() ->
	fname = 'heredoc.test.coffee'
	tester.truthy 18, existsSync("#{__dirname}/#{fname}")
	tester.falsy 19, existsSync("#{__dirname}/nosuchfile.test.coffee")
	tester.equal 20, pathTo("#{fname}", __dirname), "#{__dirname}/#{fname}"
	)()

# ---------------------------------------------------------------------------

tester.equal 30, getSubDirs(__dirname), ['subdirectory']
tester.equal 31, pathTo('test.txt', __dirname), \
		"#{__dirname}/subdirectory/test.txt"
