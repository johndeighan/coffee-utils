# log_utils.coffee

import {strict as assert} from 'assert'
import yaml from 'js-yaml'

import {
	undef, isFunction, escapeStr, stringToArray,
	} from '@jdeighan/coffee-utils'
import {tabify} from '@jdeighan/coffee-utils/indent'
import {debug} from '@jdeighan/coffee-utils/debug'

logger = console.log          # for strings

# ---------------------------------------------------------------------------
# the default stringifier

export tamlStringify = (obj) ->

	str = yaml.dump(obj, {
			skipInvalid: true
			indent: 1
			sortKeys: false
			lineWidth: -1
			})
	str = "---\n" + tabify(str)
	str = str.replace(/\t/g, '   ')  # because fr***ing Windows Terminal
	                                 # has no way of adjusting display
	                                 # of TAB chars
	return str

# ---------------------------------------------------------------------------

export stringify = tamlStringify # for non-strings

# ---------------------------------------------------------------------------

export setLogger = (func) ->

	if func?
		assert isFunction(func), "setLogger() not a function"
		logger = func
	else
		logger = console.log
	return

# ---------------------------------------------------------------------------

export setStringifier = (func) ->

	if func?
		assert isFunction(func), "setStringifier() not a function"
		stringify = func
	else
		stringify = tamlStringify
	return

# ---------------------------------------------------------------------------

export currentLogger = () ->

	return logger

# ---------------------------------------------------------------------------

export currentStringifier = () ->

	return stringify

# ---------------------------------------------------------------------------

maxOneLine = 32

# ---------------------------------------------------------------------------
#   log - print to the console

export log = (lArgs...) ->
	# --- (str, item, prefix)

	console.log "enter log()"
	nArgs = lArgs.length
	if (nArgs==0)
		return
	str = lArgs[0]
	if (nArgs >= 2)
		item = lArgs[1]    # might be undef
	if (nArgs >= 3)
		prefix = lArgs[2]
	else
		prefix = ''

	debug "nArgs = #{nArgs}"
	debug "str = '#{str}'"
	debug "item", item

	if (nArgs==1)
		logger "#{prefix}#{str}"
	else if not item?
		logger "#{prefix}#{str} = undef"
	else if isNumber(item)
		logger "#{prefix}#{str} = #{item}"
	else if isString(item)
		esc = escapeStr(item)
		if (esc.length <= maxOneLine)
			logger "#{prefix}#{str} = '#{esc}'"
		else
			logger "#{prefix}#{str}:"
			for line in stringToArray(item)
				logger "#{prefix}   #{escapeStr(line)}"
	else
		# --- It's some type of object
		json = JSON.stringify(item)
		if (json.length <= maxOneLine)
			logger "#{prefix}#{str} = #{json}"
		else
			logger "#{prefix}#{str}:"
			for str in stringToArray(stringify(item))
				logger "#{prefix}   #{str}"
	debug "return from log()"
	return

# ---------------------------------------------------------------------------
