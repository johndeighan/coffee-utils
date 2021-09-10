# utils.test.coffee

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	say, undef, error, warn, isString, isObject, isArray, isHash,
	isEmpty, nonEmpty, isComment, getClassName, isNumber,
	isFunction, isInteger, arrayToString, rtrim,
	normalize, stringToArray, ltrunc, rtrunc,
	words, escapeStr, truncateBlock, titleLine,
	removeCR, splitBlock, CWS, isArrayOfHashes,
	tamlStringifier, stringify, setStringifier,
	setLogger, log, firstLine, oneline, croak,
	} from '@jdeighan/coffee-utils'

simple = new UnitTester()

# ---------------------------------------------------------------------------

simple.truthy 19, isEmpty('')
simple.truthy 20, isEmpty('  \t\t')
simple.truthy 21, isEmpty([])
simple.truthy 22, isEmpty({})

simple.truthy 24, nonEmpty('a')
simple.truthy 25, nonEmpty('.')
simple.truthy 26, nonEmpty([2])
simple.truthy 27, nonEmpty({width: 2})

simple.truthy 29, isComment("# a comment")
simple.truthy 30, isComment("### a comment")
simple.truthy 31, isComment("#\ta comment")
simple.truthy 32, isComment("###\ta comment")
simple.truthy 33, isComment("   # a comment")
simple.truthy 34, isComment("   ### a comment")
simple.falsy  35, isComment("not much")
simple.falsy  36, isComment("#foreach x in lItems")
simple.truthy 37, isComment('#')
simple.truthy 38, isComment('   #')
simple.truthy 39, isComment('   ###')
simple.falsy  40, isComment('#for')
simple.falsy  41, isComment('   #for')
simple.falsy  42, isComment('#for line in lLines')

simple.equal  44, titleLine('a thing').length, 42
simple.equal  45, titleLine('a thing','-',5,90).length, 90

# ---------------------------------------------------------------------------

simple.equal 49, normalize("""
			line 1
			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 57, normalize("""
			line 1

			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 66, normalize("""

			line 1

			line 2


			"""), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 80, rtrim("abc"), "abc"
simple.equal 81, rtrim("  abc"), "  abc"
simple.equal 82, rtrim("abc  "), "abc"
simple.equal 83, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

simple.equal 87, words('a b c'), ['a', 'b', 'c']
simple.equal 88, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

simple.equal 92, escapeStr("\t\tXXX\n"), "\\t\\tXXX\\n"

# ---------------------------------------------------------------------------

simple.equal 96, truncateBlock("""
			line 1
			line 2
			line 3
			line 4
			""", 2), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 108, stringToArray("abc\nxyz\n"), [
	'abc'
	'xyz'
	]

simple.equal 113, stringToArray("abc\nxyz\n\n\n\n"), [
	'abc'
	'xyz'
	]

simple.equal 118, stringToArray("abc\n\nxyz\n"), [
	'abc'
	''
	'xyz'
	]

# ---------------------------------------------------------------------------

simple.equal 126, arrayToString(['a','b','c']), "a\nb\nc\n"

# ---------------------------------------------------------------------------

simple.equal 130, rtrunc('/user/lib/.env', 5), '/user/lib'
simple.equal 131, ltrunc('abcdefg', 3), 'defg'

simple.equal 133, removeCR("abc\r\ndef\r\n"), "abc\ndef\n"
simple.equal 134, splitBlock("""
		abc
		def
		ghi
		"""), ['abc', "def\nghi"]
simple.equal 139, CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

simple.truthy 147, isArrayOfHashes([])
simple.truthy 148, isArrayOfHashes([{}, {}])
simple.truthy 149, isArrayOfHashes([{a: 1, b:2}, {}])
simple.truthy 150, isArrayOfHashes([{a: 1, b:2, c: [1,2,3]}, {}])

simple.falsy  152, isArrayOfHashes({})
simple.falsy  153, isArrayOfHashes([1,2,3])
simple.falsy  154, isArrayOfHashes([{a: 1, b:2, c: [1,2,3]}, 4])
simple.falsy  155, isArrayOfHashes([{a: 1, b:2, c: [1,2,3]}, {}, [1,2]])

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

(() ->
	class NewClass

	h = {a:1, b:2}
	l = [1,2,2]
	o = new NewClass()
	n = 42
	n2 = new Number(42)
	s = 'simple'
	s2 = new String('abc')

	simple.truthy 222, isHash(h)
	simple.falsy  223, isHash(l)
	simple.falsy  224, isHash(o)
	simple.falsy  225, isHash(n)
	simple.falsy  226, isHash(n2)
	simple.falsy  227, isHash(s)
	simple.falsy  228, isHash(s2)

	simple.falsy  230, isArray(h)
	simple.truthy 231, isArray(l)
	simple.falsy  232, isArray(o)
	simple.falsy  233, isArray(n)
	simple.falsy  234, isArray(n2)
	simple.falsy  235, isArray(s)
	simple.falsy  236, isArray(s2)

	simple.falsy  238, isString(h)
	simple.falsy  239, isString(l)
	simple.falsy  240, isString(o)
	simple.falsy  241, isString(n)
	simple.falsy  242, isString(n2)
	simple.truthy 243, isString(s)
	simple.truthy 244, isString(s2)

	simple.falsy  246, isObject(h)
	simple.falsy  247, isObject(l)
	simple.truthy 248, isObject(o)
	simple.falsy  249, isObject(n)
	simple.falsy  250, isObject(n2)
	simple.falsy  251, isObject(s)
	simple.falsy  252, isObject(s2)

	simple.falsy  254, isNumber(h)
	simple.falsy  255, isNumber(l)
	simple.falsy  256, isNumber(o)
	simple.truthy 257, isNumber(n)
	simple.truthy 258, isNumber(n2)
	simple.falsy  259, isNumber(s)
	simple.falsy  260, isNumber(s2)

	)()

# ---------------------------------------------------------------------------

simple.truthy 266, isFunction(() -> pass)
simple.falsy  267, isFunction(23)

simple.truthy 269, isInteger(42)
simple.truthy 270, isInteger(new Number(42))
simple.falsy  271, isInteger('abc')
simple.falsy  272, isInteger({})
simple.falsy  273, isInteger([])

# ---------------------------------------------------------------------------

simple.equal 277, firstLine("""
		#starbucks
		do this
		do that
		"""), '#starbucks'

# ---------------------------------------------------------------------------

simple.equal 285, oneline(undef), "undef"
simple.equal 286, oneline("\t\tabc\nxyz"), "'\\t\\tabc\\nxyz'"
simple.equal 287, oneline({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

simple.equal 291, CWS("""
		a simple
		error message
		"""), "a simple error message"

# ---------------------------------------------------------------------------
# test croak()

(() ->
	lLines = []
	setLogger (line) -> lLines.push(line)

	obj = {a:1, b:2}
	try
		croak "bad stuff", obj, "An Object"
	simple.equal 306, arrayToString(lLines), """
			ERROR: bad stuff
			==============  An Object  ===============
			---
				a: 1
				b: 2
			==========================================
			"""
	setLogger()
	)()
