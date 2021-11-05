# log_utils.coffee

import yaml from 'js-yaml'

import {
	assert, undef, isNumber, isString, isHash, isFunction,
	escapeStr, sep_eq,
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
	str = str.replace(/\t/g, '   ')  # fr***ing Windows Terminal
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

	if (! logItem)
		logger "#{prefix}#{str}"
	else if ! item?
		logger "#{prefix}#{str} = undef"
	else if isNumber(item)
		logger "#{prefix}#{str} = #{item}"
	else if isString(item)
		esc = escapeStr(item)
		if (esc.length <= maxOneLine)
			logger "#{prefix}#{str} = '#{esc}'"
		else
			logger "#{prefix}#{str}:"
			logger "#{itemPrefix}#{sep_eq}"
			for line in blockToArray(item)
				logger "#{itemPrefix}#{escapeStr(line)}"
			logger "#{itemPrefix}#{sep_eq}"
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
