# utils.test.coffee

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	say, undef, error, warn, isString, isObject, isArray, isHash,
	isEmpty, nonEmpty, isComment, getClassName, isNumber,
	isFunction, isInteger, rtrim,
	ltrunc, rtrunc,
	words, escapeStr, titleLine,
	removeCR, splitBlock, CWS, isArrayOfHashes,
	firstLine, oneline, croak, isRegExp,
	} from '@jdeighan/coffee-utils'
import {setLogger} from '@jdeighan/coffee-utils/log'
import {setDebugging} from '@jdeighan/coffee-utils/debug'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'

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

(() ->
	class NewClass

	h = {a:1, b:2}
	l = [1,2,2]
	o = new NewClass()
	n = 42
	n2 = new Number(42)
	s = 'simple'
	s2 = new String('abc')

	simple.truthy 170, isHash(h)
	simple.falsy  171, isHash(l)
	simple.falsy  172, isHash(o)
	simple.falsy  173, isHash(n)
	simple.falsy  174, isHash(n2)
	simple.falsy  175, isHash(s)
	simple.falsy  176, isHash(s2)

	simple.falsy  178, isArray(h)
	simple.truthy 179, isArray(l)
	simple.falsy  180, isArray(o)
	simple.falsy  181, isArray(n)
	simple.falsy  182, isArray(n2)
	simple.falsy  183, isArray(s)
	simple.falsy  184, isArray(s2)

	simple.falsy  186, isString(h)
	simple.falsy  187, isString(l)
	simple.falsy  188, isString(o)
	simple.falsy  189, isString(n)
	simple.falsy  190, isString(n2)
	simple.truthy 191, isString(s)
	simple.truthy 192, isString(s2)

	simple.falsy  194, isObject(h)
	simple.falsy  195, isObject(l)
	simple.truthy 196, isObject(o)
	simple.falsy  197, isObject(n)
	simple.falsy  198, isObject(n2)
	simple.falsy  199, isObject(s)
	simple.falsy  200, isObject(s2)

	simple.falsy  202, isNumber(h)
	simple.falsy  203, isNumber(l)
	simple.falsy  204, isNumber(o)
	simple.truthy 205, isNumber(n)
	simple.truthy 206, isNumber(n2)
	simple.falsy  207, isNumber(s)
	simple.falsy  208, isNumber(s2)

	)()

# ---------------------------------------------------------------------------

simple.truthy 214, isFunction(() -> pass)
simple.falsy  215, isFunction(23)

simple.truthy 217, isInteger(42)
simple.truthy 218, isInteger(new Number(42))
simple.falsy  219, isInteger('abc')
simple.falsy  220, isInteger({})
simple.falsy  221, isInteger([])

# ---------------------------------------------------------------------------

simple.equal 225, firstLine("""
		#starbucks
		do this
		do that
		"""), '#starbucks'

# ---------------------------------------------------------------------------

simple.equal 233, oneline(undef), "undef"
simple.equal 234, oneline("\t\tabc\nxyz"), "'\\t\\tabc\\nxyz'"
simple.equal 235, oneline({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

simple.equal 239, CWS("""
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
		croak "bad stuff", "An Object", obj
	simple.equal 255, arrayToBlock(lLines), """
			ERROR: bad stuff
			An Object = {"a":1,"b":2}
			"""
	setLogger()
	)()

# ---------------------------------------------------------------------------
# test isRegExp()

simple.truthy 265, isRegExp(/^abc$/)
simple.truthy 266, isRegExp(///^
		\s*
		where
		\s+
		areyou
		$///)
simple.falsy  272, isRegExp(42)
simple.falsy  272, isRegExp('abc')
simple.falsy  272, isRegExp([1,'a'])
simple.falsy  272, isRegExp({a:1, b:'ccc'})
simple.falsy  272, isRegExp(undef)

simple.truthy 278, isRegExp(/\.coffee/)
