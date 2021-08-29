# debug.test.coffee

import {undef, say} from '@jdeighan/coffee-utils'
import {setDebugging, debug} from '@jdeighan/coffee-utils/debug'
import {UnitTester} from '@jdeighan/coffee-utils/test'

simple = new UnitTester()

# ---------------------------------------------------------------------------

lLines = undef

myLogger = (str) -> lLines.push(str)
setDebugging(true, {
	loggerFunc: myLogger
	})

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug('abc')
	simple.equal 24, lLines, ['abc']
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug 'enter myfunc'
	debug 'something'
	debug 'more'
	debug 'return 42'
	simple.equal 35, lLines, [
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
	simple.equal 53, lLines, [
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
	simple.equal 75, lLines, [
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

	setDebugging(true, {
		loggerFunc: myLogger
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

	simple.equal 108, lLines, [
		"something"
		]
	)()

# ---------------------------------------------------------------------------
# test alternate stringifier

(() ->
	setDebugging(true, {
		loggerFunc: myLogger
		stringifierFunc: JSON.stringify
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
	simple.equal 75, lLines, [
		"enter myfunc"
		"│   something"
		"│   obj:"
		"│      {\"first\":1,\"second\":2}"
		"└─> return 42"
		]
	)()

# ---------------------------------------------------------------------------
