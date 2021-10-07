# private_env.coffee

import {strict as assert} from 'assert'

# --- Use by simply importing and using hEnvLib
#     This module does no loading - it merely holds hEnvLib
export hPrivEnv = {}

# --- None of these callbacks should replace variable hEnvLib

export hPrivEnvCallbacks = {
	getVar: (name) ->
		return hPrivEnv[name]
	setVar: (name, value) ->
		hPrivEnv[name] = value
		return
	clearVar: (name) ->
		delete hPrivEnv[name]
		return
	clearAll: () ->
		for name in Object.keys(hPrivEnv)
			delete hPrivEnv[name]
		return
	names: () ->
		return Object.keys(hPrivEnv)
	}
