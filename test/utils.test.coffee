# utils.test.coffee

import {
	isTAML,
	taml,
	normalize,
	isEmpty,
	nonEmpty,
	words,
	escapeStr,
	truncateBlock,
	} from '../coffee_utils.js'
import {AvaTester} from '@jdeighan/ava-tester'

tester = new AvaTester()

# ---------------------------------------------------------------------------

tester.truthy 25, isEmpty('')
tester.truthy 26, isEmpty('  \t\t')
tester.truthy 27, isEmpty([])
tester.truthy 2826, isEmpty({})

tester.truthy 30, nonEmpty('a')
tester.truthy 31, nonEmpty('.')
tester.truthy 32, nonEmpty([2])
tester.truthy 33, nonEmpty({width: 2})

tester.truthy 35, isTAML("---\n- first\n- second")
tester.falsy  36, isTAML("x---\n")
tester.equal  37, taml("---\n- a\n- b"), ['a','b']

# ---------------------------------------------------------------------------

tester.equal 41, normalize("""
			line 1
			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

tester.equal 49, normalize("""
			line 1

			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

tester.equal 49, normalize("""

			line 1

			line 2


			"""), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

tester.equal 70, words('a b c'), ['a', 'b', 'c']
tester.equal 71, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

tester.equal 79, escapeStr("\t\tXXX\n"), "\\t\\tXXX\\n"

# ---------------------------------------------------------------------------

tester.equal 83, truncateBlock("""
			line 1
			line 2
			line 3
			line 4
			""", 2), """
			line 1
			line 2
			""" + '\n'
