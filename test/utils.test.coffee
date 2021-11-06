import {pass} from '@jdeighan/coffee-utils'
# utils.test.cielo

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	say, undef, error, warn, isString, isObject, isArray, isHash,
	isEmpty, nonEmpty, isComment, getClassName, isNumber,
	isFunction, isInteger, rtrim,
	ltrunc, rtrunc, extractMatches,
	words, escapeStr, titleLine,
	removeCR, CWS, isArrayOfHashes,
	oneline, croak, isRegExp,
	} from '@jdeighan/coffee-utils'
import {setLogger} from '@jdeighan/coffee-utils/log'
import {setDebugging} from '@jdeighan/coffee-utils/debug'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'

simple = new UnitTester()

# ---------------------------------------------------------------------------

simple.truthy 21, isEmpty('')
simple.truthy 22, isEmpty('  \t\t')
simple.truthy 23, isEmpty([])
simple.truthy 24, isEmpty({})

simple.truthy 26, nonEmpty('a')
simple.truthy 27, nonEmpty('.')
simple.truthy 28, nonEmpty([2])
simple.truthy 29, nonEmpty({width: 2})

simple.truthy 31, isComment("# a comment")
simple.truthy 32, isComment("### a comment")
simple.truthy 33, isComment("#\ta comment")
simple.truthy 34, isComment("###\ta comment")
simple.truthy 35, isComment("   # a comment")
simple.truthy 36, isComment("   ### a comment")
simple.falsy  37, isComment("not much")
simple.falsy  38, isComment("#foreach x in lItems")
simple.truthy 39, isComment('#')
simple.truthy 40, isComment('   #')
simple.truthy 41, isComment('   ###')
simple.falsy  42, isComment('#for')
simple.falsy  43, isComment('   #for')
simple.falsy  44, isComment('#for line in lLines')

simple.equal  46, titleLine('a thing').length, 42
simple.equal  47, titleLine('a thing','-',5,90).length, 90

# ---------------------------------------------------------------------------

simple.equal 51, rtrim("abc"), "abc"
simple.equal 52, rtrim("  abc"), "  abc"
simple.equal 53, rtrim("abc  "), "abc"
simple.equal 54, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

simple.equal 58, words('a b c'), ['a', 'b', 'c']
simple.equal 59, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

simple.equal 63, escapeStr("\t\tXXX\n"), "\\t\\tXXX\\n"
hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}
simple.equal 69, escapeStr("\thas quote: \"\nnext line", hEsc), \
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

simple.equal 74, rtrunc('/user/lib/.env', 5), '/user/lib'
simple.equal 75, ltrunc('abcdefg', 3), 'defg'

simple.equal 77, removeCR("abc\r\ndef\r\n"), "abc\ndef\n"
simple.equal 78, CWS(""" abc def ghi """), "abc def ghi"

# ---------------------------------------------------------------------------

simple.truthy 86, isArrayOfHashes([])
simple.truthy 87, isArrayOfHashes([{}, {}])
simple.truthy 88, isArrayOfHashes([{a: 1, b:2}, {}])
simple.truthy 89, isArrayOfHashes([{a: 1, b:2, c: [1,2,3]}, {}])

simple.falsy  91, isArrayOfHashes({})
simple.falsy  92, isArrayOfHashes([1,2,3])
simple.falsy  93, isArrayOfHashes([{a: 1, b:2, c: [1,2,3]}, 4])
simple.falsy  94, isArrayOfHashes([{a: 1, b:2, c: [1,2,3]}, {}, [1,2]])

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

	simple.truthy 109, isHash(h)
	simple.falsy  110, isHash(l)
	simple.falsy  111, isHash(o)
	simple.falsy  112, isHash(n)
	simple.falsy  113, isHash(n2)
	simple.falsy  114, isHash(s)
	simple.falsy  115, isHash(s2)

	simple.falsy  117, isArray(h)
	simple.truthy 118, isArray(l)
	simple.falsy  119, isArray(o)
	simple.falsy  120, isArray(n)
	simple.falsy  121, isArray(n2)
	simple.falsy  122, isArray(s)
	simple.falsy  123, isArray(s2)

	simple.falsy  125, isString(h)
	simple.falsy  126, isString(l)
	simple.falsy  127, isString(o)
	simple.falsy  128, isString(n)
	simple.falsy  129, isString(n2)
	simple.truthy 130, isString(s)
	simple.truthy 131, isString(s2)

	simple.falsy  133, isObject(h)
	simple.falsy  134, isObject(l)
	simple.truthy 135, isObject(o)
	simple.falsy  136, isObject(n)
	simple.falsy  137, isObject(n2)
	simple.falsy  138, isObject(s)
	simple.falsy  139, isObject(s2)

	simple.falsy  141, isNumber(h)
	simple.falsy  142, isNumber(l)
	simple.falsy  143, isNumber(o)
	simple.truthy 144, isNumber(n)
	simple.truthy 145, isNumber(n2)
	simple.falsy  146, isNumber(s)
	simple.falsy  147, isNumber(s2)

	)()

# ---------------------------------------------------------------------------

simple.truthy 153, isFunction(() -> pass)
simple.falsy  154, isFunction(23)

simple.truthy 156, isInteger(42)
simple.truthy 157, isInteger(new Number(42))
simple.falsy  158, isInteger('abc')
simple.falsy  159, isInteger({})
simple.falsy  160, isInteger([])

# ---------------------------------------------------------------------------

simple.equal 164, oneline(undef), "undef"
simple.equal 165, oneline("\t\tabc\nxyz"), "'\\t\\tabc\\nxyz'"
simple.equal 166, oneline({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

simple.equal 170, CWS(""" a simple error message """), "a simple error message"

# ---------------------------------------------------------------------------
# test croak()

(() ->
	lLines = []
	setLogger (line) -> lLines.push(line)

	obj = {a:1, b:2}
	try
		croak "bad stuff", "An Object", obj
	simple.equal 185, arrayToBlock(lLines), """
		ERROR: bad stuff
		An Object = {"a":1,"b":2}
		"""
	setLogger()
	)()

# ---------------------------------------------------------------------------
# test isRegExp()

simple.truthy 195, isRegExp(/^abc$/)
simple.truthy 196, isRegExp(///^ \s* where \s+ areyou $///)
simple.falsy  202, isRegExp(42)
simple.falsy  203, isRegExp('abc')
simple.falsy  204, isRegExp([1,'a'])
simple.falsy  205, isRegExp({a:1, b:'ccc'})
simple.falsy  206, isRegExp(undef)

simple.truthy 208, isRegExp(/\.coffee/)

# ---------------------------------------------------------------------------

simple.equal 212, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt),
	[3, 4, 5]
simple.equal 214, extractMatches("And This Is A String", /A/g), ['A','A']
