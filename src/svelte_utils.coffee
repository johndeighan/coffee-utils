# svelte_utils.coffee

import {assert, isFunction} from '@jdeighan/coffee-utils'
import {log} from '@jdeighan/coffee-utils/log'

# ---------------------------------------------------------------------------
#   svelteSourceCodeEsc - to display source code for a *.starbucks page

export svelteSourceCodeEsc = (str) ->

	return str \
		.replace(/\</g, '&lt;') \
		.replace(/\>/g, '&gt;') \
		.replace(/\{/g, '&lbrace;') \
		.replace(/\}/g, '&rbrace;') \
		.replace(/\$/g, '&dollar;')

# ---------------------------------------------------------------------------
#   svelteHtmlEsc - after converting markdown

export svelteHtmlEsc = (str) ->

	return str \
		.replace(/\{/g, '&lbrace;') \
		.replace(/\}/g, '&rbrace;') \
		.replace(/\$/g, '&dollar;')

# ---------------------------------------------------------------------------

export onInterval = (func, secs, doLog=false) ->

	assert isFunction(func), "onInterval(): 1st arg not a function"
	ms = Math.floor(1000 * secs)
	if doLog
		log "calling func every #{ms} ms."
	interval = setInterval(func, ms)

	return () ->
		if doLog
			log "destroying interval timer"
		clearInterval interval
