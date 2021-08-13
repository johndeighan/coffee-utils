# heredoc.test.coffee

import {AvaTester} from '@jdeighan/ava-tester'
import {numHereDocs, patch, build} from '@jdeighan/coffee-utils/heredoc'

tester = new AvaTester()

# ---------------------------------------------------------------------------

tester.equal 10, numHereDocs("where <<"), 0
tester.equal 11, numHereDocs("where <<<"), 1
tester.equal 12, numHereDocs("where <<< is <<<"), 2
tester.equal 13, numHereDocs("where <<< is <<< or <<<"), 3
tester.equal 14, numHereDocs("<<< <<< <<<"), 3
tester.equal 15, numHereDocs("<<<<<<<<<"), 3

# ---------------------------------------------------------------------------

tester.equal 19, build([
				'a multi',
				'line string',
				]),
		"a multi\nline string\n"

# ---------------------------------------------------------------------------

tester.equal 27, patch("let x = <<<;", [[
				'a multi',
				'line string',
				]]),
		"let x = \"a multi\\nline string\\n\";"


# ---------------------------------------------------------------------------

tester.equal 36, build([
				'\t\ta multi',
				'\t\tline string',
				]),
		"a multi\nline string\n"

# ---------------------------------------------------------------------------

tester.equal 44, patch("let x = <<<; let y = <<<;", [[
				'\t\ta multi',
				'\t\tline string',
				],[
				'\ta new',
				'\tstring',
				]]),
		"let x = \"a multi\\nline string\\n\"; let y = \"a new\\nstring\\n\";"

# ---------------------------------------------------------------------------

tester.equal 55, build(undefined), ''
tester.equal 56, build(null), ''
tester.equal 57, build([]), ''

# --- build standard HEREDOC

tester.equal 61, build([
			'first line',
			'second line',
			]),
		"first line\nsecond line\n"

# --- TAML

tester.equal 69,
		build(['---', '- first', '- second']),
		['first', 'second']

tester.equal 73,
		build(['---', 'key: first', 'value: second']),
		{key: "first", value: "second"}


# ---------------------------------------------------------------------------

tester.equal 79,
		patch("let lItems = <<<;", [[
			'---',
			'- one',
			'- two',
			]]),
		'let lItems = ["one","two"];'

# ---------------------------------------------------------------------------

tester.equal 89,
		patch("let lItems = <<<;", [[
			'---',
			'key: one',
			'value: two',
			]]),
		'let lItems = {"key":"one","value":"two"};'

# ---------------------------------------------------------------------------
# test providing a callback to patch()

tester.equal 89,
		patch("let lItems = <<<;", [[
			'---',
			'key: one',
			'value: two',
			]], (lLines) -> return 'xxx'),
		'let lItems = xxx;'

# ---------------------------------------------------------------------------
# test providing a callback to patch()

(() ->
	converter = (lLines) ->

		count = lLines.length
		return "#{count} lines"

	tester.equal 89,
			patch("let lItems = <<<;", [[
				'---',
				'key: one',
				'value: two',
				]], converter),
			'let lItems = 3 lines;'
	)()
