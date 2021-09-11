# temp.coffee

import {log} from '@jdeighan/coffee-utils'
import {debug, setDebugging} from '@jdeighan/coffee-utils/debug'

# ---------------------------------------------------------------------------

main = () ->
	setDebugging true
	x = total([1,2,3])
	debug "total = #{x}"

# ---------------------------------------------------------------------------

total = (lNumbers) ->

	debug "enter total"
	sum = 0
	for n in lNumbers
		sum += n
	sum += max(lNumbers) + max(lNumbers)
	debug "return #{sum} from total"
	return sum

# ---------------------------------------------------------------------------

max = (lNumbers) ->

	debug "enter max()"
	m = lNumbers[0]
	for n in lNumbers
		if (n > m)
			m = n
	debug "return #{m} from max()"
	return m

# ---------------------------------------------------------------------------

main()
