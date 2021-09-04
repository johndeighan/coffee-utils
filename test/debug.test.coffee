# debug.test.coffee

import {undef, say} from '@jdeighan/coffee-utils'
import {startDebugging, debug} from '@jdeighan/coffee-utils/debug'
import {UnitTester} from '@jdeighan/coffee-utils/test'

simple = new UnitTester()

# ---------------------------------------------------------------------------

lLines = undef
myLogger = (str) -> lLines.push(str)
startDebugging({
	logger: myLogger,
	})

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug('abc')
	simple.equal 22, lLines, ['abc']
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug 'enter myfunc'
	debug 'something'
	debug 'more'
	debug 'return 42'
	simple.equal 33, lLines, [
		"enter myfunc"
		"│   something"
		"│   more"
		"└─> return 42"
		]
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug 'enter myfunc'
	debug 'something'
	debug 'enter newfunc'
	debug 'something else'
	debug 'return abc'
	debug 'return 42'
	simple.equal 51, lLines, [
		"enter myfunc"
		"│   something"
		"│   enter newfunc"
		"│   │   something else"
		"│   └─> return abc"
		"└─> return 42"
		]
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	obj = {
		first: 1
		second: 2
		}
	debug 'enter myfunc'
	debug 'something'
	debug obj, 'obj:'
	debug 'return 42'
	simple.equal 73, lLines, [
		"enter myfunc"
		"│   something"
		"│   obj:"
		"│      ---"
		"│      first: 1"
		"│      second: 2"
		"└─> return 42"
		]
	)()

# ---------------------------------------------------------------------------
# test option ifMatches

(() ->
	lLines = []

	startDebugging({
		logger: myLogger
		ifMatches: /something/
		})

	obj = {
		first: 1
		second: 2
		}

	debug 'enter myfunc'
	debug 'something'
	debug obj, 'obj:'
	debug 'return 42'

	simple.equal 105, lLines, [
		"something"
		]
	)()

# ---------------------------------------------------------------------------
# test alternate stringifier

(() ->
	startDebugging({
		logger: myLogger
		stringifier: JSON.stringify
		})

	lLines = []
	obj = {
		first: 1
		second: 2
		}
	debug 'enter myfunc'
	debug 'something'
	debug obj, 'obj:'
	debug 'return 42'
	simple.equal 128, lLines, [
		"enter myfunc"
		"│   something"
		"│   obj:"
		"│      {\"first\":1,\"second\":2}"
		"└─> return 42"
		]
	)()

# ---------------------------------------------------------------------------
