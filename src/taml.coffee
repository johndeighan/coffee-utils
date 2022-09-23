# taml.coffee

import yaml from 'js-yaml'

import {assert, croak} from '@jdeighan/exceptions'
import {
	undef, defined, notdefined, OL, chomp, escapeStr,
	isString, isObject, isEmpty,
	} from '@jdeighan/coffee-utils'
import {splitLine} from '@jdeighan/coffee-utils/indent'
import {
	firstLine, toArray, toBlock,
	} from '@jdeighan/coffee-utils/block'
import {slurp} from '@jdeighan/coffee-utils/fs'

# ---------------------------------------------------------------------------
#   isTAML - is the string valid TAML?

export isTAML = (text) ->

	return isString(text) && (firstLine(text).indexOf('---') == 0)

# ---------------------------------------------------------------------------
#   taml - convert valid TAML string to a JavaScript value

export fromTAML = (text) ->

	if notdefined(text)
		return undef
	assert isTAML(text), "string #{OL(text)} isn't TAML"

	lLines = for line in toArray(text)
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

	return yaml.load(toBlock(lLines), {skipInvalid: true})

# ---------------------------------------------------------------------------
# --- a replacer is (key, value) -> newvalue

myReplacer = (name, value) ->

	if isString(value)
		return escapeStr(value)
	else if isObject(value, ['tamlReplacer'])
		return value.tamlReplacer()
	else
		return value

# ---------------------------------------------------------------------------

export toTAML = (obj, hOptions={}) ->

	{useTabs, sortKeys, escape, replacer} = hOptions
	if notdefined(replacer)
		replacer = myReplacer
	str = yaml.dump(obj, {
		skipInvalid: true
		indent: 3
		sortKeys: !!sortKeys
		lineWidth: -1
		replacer
		})
	if useTabs
		str = str.replace(/   /g, "\t")
	return "---\n" + chomp(str)

# ---------------------------------------------------------------------------

squote = (text) ->

	return "'" + text.replace(/'/g, "''") + "'"

# ---------------------------------------------------------------------------
#   slurpTAML - read TAML from a file

export slurpTAML = (filepath) ->

	contents = slurp(filepath)
	return fromTAML(contents)
