# env_lib.coffee

import {strict as assert} from 'assert'

# --- Use by simply importing and using hEnv
#     This module does no loading - it merely holds hEnv
export hEnvLib = {}

# --- None of these callbacks should replace variable hEnv

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
		for key in Object.keys(hEnv)
			delete hEnvLib[name]
		return
	names: () ->
		return Object.keys(hEnvLib)
	}
