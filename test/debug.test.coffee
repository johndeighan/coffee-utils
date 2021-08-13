# debug.test.coffee

import {AvaTester} from '@jdeighan/ava-tester'
import {
	undef,
	setDebugging,
	debug,
	} from '../src/coffee_utils.js'

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
	simple.equal 25, lLines, ['abc']
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	debug 'enter myfunc'
	debug 'something'
	debug 'return 42'
	simple.equal 34, lLines, [
		"enter myfunc"
		"   something"
		"   return 42"
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
	simple.equal 34, lLines, [
		"enter myfunc"
		"   something"
		"   enter newfunc"
		"      something else"
		"      return abc"
		"   return 42"
		]
	)()

# ---------------------------------------------------------------------------
