# env_lib.coffee

import {strict as assert} from 'assert'

# --- Use by simply importing and using hEnvLib
#     This module does no loading - it merely holds hEnvLib
export hEnvLib = {}

# --- None of these callbacks should replace variable hEnvLib

export hEnvLibCallbacks = {
	getVar: (name) ->
		return hEnvLib[name]
	setVar: (name, value) ->
		hEnvLib[name] = value
		return
	clearVar: (name) ->
		delete hEnvLib[name]
		return
	clearAll: () ->
		for name in Object.keys(hEnvLib)
			delete hEnvLib[name]
		return
	names: () ->
		return Object.keys(hEnvLib)
	}
