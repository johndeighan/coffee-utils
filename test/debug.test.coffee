# debug.test.coffee

import {undef} from '@jdeighan/coffee-utils'
import {log, setLogger} from '@jdeighan/coffee-utils/log'
import {setDebugging, debug} from '@jdeighan/coffee-utils/debug'
import {UnitTester} from '@jdeighan/coffee-utils/test'

simple = new UnitTester()

# ---------------------------------------------------------------------------

lLines = undef
setLogger (str) -> lLines.push(str)
setDebugging true

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug 'abc'
	simple.equal 21, lLines, ['abc']
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug 'enter myfunc'
	debug 'something'
	debug 'more'
	debug 'return 42 from myfunc'
	debug "Answer is 42"
	simple.equal 33, lLines, [
		"enter myfunc"
		"│   something"
		"│   more"
		"└─> return 42 from myfunc"
		"Answer is 42"
		]
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug 'enter myfunc'
	debug 'something'
	debug 'enter newfunc'
	debug 'something else'
	debug 'return abc from newfunc'
	debug 'return 42 from myfunc'
	simple.equal 52, lLines, [
		"enter myfunc"
		"│   something"
		"│   enter newfunc"
		"│   │   something else"
		"│   └─> return abc from newfunc"
		"└─> return 42 from myfunc"
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
	debug 'obj', obj
	debug 'return 42 from myfunc'
	simple.equal 74, lLines, [
		"enter myfunc"
		"│   something"
		'│   obj = {"first":1,"second":2}'
		"└─> return 42 from myfunc"
		]
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	obj = {
		first: "this is the first item in the hash"
		second: "this is the second item in the hash"
		}
	debug 'enter myfunc'
	debug 'something'
	debug 'obj', obj
	debug 'return 42 from myfunc'
	simple.equal 74, lLines, [
		"enter myfunc"
		"│   something"
		"│   obj:"
		"│      ---"
		"│      first: this is the first item in the hash"
		"│      second: this is the second item in the hash"
		"└─> return 42 from myfunc"
		]
	)()
