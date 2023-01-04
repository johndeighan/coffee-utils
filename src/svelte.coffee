# svelte.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG} from '@jdeighan/base-utils/log'
import {isFunction} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------
#   svelteSourceCodeEsc - to display source code for a *.starbucks page

export svelteSourceCodeEsc = (str) =>

	return str \
		.replace(/\</g, '&lt;') \
		.replace(/\>/g, '&gt;') \
		.replace(/\{/g, '&lbrace;') \
		.replace(/\}/g, '&rbrace;') \
		.replace(/\$/g, '&dollar;')

# ---------------------------------------------------------------------------
#   svelteHtmlEsc - after converting markdown

export svelteHtmlEsc = (str) =>

	return str \
		.replace(/\{/g, '&lbrace;') \
		.replace(/\}/g, '&rbrace;') \
		.replace(/\$/g, '&dollar;')

# ---------------------------------------------------------------------------

export onInterval = (func, secs, doLog=false) =>

	assert isFunction(func), "onInterval(): 1st arg not a function"
	ms = Math.floor(1000 * secs)
	if doLog
		LOG "calling func every #{ms} ms."
	interval = setInterval(func, ms)

	return () ->
		if doLog
			LOG "destroying interval timer"
		clearInterval interval
