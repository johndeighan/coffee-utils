# arrow.coffee

export vbar = '│'       # unicode 2502
export hbar = '─'       # unicode 2500
export corner = '└'     # unicode 2514
export arrowhead = '>'
export space = ' '

export oneIndent = vbar + space + space + space
export arrow = corner + hbar + arrowhead + space
export fourSpaces = space + space + space + space

# ---------------------------------------------------------------------------

export getPrefix = (level, option='none') ->

	if level==0 then return ''
	switch option
		when 'withArrow'
			result = oneIndent.repeat(level-1) + arrow
		when 'returnVal'
			result = oneIndent.repeat(level-1) + fourSpaces
		when 'none'
			result = oneIndent.repeat(level)
		else
			throw new Error("getPrefix(): Bad option: '#{option}'")
	if result.length % 4 != 0
		throw new Error("getPrefix(): Bad prefix '#{result}'")
	return result
