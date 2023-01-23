# cssUtils.coffee

import {undef} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

export getCSSVar = (name, elem=undef) =>

	if (elem == undef)
		elem = document
	return getComputedStyle(elem).getPropertyValue(name)

# ---------------------------------------------------------------------------

export setCSSVar = (name, value, elem=undef) =>

	if (elem == undef)
		elem = document
	elem.style.setProperty(name, value)
	return
