# arrow.coffee

import {assert} from '@jdeighan/unit-tester/utils'
import {undef, OL, setCharsAt} from '@jdeighan/coffee-utils'

# --- We use spaces here because Windows Terminal handles TAB chars badly

export vbar = '│'       # unicode 2502
export hbar = '─'       # unicode 2500
export corner = '└'     # unicode 2514
export arrowhead = '>'
export space = ' '
export dot = '.'

export oneIndent   = vbar   + space + space     + space
export arrow       = corner + hbar  + arrowhead + space
export clearIndent = space  + space + space     + space
export dotIndent   = dot    + space + space     + space

# ---------------------------------------------------------------------------

export prefix = (level, option='none') ->

	switch option
		when 'withArrow'
			if (level == 0)
				return arrow
			else
				return oneIndent.repeat(level-1) + arrow
		when 'noLastVbar'
			assert (level >= 1), "prefix(), noLastVbar but level=#{OL(level)}"
			return oneIndent.repeat(level-1) + clearIndent
		when 'noLast2Vbars'
			assert (level >= 2), "prefix(), noLast2Vbars but level=#{OL(level)}"
			return oneIndent.repeat(level-2) + clearIndent + clearIndent
		when 'dotLastVbar'
			assert (level >= 1), "prefix(), dotLastVbar but level=#{OL(level)}"
			return oneIndent.repeat(level-1) + dotIndent
		when 'dotLast2Vbars'
			assert (level >= 2), "prefix(), dotLast2Vbars but level=#{OL(level)}"
			return oneIndent.repeat(level-2) + dotIndent + clearIndent
		else
			return oneIndent.repeat(level)

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
