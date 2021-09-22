# log_utils.coffee

import {strict as assert} from 'assert'
import yaml from 'js-yaml'

import {
	undef, isNumber, isString, isHash, isFunction, escapeStr,
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {tabify} from '@jdeighan/coffee-utils/indent'

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

export log = (lArgs...) ->
	# --- (str, item, hOptions)
	#     valid options:
	#        prefix
	#        logItem
	#        itemPrefix

	if (lArgs.length==0)
		return
	str = lArgs[0]
	switch lArgs.length
		when 1
			logItem = false
		when 2
			item = lArgs[1]
			logItem = true
		else
			item = lArgs[1]      # might not be logged, though
			hOptions = lArgs[2]
			assert isHash(hOptions), "log(): 3rd arg must be a hash"
			if hOptions.logItem?
				logItem = hOptions.logItem

	if hOptions?
		if hOptions.prefix?
			prefix = hOptions.prefix
		else
			prefix = ''

		if hOptions.itemPrefix?
			itemPrefix = hOptions.itemPrefix
		else
			itemPrefix = ''
	else
		prefix = itemPrefix = ''

	if (not logItem)
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
			for line in blockToArray(item)
				logger "#{itemPrefix}   #{escapeStr(line)}"
	else
		# --- It's some type of object
		json = JSON.stringify(item)
		if (json.length <= maxOneLine)
			logger "#{prefix}#{str} = #{json}"
		else
			logger "#{prefix}#{str}:"
			for str in blockToArray(stringify(item))
				logger "#{itemPrefix}   #{str}"
	return

# ---------------------------------------------------------------------------
