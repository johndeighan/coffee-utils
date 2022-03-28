# arrow.coffee

vbar = '│'       # unicode 2502
hbar = '─'       # unicode 2500
corner = '└'     # unicode 2514
arrowhead = '>'

oneIndent = vbar + '   '
export arrow = corner + hbar + arrowhead + ' '

# ---------------------------------------------------------------------------

export getPrefix = (level, withArrow) ->

	if withArrow
		return oneIndent.repeat(level-1) + arrow
	else
		return oneIndent.repeat(level)
	return

# ---------------------------------------------------------------------------

export hasArrow = (str) ->

	return str.indexOf(arrow) > -1

# ---------------------------------------------------------------------------

export removeArrow = (str, useVbar) ->

	if hasArrow(str)
		if useVbar
			return str.replace(arrow, oneIndent)
		else
			return str.replace(arrow, '    ')
	else
		return str

# ---------------------------------------------------------------------------
