# temp.coffee

import {say} from '@jdeighan/coffee-utils'

# ---------------------------------------------------------------------------

n = new Number(42)
if Number.isInteger(n)
	say "yes"
else
	say "no"
