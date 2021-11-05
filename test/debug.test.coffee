# debug.test.coffee

import {undef, OL} from '@jdeighan/coffee-utils'
import {blockToArray, arrayToBlock} from '@jdeighan/coffee-utils/block'
import {log, setLogger} from '@jdeighan/coffee-utils/log'
import {
	setDebugging, debug, resetDebugging, funcMatch,
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
	simple.equal 24, lLines, ['abc']
	)()

# ---------------------------------------------------------------------------

class TraceTester extends UnitTester

	initialize: () ->
		lLines = []

	transformValue: (block) ->

		for line in blockToArray(block)
			debug line
		return arrayToBlock(lLines)

	normalize: (text) ->
		return text

tester = new TraceTester()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug 'enter myfunc'
	debug 'something'
	debug 'more'
	debug 'return 42 from myfunc'
	debug "Answer is 42"
	simple.equal 54, lLines, [
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
	simple.equal 73, lLines, [
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
	simple.equal 95, lLines, [
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
	simple.equal 115, lLines, [
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
	simple.equal 141, lLines, [
		"enter innerFunc"
		"│   something else"
		"└─> return nothing from innerFunc"
		]
	setDebugging false
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

	simple.equal 175, lLines, [
		"enter innerFunc()"
		"│   answer is 42"
		"└─> return from innerFunc()"
		]
	setDebugging false
	)()

# ---------------------------------------------------------------------------

(() ->
	setDebugging 'get'

	simple.truthy 188, funcMatch('get')
	simple.truthy 189, funcMatch('StringInput.get')
	setDebugging false
	)()

# ---------------------------------------------------------------------------

(() ->
	resetDebugging()
	setDebugging true
	lLines = []

	line = 'first line'
	debug "line is #{OL(line)}"

	simple.equal 203, lLines.length, 1
	simple.equal 204, lLines, [
		"line is 'first line'"
		]
	setDebugging false
	)()

# ---------------------------------------------------------------------------

(() ->
	resetDebugging()
	setDebugging true
	lLines = []

	obj = {
		first: "this is the first item in the hash"
		second: "this is the second item in the hash"
		}

	debug 'enter myfunc'
	debug 'return from myfunc', obj
	debug "Answer is 42"
	simple.equal 225, lLines, [
		"enter myfunc"
		"└─> return from myfunc:"
		"       ---"
		"       first: this is the first item in the hash"
		"       second: this is the second item in the hash"
		"Answer is 42"
		]
	)()

# ---------------------------------------------------------------------------

(() ->
	resetDebugging()
	setDebugging true
	lLines = []

	longBlock = """
		this is one very long line
		this is another very long line
		"""

	debug 'enter myfunc'
	debug 'return from myfunc', longBlock
	debug "Answer is 42"
	simple.equal 250, lLines, [
		"enter myfunc"
		"└─> return from myfunc:"
		"    =========================================="
		"    this is one very long line"
		"    this is another very long line"
		"    =========================================="
		"Answer is 42"
		]
	)()

# ---------------------------------------------------------------------------

(() ->
	resetDebugging()
	setDebugging 'get'

	block = """
		enter myfunc
		enter get
		enter fetch
		return from fetch
		return from get
		enter nofunc
		return from nofunc
		enter get
		something
		return from get
		return from myfunc
		"""

	tester.equal 279, block, """
		enter get
		│   enter fetch
		│   └─> return from fetch
		└─> return from get
		enter get
		│   something
		└─> return from get
		"""
	)()
