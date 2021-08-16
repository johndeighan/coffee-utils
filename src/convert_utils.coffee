# convert_utils.coffee

import {strict as assert} from 'assert'
import {dirname, resolve, parse as parse_fname} from 'path';
import CoffeeScript from 'coffeescript'
import marked from 'marked'
import sass from 'sass'

import {
	say,
	undef,
	pass,
	error,
	isEmpty,
	taml,
	unitTesting,
	} from '@jdeighan/coffee-utils'
import {
	splitLine,
	indentedStr,
	indentedBlock,
	undentedBlock,
	} from '@jdeighan/coffee-utils/indent'
import {slurp, pathTo} from '@jdeighan/coffee-utils/fs'
import {setDebugging} from '@jdeighan/coffee-utils/debug'
import {svelteHtmlEsc} from '../src/svelte_utils.js'
import {StringInput} from '@jdeighan/string-input'

### -------------------------------------------------------------------------

- removes blank lines and comments

- converts
		<varname> <== <expr>
	to:
		`$: <varname> = <expr>;`

- converts
		<== <expr>
	to:
		`$: <expr>;`

- converts
		<===
			<code>
	to:
		```
		$: {
			<code>
			}
###
# ---------------------------------------------------------------------------
# --- export to allow unit testing

export class CoffeeMapper extends StringInput

	mapLine: (orgLine) ->

		[level, line] = splitLine(orgLine)
		if isEmpty(line) || line.match(/^#\s/)
			return undef
		if lMatches = line.match(///^
				(?:
					([A-Za-z][A-Za-z0-9_]*)   # variable name
					\s*
					)?
				\<\=\=
				\s*
				(.*)
				$///)
			[_, varname, expr] = lMatches
			if expr
				# --- convert to JavaScript if not unit testing ---
				try
					jsExpr = brewCoffee(expr).trim()   # will have trailing ';'
				catch err
					error err.message

				if varname
					result = indentedStr("\`\$\: #{varname} = #{jsExpr}\`", level)
				else
					result = indentedStr("\`\$\: #{jsExpr}\`", level)
			else
				if varname
					error "Invalid syntax - variable name not allowed"
				code = @fetchBlock(level+1)
				try
					jsCode = brewCoffee(code)
				catch err
					error err.message

				result = """
						\`\`\`
						\$\: {
						#{indentedBlock(jsCode, 1)}
						#{indentedStr('}', 1)}
						\`\`\`
						"""
			return indentedBlock(result, level)
		else
			return orgLine

# ---------------------------------------------------------------------------

export brewExpr = (expr) ->

	if unitTesting
		return expr
	try
		newexpr = CoffeeScript.compile(expr, {bare: true}).trim()
		pos = newexpr.length - 1
		if newexpr.substr(pos, 1) == ';'
			newexpr = newexpr.substr(0, pos)
	catch err
		say "CoffeeScript error!"
		say expr, "expr:"
		error "CoffeeScript error: #{err.message}"
	return newexpr

# ---------------------------------------------------------------------------

export brewCoffee = (text) ->

	if unitTesting
		return text
	try
		oInput = new CoffeeMapper(text)
		newtext = oInput.getAllText()
		script = CoffeeScript.compile(newtext, {bare: true})
	catch err
		say "CoffeeScript error!"
		say text, "Original Text:"
		say newtext, "Mapped Text:"
		error "CoffeeScript error: #{err.message}"
	return script

# ---------------------------------------------------------------------------

export markdownify = (text) ->

	if unitTesting
		return text
	html = marked(undentedBlock(text), {
			grm: true,
			headerIds: false,
			})
	return svelteHtmlEsc(html)

# ---------------------------------------------------------------------------
# --- export to allow unit testing

export class SassMapper extends StringInput

	mapLine: (line) ->

		if line.match(/^\s*$/) || line.match(/^\s*#\s/)
			return undef
		return line

# ---------------------------------------------------------------------------

export sassify = (text) ->

	if unitTesting
		return text
	oInput = new SassMapper(text)
	newtext = oInput.getAllText()
	result = sass.renderSync({
			data: newtext,
			indentedSyntax: true,
			indentType: "tab",
			})
	return result.css.toString()

# ---------------------------------------------------------------------------

hExtToEnvVar = {
	'.md':   'DIR_MARKDOWN',
	'.taml': 'DIR_DATA',
	'.txt':  'DIR_DATA',
	}

# ---------------------------------------------------------------------------

export getFileContents = (fname, convert=false) ->

	if unitTesting
		return "Contents of #{fname}"

	{root, dir, base, ext} = parse_fname(fname.trim())
	assert not root && not dir, "getFileContents():" \
		+ " root='#{root}', dir='#{dir}'" \
		+ " - full path not allowed"
	envvar = hExtToEnvVar[ext]
	assert envvar, "getFileContents() doesn't work for ext '#{ext}'"
	dir = process.env[envvar]
	assert dir, "No env var set for file extension '#{ext}'"
	fullpath = pathTo(base, dir)   # guarantees that file exists
	contents = slurp(fullpath)
	if not convert
		return contents
	switch ext
		when '.md'
			return markdownify(contents)
		when '.taml'
			return taml(contents)
		when '.txt'
			return contents
		else
			error "getFileContents(): No handler for ext '#{ext}'"
