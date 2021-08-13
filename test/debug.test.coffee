# debug.test.coffee

import {AvaTester} from '@jdeighan/ava-tester'

import {undef, say} from '@jdeighan/coffee-utils'
import {setDebugging, debug} from '@jdeighan/coffee-utils/debug'

simple = new AvaTester()

# ---------------------------------------------------------------------------

lLines = undef
myLogger = (str) -> lLines.push(str)
myDumper = (x) -> lLines.push(JSON.stringify(x))
setDebugging(true, myLogger, myDumper)

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
	simple.equal 32, lLines, [
		"enter myfunc"
		"│   something"
		"│   obj:"
		"│   {\"first\":1,\"second\":2}"
		"└─> return 42"
		]
	)()

# ---------------------------------------------------------------------------
