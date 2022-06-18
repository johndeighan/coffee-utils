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

export prefix = (level, option='none') ->

	switch option
		when 'withArrow'
			result = oneIndent.repeat(level-1) + arrow
		when 'noLastVbar'
			result = oneIndent.repeat(level-1) + clearIndent
		when 'none'
			result = oneIndent.repeat(level)
		else
			throw new Error("prefix(): Bad option: '#{option}'")
	if result.length % 4 != 0
		throw new Error("prefix(): Bad prefix '#{result}'")
	return result

# ---------------------------------------------------------------------------

export addArrow = (prefix) ->

	pos = prefix.lastIndexOf(vbar)
	if (pos == -1)
		result = prefix
	else
		result = setCharsAt(prefix, pos, arrow)
	return result

# ---------------------------------------------------------------------------

export removeLastVbar = (prefix) ->

	pos = prefix.lastIndexOf(vbar)
	if (pos == -1)
		result = prefix
	else
		result = setCharsAt(prefix, pos, ' ')
	return result
