# log.test.coffee

import {undef} from '@jdeighan/coffee-utils'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'
import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	stringify, setStringifier, log, setLogger, tamlStringify,
	} from '@jdeighan/coffee-utils/log'

simple = new UnitTester()

# ---------------------------------------------------------------------------

class LogTester extends UnitTester

	transformValue: (lLines) ->
		return arrayToBlock(lLines)
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
	tester.equal 33, lLines, """
			enter myfunc
			"""
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	log 'abc'
	log 'def'
	log 'ghi'
	tester.equal 45, lLines, """
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
	tester.equal 59, lLines, """
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
	tester.equal 79, lLines, """
			abc
			name = 'John'
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', {a: 1, b: 'xyz'}
	tester.equal 89, lLines, """
			abc
			name = {"a":1,"b":"xyz"}
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', ['a', 42, [1,2]]
	tester.equal 99, lLines, """
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
	tester.equal 116, lLines, """
			abc
			name:
			==========================================
			This is a rather long bit of
			text which changes
			how it's displayed
			==========================================
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
	tester.equal 134, lLines, """
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
	tester.equal 153, lLines, """
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
	tester.equal 171, lLines, """
			<-->name = undef
			"""
	)()

(() ->
	lLines = []
	log 'name', 42, {prefix: '<-->', logItem: true}
	tester.equal 179, lLines, """
			<-->name = 42
			"""
	)()

(() ->
	lLines = []
	log 'name', 'John', {prefix: '<-->', logItem: true}
	tester.equal 187, lLines, """
			<-->name = 'John'
			"""
	)()

(() ->
	lLines = []
	log 'name', {a: 1, b: 'xyz'}, {prefix: '<-->', logItem: true}
	tester.equal 195, lLines, """
			<-->name = {"a":1,"b":"xyz"}
			"""
	)()

(() ->
	lLines = []
	log 'name', ['a', 42, [1,2]], {prefix: '<-->', logItem: true}
	tester.equal 203, lLines, """
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
	tester.equal 215, lLines, """
			<-->name:
			==========================================
			This is a rather long bit of
			text which changes
			how it's displayed
			==========================================
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
	tester.equal 231, lLines, """
			<-->name:
			   ---
			   fname: John
			   lname: Deighan
			   age: 68
			   home: Blacksburg, VA
			"""
	)()

(() ->
	lLines = []
	log 'name', [
		68,
		'a rather long string of text',
		{a:1, b:2}
		], {prefix: '<-->', logItem: true}
	tester.equal 248, lLines, """
			<-->name:
			   ---
			   - 68
			   - a rather long string of text
			   -
			      a: 1
			      b: 2
			"""
	)()

# ---------------------------------------------------------------------------

simple.equal 261, tamlStringify({a:"word", b:"blind"}), """
		---
		a: word
		b: blind
		"""
simple.equal 266, stringify({a:"word", b:"blind"}), """
		---
		a: word
		b: blind
		"""

setStringifier(JSON.stringify)

simple.equal 274, stringify({a:"word", b:"blind"}),
		'{"a":"word","b":"blind"}'

setStringifier(tamlStringify)

simple.equal 279, stringify({a:"word", b:"blind"}), """
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

	simple.equal 295, lItems, ['a','b','c']
	)()

(() ->
	lItems = []
	setLogger (item) -> lItems.push(item)
	log 'a'
	log 'b'
	log 'c'
	setLogger()    # reset

	simple.equal 306, lItems, ['a','b','c']
	)()

simple.fails 309, () -> error("an error message")

# ---------------------------------------------------------------------------
