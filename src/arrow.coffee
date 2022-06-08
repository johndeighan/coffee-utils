# arrow.coffee

import {undef, OL, setCharsAt} from '@jdeighan/coffee-utils'

# --- We use spaces here because Windows Terminal handles TAB chars badly

export vbar = '│'       # unicode 2502
export hbar = '─'       # unicode 2500
export corner = '└'     # unicode 2514
export arrowhead = '>'
export space = ' '

export oneIndent = vbar + space + space + space
export arrow = corner + hbar + arrowhead + space
export clearIndent = space + space + space + space

# ---------------------------------------------------------------------------

export getPrefix = (level, option='none') ->

	if level==0
		if (option == 'object')
			return clearIndent
		else
			return ''
	switch option
		when 'withArrow'
			result = oneIndent.repeat(level-1) + arrow
		when 'object'
			result = oneIndent.repeat(level) + clearIndent
		when 'none'
			result = oneIndent.repeat(level)
		else
			throw new Error("getPrefix(): Bad option: '#{option}'")
	if result.length % 4 != 0
		throw new Error("getPrefix(): Bad prefix '#{result}'")
	return result

# ---------------------------------------------------------------------------

export addArrow = (prefix) ->

#	console.log "in addArrow(#{OL(prefix)})"
	pos = prefix.lastIndexOf(vbar)
#	console.log "pos = #{pos}"
	if (pos == -1)
		result = prefix
	else
		result = setCharsAt(prefix, pos, arrow)
#	console.log "result = #{OL(result)}"
	return result

# ---------------------------------------------------------------------------

export removeLastVbar = (prefix) ->

#	console.log "in removeLastVbar(#{OL(prefix)})"
	pos = prefix.lastIndexOf(vbar)
#	console.log "pos = #{pos}"
	if (pos == -1)
		result = prefix
	else
		result = setCharsAt(prefix, pos, ' ')
#	console.log "result = #{OL(result)}"
	return result
