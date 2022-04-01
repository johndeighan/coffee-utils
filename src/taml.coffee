# taml.coffee

import yaml from 'js-yaml'

import {
	assert, undef, oneline, isString,
	} from '@jdeighan/coffee-utils'
import {untabify, tabify, splitLine} from '@jdeighan/coffee-utils/indent'
import {slurp} from '@jdeighan/coffee-utils/fs'
import {debug} from '@jdeighan/coffee-utils/debug'
import {
	firstLine, blockToArray, arrayToBlock,
	} from '@jdeighan/coffee-utils/block'

# ---------------------------------------------------------------------------
#   isTAML - is the string valid TAML?

export isTAML = (text) ->

	return isString(text) && (firstLine(text).indexOf('---') == 0)

# ---------------------------------------------------------------------------

squote = (text) ->

	return "'" + text.replace(/'/g, "''") + "'"

# ---------------------------------------------------------------------------
#   taml - convert valid TAML string to a JavaScript value

export taml = (text) ->

	debug "enter taml(#{oneline(text)})"
	if ! text?
		debug "return undef from taml() - text is not defined"
		return undef
	assert isTAML(text), "taml(): string #{oneline(text)} isn't TAML"

	lLines = for line in blockToArray(text)
		[level, str] = splitLine(line)
		prefix = ' '.repeat(level)
		if lMatches = line.match(///^
				([A-Za-z_][A-Za-z0-9_]*)    # the key
				\s*
				:
				\s*
				(.*)
				$///)
			[_, key, text] = lMatches
			if isEmpty(text) || text.match(/\d+(?:\.\d*)$/)
				prefix + str
			else
				prefix + key + ':' + ' ' + squote(text)
		else
			prefix + str

	debug "return from taml()"
	return yaml.load(arrayToBlock(lLines), {skipInvalid: true})

# ---------------------------------------------------------------------------
#   slurpTAML - read TAML from a file

export slurpTAML = (filepath) ->

	contents = slurp(filepath)
	return taml(contents)
