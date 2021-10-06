# env_lib.coffee

import {strict as assert} from 'assert'

# --- Use by simply importing and using hEnv
#     This module does no loading - it merely holds hEnv
export hEnv = {}

# --- None of these callbacks should replace variable hEnv

export hCallbacks = {
	getVar: (name) ->
		return hEnv[name]
	setVar: (name, value) ->
		hEnv[name] = value
		return
	clearVar: (name) ->
		delete hEnv[name]
		return
	clearAll: () ->
		for key in Object.keys(hEnv)
			delete hEnv[name]
		return
	names: () ->
		return Object.keys(hEnv)
	}
