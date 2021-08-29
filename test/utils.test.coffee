# utils.test.coffee

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	normalize, stringToArray, isEmpty, ltrunc, rtrunc,
	nonEmpty, isComment, words, escapeStr, truncateBlock,
	} from '@jdeighan/coffee-utils'

simple = new UnitTester()

# ---------------------------------------------------------------------------

simple.truthy 13, isEmpty('')
simple.truthy 14, isEmpty('  \t\t')
simple.truthy 15, isEmpty([])
simple.truthy 16, isEmpty({})

simple.truthy 18, nonEmpty('a')
simple.truthy 10, nonEmpty('.')
simple.truthy 20, nonEmpty([2])
simple.truthy 21, nonEmpty({width: 2})

simple.truthy 23, isComment("# a comment")
simple.truthy 24, isComment("#\ta comment")
simple.truthy 25, isComment("   # a comment")
simple.falsy  26, isComment("not much")
simple.falsy  27, isComment("#foreach x in lItems")
simple.truthy 28, isComment('#')
simple.truthy 29, isComment('   #')
simple.falsy  30, isComment('#for')
simple.falsy  31, isComment('   #for')
simple.falsy  32, isComment('#for line in lLines')

# ---------------------------------------------------------------------------

simple.equal 40, normalize("""
			line 1
			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 48, normalize("""
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

# ---------------------------------------------------------------------------

simple.equal 71, words('a b c'), ['a', 'b', 'c']
simple.equal 72, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

simple.equal 76, escapeStr("\t\tXXX\n"), "\\t\\tXXX\\n"

# ---------------------------------------------------------------------------

simple.equal 80, truncateBlock("""
			line 1
			line 2
			line 3
			line 4
			""", 2), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 92, stringToArray("abc\nxyz\n"), [
	'abc'
	'xyz'
	]

# ---------------------------------------------------------------------------

simple.equal 99, stringToArray("abc\nxyz\n\n\n\n"), [
	'abc'
	'xyz'
	]

# ---------------------------------------------------------------------------

simple.equal 106, rtrunc('/user/lib/.env', 5), '/user/lib'
simple.equal 107, ltrunc('abcdefg', 3), 'defg'
