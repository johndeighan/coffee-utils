# heredoc.test.coffee

import {AvaTester} from '@jdeighan/ava-tester'
import {
	numHereDocs, patch, build,
	} from '@jdeighan/coffee-utils/heredoc'

tester = new AvaTester()

# ---------------------------------------------------------------------------

tester.equal 12, numHereDocs("where <<"), 0
tester.equal 13, numHereDocs("where <<<"), 1
tester.equal 14, numHereDocs("where <<< is <<<"), 2
tester.equal 15, numHereDocs("where <<< is <<< or <<<"), 3
tester.equal 16, numHereDocs("<<< <<< <<<"), 3
tester.equal 17, numHereDocs("<<<<<<<<<"), 3

# ---------------------------------------------------------------------------
# --- without evaluation

tester.equal 22, patch("let x = <<<;", [[
				'a multi',
				'line string',
				]]),
		"let x = a multi line string;"

# ---------------------------------------------------------------------------
# --- with evaluation

tester.equal 31, patch("let x = <<<;", [[
				'a multi',
				'line string',
				]], true),
		'let x = "a multi\\nline string";'

tester.equal 37, patch("let x = <<<;", [[
				'---',
				'\t- one string',
				'\t- another string',
				]], true),
		'let x = ["one string","another string"];'

# ---------------------------------------------------------------------------

tester.equal 46, build([
				'a multi',
				'line string',
				], true),
		"a multi\nline string\n"

# ---------------------------------------------------------------------------

tester.equal 54, build([
				'\t\ta multi',
				'\t\tline string',
				], true),
		"a multi\nline string\n"

# ---------------------------------------------------------------------------

tester.equal 62, patch("let x = <<<; let y = <<<;", [[
				'\t\ta multi',
				'\t\tline string',
				],[
				'\ta new',
				'\tstring',
				]], true),
		"let x = \"a multi\\nline string\"; let y = \"a new\\nstring\";"

# ---------------------------------------------------------------------------

tester.equal 73, build(undefined), ''
tester.equal 74, build(null), ''
tester.equal 75, build([]), ''

# --- build standard HEREDOC

tester.equal 79, build([
			'first line',
			'second line',
			]),
		"first line\nsecond line\n"

# --- TAML

tester.equal 87,
		build(['---', '- first', '- second']),
		['first', 'second']

tester.equal 91,
		build(['---', 'key: first', 'value: second']),
		{key: "first", value: "second"}


# ---------------------------------------------------------------------------

tester.equal 98,
		patch("let lItems = <<<;", [[
			'---',
			'- one',
			'- two',
			]], true),
		'let lItems = ["one","two"];'

# ---------------------------------------------------------------------------

tester.equal 108,
		patch("let lItems = <<<;", [[
			'---',
			'key: one',
			'value: two',
			]], true),
		'let lItems = {"key":"one","value":"two"};'
