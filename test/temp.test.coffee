# utils.test.coffee

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {croak, arrayToString} from '@jdeighan/coffee-utils'
import {setLogger} from '@jdeighan/coffee-utils/log'
import {setDebugging} from '@jdeighan/coffee-utils/debug'

simple = new UnitTester()

# ---------------------------------------------------------------------------
# test croak()

(() ->
	lLines = []
	setLogger (line) -> lLines.push(line)

	obj = {a:1, b:2}
	try
		croak "bad stuff", "An Object", obj
	simple.equal -254, arrayToString(lLines), """
			ERROR: bad stuff
			An Object = {"a":1,"b":2}
			"""
	setLogger()
	)()
