# log.test.coffee

import {undef, arrayToString} from '@jdeighan/coffee-utils'
import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	stringify, setStringifier, log, setLogger, tamlStringify,
	} from '@jdeighan/coffee-utils/log'

simple = new UnitTester()

# ---------------------------------------------------------------------------

class LogTester extends UnitTester

	transformValue: (lLines) ->
		return arrayToString(lLines)
	normalize: (text) ->
		return text

tester = new LogTester()

# ---------------------------------------------------------------------------

lLines = undef
setLogger (str) -> lLines.push(str)

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	log 'enter myfunc'
	tester.equal 32, lLines, """
			enter myfunc
			"""
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	log 'abc'
	log 'def'
	log 'ghi'
	tester.equal 44, lLines, """
			abc
			def
			ghi
			"""
	)()

# ---------------------------------------------------------------------------
# test logging various small objects

(() ->
	lLines = []
	log 'abc'
	log 'name', undef
	tester.equal 58, lLines, """
			abc
			name = undef
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', 42
	tester.equal 68, lLines, """
			abc
			name = 42
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', 'John'
	tester.equal 78, lLines, """
			abc
			name = 'John'
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', {a: 1, b: 'xyz'}
	tester.equal 88, lLines, """
			abc
			name = {"a":1,"b":"xyz"}
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', ['a', 42, [1,2]]
	tester.equal 98, lLines, """
			abc
			name = ["a",42,[1,2]]
			"""
	)()

# ---------------------------------------------------------------------------
# test logging various large objects

(() ->
	lLines = []
	log 'abc'
	log 'name', """
			This is a rather long bit of
			text which changes
			how it's displayed
			"""
	tester.equal 115, lLines, """
			abc
			name:
			   This is a rather long bit of
			   text which changes
			   how it's displayed
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', {
		fname: 'John',
		lname: 'Deighan',
		age: 68,
		home: 'Blacksburg, VA',
		}
	tester.equal 133, lLines, """
			abc
			name:
			   ---
			   fname: John
			   lname: Deighan
			   age: 68
			   home: Blacksburg, VA
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', [
		68,
		'a rather long string of text',
		{a:1, b:2}
		]
	tester.equal 152, lLines, """
			abc
			name:
			   ---
			   - 68
			   - a rather long string of text
			   -
			      a: 1
			      b: 2
			"""
	)()

# ---------------------------------------------------------------------------
# test providing a prefix

(() ->
	lLines = []
	log 'name', undef, {prefix: '<-->', logItem: true}
	tester.equal 170, lLines, """
			<-->name = undef
			"""
	)()

(() ->
	lLines = []
	log 'name', 42, {prefix: '<-->', logItem: true}
	tester.equal 178, lLines, """
			<-->name = 42
			"""
	)()

(() ->
	lLines = []
	log 'name', 'John', {prefix: '<-->', logItem: true}
	tester.equal 186, lLines, """
			<-->name = 'John'
			"""
	)()

(() ->
	lLines = []
	log 'name', {a: 1, b: 'xyz'}, {prefix: '<-->', logItem: true}
	tester.equal 194, lLines, """
			<-->name = {"a":1,"b":"xyz"}
			"""
	)()

(() ->
	lLines = []
	log 'name', ['a', 42, [1,2]], {prefix: '<-->', logItem: true}
	tester.equal 202, lLines, """
			<-->name = ["a",42,[1,2]]
			"""
	)()

(() ->
	lLines = []
	log 'name', """
			This is a rather long bit of
			text which changes
			how it's displayed
			""", {prefix: '<-->', logItem: true}
	tester.equal 214, lLines, """
			<-->name:
			<-->   This is a rather long bit of
			<-->   text which changes
			<-->   how it's displayed
			"""
	)()

(() ->
	lLines = []
	log 'name', {
		fname: 'John',
		lname: 'Deighan',
		age: 68,
		home: 'Blacksburg, VA',
		}, {prefix: '<-->', logItem: true}
	tester.equal 230, lLines, """
			<-->name:
			<-->   ---
			<-->   fname: John
			<-->   lname: Deighan
			<-->   age: 68
			<-->   home: Blacksburg, VA
			"""
	)()

(() ->
	lLines = []
	log 'name', [
		68,
		'a rather long string of text',
		{a:1, b:2}
		], {prefix: '<-->', logItem: true}
	tester.equal 247, lLines, """
			<-->name:
			<-->   ---
			<-->   - 68
			<-->   - a rather long string of text
			<-->   -
			<-->      a: 1
			<-->      b: 2
			"""
	)()

# ---------------------------------------------------------------------------

simple.equal 260, tamlStringify({a:"word", b:"blind"}), """
		---
		a: word
		b: blind
		"""
simple.equal 265, stringify({a:"word", b:"blind"}), """
		---
		a: word
		b: blind
		"""

setStringifier(JSON.stringify)

simple.equal 273, stringify({a:"word", b:"blind"}),
		'{"a":"word","b":"blind"}'

setStringifier(tamlStringify)

simple.equal 278, stringify({a:"word", b:"blind"}), """
		---
		a: word
		b: blind
		"""

# ---------------------------------------------------------------------------

(() ->
	lItems = []
	setLogger (item) -> lItems.push(item)
	log 'a'
	log 'b'
	log 'c'
	setLogger()    # reset

	simple.equal 294, lItems, ['a','b','c']
	)()

(() ->
	lItems = []
	setLogger (item) -> lItems.push(item)
	log 'a'
	log 'b'
	log 'c'
	setLogger()    # reset

	simple.equal 305, lItems, ['a','b','c']
	)()

simple.fails 308, () -> error("an error message")

# ---------------------------------------------------------------------------
