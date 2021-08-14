# temp.coffee

import {say} from '@jdeighan/coffee-utils'

obj = {
	a: 1
	b: 3
	c:
		a: 'first'
		b: 'second'
	}

say obj, "OBJECT:"
