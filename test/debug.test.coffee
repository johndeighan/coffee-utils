# debug.test.coffee

import {undef} from '@jdeighan/coffee-utils'
import {log, setLogger} from '@jdeighan/coffee-utils/log'
import {
	setDebugging, debug, resetDebugging,
	} from '@jdeighan/coffee-utils/debug'
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
	simple.equal 23, lLines, ['abc']
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug 'enter myfunc'
	debug 'something'
	debug 'more'
	debug 'return 42 from myfunc'
	debug "Answer is 42"
	simple.equal 35, lLines, [
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
	simple.equal 54, lLines, [
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
	simple.equal 76, lLines, [
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
	simple.equal 96, lLines, [
		"enter myfunc"
		"│   something"
		"│   obj:"
		"│      ---"
		"│      first: this is the first item in the hash"
		"│      second: this is the second item in the hash"
		"└─> return 42 from myfunc"
		]
	)()

# ---------------------------------------------------------------------------
# --- Test ability to debug only a particular function

(() ->
	lLines = []
	resetDebugging()
	setDebugging 'innerFunc'

	debug "enter myfunc"
	debug "something"
	debug "enter innerFunc"
	debug "something else"
	debug "return nothing from innerFunc"
	debug "this should not appear"
	debug "return 42 from myfunc"
	simple.equal 122, lLines, [
		"enter innerFunc"
		"│   something else"
		"└─> return nothing from innerFunc"
		]
	)()

# ---------------------------------------------------------------------------
# --- Test ability to debug only a particular function
#     using actual functions!

(() ->
	lLines = []
	resetDebugging()
	setDebugging 'innerFunc'

	innerFunc = () ->

		debug "enter innerFunc()"
		debug "answer is 42"
		x = 42
		debug "return from innerFunc()"
		return

	outerFunc = () ->

		debug "enter outerFunc()"
		innerFunc()
		debug "return from outerFunc()"
		return

	outerFunc()

	simple.equal 155, lLines, [
		"enter innerFunc()"
		"│   answer is 42"
		"└─> return from innerFunc()"
		]
	)()
