# temp.coffee

import {say, undef, sep_eq} from '@jdeighan/coffee-utils'
import {forEachLine, forEachBlock} from '@jdeighan/coffee-utils/fs'
import {setDebugging} from '@jdeighan/coffee-utils/debug'

# ---------------------------------------------------------------------------

(() ->
	filepath = "c:/Users/johnd/coffee-utils/test/data/file3.txt"

	callback = (block) ->
		console.log sep_eq
		console.log block
		return undef

	await forEachBlock filepath, callback, '-'.repeat(10)
	say sep_eq
	)()

# ---------------------------------------------------------------------------

