# convert.test.coffee

import {AvaTester} from '@jdeighan/ava-tester'
import {
	say,
	undef,
	setUnitTesting,
	unitTesting,
	} from '@jdeighan/coffee-utils'
import {mydir} from '@jdeighan/coffee-utils/fs'
import {
	brewCoffee,
	brewExpr,
	markdownify,
	sassify,
	getFileContents,
	} from '@jdeighan/coffee-utils/convert'

setUnitTesting(true)
dir = mydir(`import.meta.url`)
process.env.DIR_DATA = "#{dir}/data"
process.env.DIR_MARKDOWN = "#{dir}/markdown"
simple = new AvaTester()

# ---------------------------------------------------------------------------

class MarkdownTester extends AvaTester

	transformValue: (text) ->

		# --- temporarily turn off unit testing so markdownify works
		setUnitTesting(false)
		html = markdownify(text)
		setUnitTesting(true)
		return html

# ---------------------------------------------------------------------------

(() ->
	tester = new MarkdownTester()

	tester.equal 42, """
			# title
			""", """
			<h1>title</h1>
			"""

	tester.equal 48, """
		this is **bold** text
		""", """
		<p>this is <strong>bold</strong> text</p>
		"""

	setUnitTesting(false)

	tester.equal 56, """
		```javascript
				adapter: adapter({
					pages: 'build',
					assets: 'build',
					fallback: null,
					})
		```
		""", """
		<pre><code class="language-javascript"> adapter: adapter(&lbrace;
		pages: &#39;build&#39;,
		assets: &#39;build&#39;,
		fallback: null,
		&rbrace;)
		</code></pre>
		"""

	setUnitTesting(true)
	)()

# ---------------------------------------------------------------------------

class CoffeeTester extends AvaTester

	transformValue: (text) ->

		# --- temporarily turn off unit testing so brewCoffee works
		setUnitTesting(false)
		js = brewCoffee(text)
		setUnitTesting(true)
		return js

# ---------------------------------------------------------------------------

(() ->

	tester = new CoffeeTester()

	tester.equal 94, """
			x = 23
			""", """
			var x;
			x = 23;
			"""

	)()

# ---------------------------------------------------------------------------

class SassTester extends AvaTester

	transformValue: (text) ->

		# --- temporarily turn off unit testing so sassify works
		setUnitTesting(false)
		css = sassify(text)
		setUnitTesting(true)
		return css

# ---------------------------------------------------------------------------

(() ->

	tester = new SassTester()

	tester.equal 121, """
	p
		margin: 0
		span
			color: red
	""", """
	p {
		margin: 0;
	}
	p span {
		color: red;
	}
	"""
	)()

# ---------------------------------------------------------------------------
# --- test getFileContents without conversion

setUnitTesting(false)

simple.equal 141, getFileContents('file.md'), """
		title
		=====

		subtitle
		--------

		"""

simple.equal 150, getFileContents('file.taml'), """
		---
		-
			first: 1
			second: 2
		-
			kind: cmd
			cmd: include

		"""

simple.equal 161, getFileContents('file.txt'), """
		abc
		def

		"""

setUnitTesting(true)

# ---------------------------------------------------------------------------
# --- test getFileContents with conversion

setUnitTesting(false)

simple.equal 141, getFileContents('file.md', true), """
		<h1>title</h1>
		<h2>subtitle</h2>
		"""

simple.equal 150, getFileContents('file.taml', true), [
		{first: 1, second: 2},
		{kind: 'cmd', cmd: 'include'},
		]

simple.equal 161, getFileContents('file.txt', true), """
		abc
		def
		"""

setUnitTesting(true)

# ---------------------------------------------------------------------------
