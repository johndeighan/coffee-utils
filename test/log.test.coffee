# log.test.coffee

import {undef, arrayToString} from '@jdeighan/coffee-utils'
import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	stringify, setStringifier, log, setLogger, tamlStringifier,
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
	tester.equal 28, lLines, """
			enter myfunc
			"""
	)()

# ---------------------------------------------------------------------------

(() ->
	lLines = []
	log 'abc'
	log 'def'
	log 'ghi'
	tester.equal 40, lLines, """
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
	tester.equal 54, lLines, """
			abc
			name = undef
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', 42
	tester.equal 64, lLines, """
			abc
			name = 42
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', 'John'
	tester.equal 74, lLines, """
			abc
			name = 'John'
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', {a: 1, b: 'xyz'}
	tester.equal 84, lLines, """
			abc
			name = {"a":1,"b":"xyz"}
			"""
	)()

(() ->
	lLines = []
	log 'abc'
	log 'name', ['a', 42, [1,2]]
	tester.equal 94, lLines, """
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
	tester.equal 111, lLines, """
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
	tester.equal 129, lLines, """
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
	tester.equal 148, lLines, """
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
	log 'name', undef, '<-->'
	tester.equal 166, lLines, """
			<-->name = undef
			"""
	)()

(() ->
	lLines = []
	log 'name', 42, '<-->'
	tester.equal 174, lLines, """
			<-->name = 42
			"""
	)()

(() ->
	lLines = []
	log 'name', 'John', '<-->'
	tester.equal 182, lLines, """
			<-->name = 'John'
			"""
	)()

(() ->
	lLines = []
	log 'name', {a: 1, b: 'xyz'}, '<-->'
	tester.equal 190, lLines, """
			<-->name = {"a":1,"b":"xyz"}
			"""
	)()

(() ->
	lLines = []
	log 'name', ['a', 42, [1,2]], '<-->'
	tester.equal 198, lLines, """
			<-->name = ["a",42,[1,2]]
			"""
	)()

(() ->
	lLines = []
	log 'name', """
			This is a rather long bit of
			text which changes
			how it's displayed
			""", '<-->'
	tester.equal 210, lLines, """
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
		}, '<-->'
	tester.equal 226, lLines, """
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
		], '<-->'
	tester.equal 243, lLines, """
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

simple.equal 159, tamlStringifier({a:"word", b:"blind"}), """
		---
		a: word
		b: blind
		"""
simple.equal 164, stringify({a:"word", b:"blind"}), """
		---
		a: word
		b: blind
		"""

setStringifier(JSON.stringify)

simple.equal 172, stringify({a:"word", b:"blind"}),
		'{"a":"word","b":"blind"}'

setStringifier(tamlStringifier)

simple.equal 177, stringify({a:"word", b:"blind"}), """
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

	simple.equal 193, lItems, ['a','b','c']
	)()

(() ->
	lItems = []
	setLogger (item) -> lItems.push(item)
	say 'a'
	say 'b'
	say 'c'
	setLogger()    # reset

	simple.equal 204, lItems, ['a','b','c']
	)()

simple.fails 207, () -> error("an error message")

# ---------------------------------------------------------------------------
