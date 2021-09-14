# code.test.coffee

import {strict as assert} from 'assert'
import test from 'ava'

import {
	undef, say, isString, isHash, isEmpty, nonEmpty,
	} from '@jdeighan/coffee-utils'
import {mydir, mkpath} from '@jdeighan/coffee-utils/fs'
import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	forEachLine, forEachBlock, forEachSetOfBlocks,
	} from '@jdeighan/coffee-utils/block'

testDir = mydir(`import.meta.url`)
simple = new UnitTester()

filepath = mkpath(testDir, 'code2.test.txt')

# ----------------------------------------------------------------------------

(() ->
	lFirstBlocks = undef
	callback = (lBlocks) ->
		lFirstBlocks = lBlocks
		return true   # we're only interested in the first set

	test "line 29", (t) ->
		await forEachSetOfBlocks filepath, callback
		t.deepEqual lFirstBlocks, ["f()", "f"]
	)()

# ----------------------------------------------------------------------------

(() ->
	lAllBlockSets = []
	callback = (lBlocks) ->
		lAllBlockSets.push(lBlocks)
		return

	test "line 44", (t) ->
		await forEachSetOfBlocks filepath, callback
		t.deepEqual lAllBlockSets, [
				["f()", "f"],
				["f = (key=undef) ->\n\tswitch key\n\t\twhen 'ok'\n\t\t\tsay 'all is OK'", "f,say,mkpath"],
				]
	)()
