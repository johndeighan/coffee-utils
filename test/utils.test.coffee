# utils.test.coffee

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	say, error, warn, isString, isObject, isArray, isHash,
	isEmpty, nonEmpty, isComment, getClassName, isNumber,
	isFunction, isInteger, arrayToString, rtrim,
	normalize, stringToArray, ltrunc, rtrunc,
	words, escapeStr, truncateBlock,
	removeCR, splitBlock, CWS, isArrayOfHashes,
	tamlStringifier, stringify, setStringifier,
	setLogger, log, firstLine, oneline, croak,
	} from '@jdeighan/coffee-utils'

simple = new UnitTester()

# ---------------------------------------------------------------------------

simple.truthy 14, isEmpty('')
simple.truthy 15, isEmpty('  \t\t')
simple.truthy 16, isEmpty([])
simple.truthy 17, isEmpty({})

simple.truthy 19, nonEmpty('a')
simple.truthy 20, nonEmpty('.')
simple.truthy 21, nonEmpty([2])
simple.truthy 22, nonEmpty({width: 2})

simple.truthy 24, isComment("# a comment")
simple.truthy 24, isComment("### a comment")
simple.truthy 25, isComment("#\ta comment")
simple.truthy 25, isComment("###\ta comment")
simple.truthy 26, isComment("   # a comment")
simple.truthy 26, isComment("   ### a comment")
simple.falsy  27, isComment("not much")
simple.falsy  28, isComment("#foreach x in lItems")
simple.truthy 29, isComment('#')
simple.truthy 30, isComment('   #')
simple.truthy 30, isComment('   ###')
simple.falsy  31, isComment('#for')
simple.falsy  32, isComment('   #for')
simple.falsy  33, isComment('#for line in lLines')

# ---------------------------------------------------------------------------

simple.equal 37, normalize("""
			line 1
			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 45, normalize("""
			line 1

			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 54, normalize("""

			line 1

			line 2


			"""), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 77, rtrim("abc"), "abc"
simple.equal 78, rtrim("  abc"), "  abc"
simple.equal 79, rtrim("abc  "), "abc"
simple.equal 80, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

simple.equal 68, words('a b c'), ['a', 'b', 'c']
simple.equal 69, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

simple.equal 73, escapeStr("\t\tXXX\n"), "\\t\\tXXX\\n"

# ---------------------------------------------------------------------------

simple.equal 77, truncateBlock("""
			line 1
			line 2
			line 3
			line 4
			""", 2), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 89, stringToArray("abc\nxyz\n"), [
	'abc'
	'xyz'
	]

# ---------------------------------------------------------------------------

simple.equal 96, stringToArray("abc\nxyz\n\n\n\n"), [
	'abc'
	'xyz'
	]

# ---------------------------------------------------------------------------

simple.equal 112, arrayToString(['a','b','c']), "a\nb\nc\n"

# ---------------------------------------------------------------------------

simple.equal 103, rtrunc('/user/lib/.env', 5), '/user/lib'
simple.equal 104, ltrunc('abcdefg', 3), 'defg'

simple.equal 106, removeCR("abc\r\ndef\r\n"), "abc\ndef\n"
simple.equal 107, splitBlock("""
		abc
		def
		ghi
		"""), ['abc', "def\nghi"]
simple.equal 112, CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

simple.truthy 120, isArrayOfHashes([])
simple.truthy 121, isArrayOfHashes([{}, {}])
simple.truthy 122, isArrayOfHashes([{a: 1, b:2}, {}])
simple.truthy 123, isArrayOfHashes([{a: 1, b:2, c: [1,2,3]}, {}])

simple.falsy  125, isArrayOfHashes({})
simple.falsy  126, isArrayOfHashes([1,2,3])
simple.falsy  127, isArrayOfHashes([{a: 1, b:2, c: [1,2,3]}, 4])
simple.falsy  128, isArrayOfHashes([{a: 1, b:2, c: [1,2,3]}, {}, [1,2]])

# ---------------------------------------------------------------------------

simple.equal 134, tamlStringifier({a:"word", b:"blind"}), """
		---
		a: word
		b: blind
		"""
simple.equal 140, stringify({a:"word", b:"blind"}), """
		---
		a: word
		b: blind
		"""

setStringifier(JSON.stringify)

simple.equal 140, stringify({a:"word", b:"blind"}),
		'{"a":"word","b":"blind"}'

setStringifier(tamlStringifier)

simple.equal 140, stringify({a:"word", b:"blind"}), """
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

	simple.equal 171, lItems, ['a','b','c']
	)()

(() ->
	lItems = []
	setLogger (item) -> lItems.push(item)
	say 'a'
	say 'b'
	say 'c'

	simple.equal 179, lItems, ['a','b','c']

	setLogger console.log
	)()

simple.fails 187, () -> error("an error message")

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

	simple.truthy 203, isHash(h)
	simple.falsy  204, isHash(l)
	simple.falsy  205, isHash(o)
	simple.falsy  206, isHash(n)
	simple.falsy  207, isHash(n2)
	simple.falsy  208, isHash(s)
	simple.falsy  209, isHash(s2)

	simple.falsy  211, isArray(h)
	simple.truthy 212, isArray(l)
	simple.falsy  213, isArray(o)
	simple.falsy  214, isArray(n)
	simple.falsy  215, isArray(n2)
	simple.falsy  216, isArray(s)
	simple.falsy  217, isArray(s2)

	simple.falsy  219, isString(h)
	simple.falsy  220, isString(l)
	simple.falsy  221, isString(o)
	simple.falsy  222, isString(n)
	simple.falsy  223, isString(n2)
	simple.truthy 224, isString(s)
	simple.truthy 225, isString(s2)

	simple.falsy  227, isObject(h)
	simple.falsy  228, isObject(l)
	simple.truthy 229, isObject(o)
	simple.falsy  230, isObject(n)
	simple.falsy  231, isObject(n2)
	simple.falsy  232, isObject(s)
	simple.falsy  233, isObject(s2)

	simple.falsy  235, isNumber(h)
	simple.falsy  236, isNumber(l)
	simple.falsy  237, isNumber(o)
	simple.truthy 238, isNumber(n)
	simple.truthy 239, isNumber(n2)
	simple.falsy  240, isNumber(s)
	simple.falsy  241, isNumber(s2)

	)()

# ---------------------------------------------------------------------------

simple.truthy 248, isFunction(() -> pass)
simple.falsy  249, isFunction(23)

simple.truthy 251, isInteger(42)
simple.truthy 252, isInteger(new Number(42))
simple.falsy  253, isInteger('abc')
simple.falsy  253, isInteger({})
simple.falsy  253, isInteger([])

# ---------------------------------------------------------------------------

simple.equal 259, firstLine("""
		#starbucks
		do this
		do that
		"""), '#starbucks'

# ---------------------------------------------------------------------------

simple.equal 278, oneline("\t\tabc"), "\\t\\tabc"
simple.equal 279, oneline("\t\tabc\nxyz"), "\\t\\tabc\\nxyz"
simple.equal 280, oneline({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

simple.equal 284, CWS("""
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
	simple.equal 298, arrayToString(lLines), """
			ERROR: bad stuff
			============== An Object ===============
			---
				a: 1
				b: 2
			"""
	)()
