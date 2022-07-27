# placeholders.coffee

import {assert, error, croak} from '@jdeighan/unit-tester/utils'
import {undef, defined} from '@jdeighan/coffee-utils'

hDefOptions = {
	pre:  '__'
	post: '__'
	}

# ---------------------------------------------------------------------------

export phStr = (name, hOptions=hDefOptions) ->

	{pre, post} = hOptions
	return "#{pre}#{name}#{post}"

# ---------------------------------------------------------------------------

export phReplace = (str, hValues, hOptions=hDefOptions) ->

	{pre, post} = hOptions
	return str.replace(
			/// #{pre} ([A-Za-z_][A-Za-z0-9_]*) #{post} ///g,
			(_, name) -> hValues[name]
			)
