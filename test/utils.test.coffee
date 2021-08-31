# utils.test.coffee

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	normalize, stringToArray, isEmpty, ltrunc, rtrunc,
	nonEmpty, isComment, words, escapeStr, truncateBlock,
	removeCR, splitBlock, CWS, isArrayOfHashes,
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
simple.truthy 25, isComment("#\ta comment")
simple.truthy 26, isComment("   # a comment")
simple.falsy  27, isComment("not much")
simple.falsy  28, isComment("#foreach x in lItems")
simple.truthy 29, isComment('#')
simple.truthy 30, isComment('   #')
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
