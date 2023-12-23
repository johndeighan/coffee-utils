# prefs.coffee

import {getLocalStore} from '@jdeighan/coffee-utils/browser'

export hPrefs = getLocalStore 'hPrefs', {}

# ---------------------------------------------------------------------------

export setPref = (key, value) =>

	hPrefs[key] = value
	setLocalStore 'hPrefs', hPrefs
