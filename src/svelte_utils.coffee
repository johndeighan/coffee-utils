# svelte_utils.coffee

import {onDestroy} from 'svelte'

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

export onInterval = (func, secs) ->

	interval = setInterval(func, Math.floor(1000 * secs))

	onDestroy () ->
		clearInterval interval
