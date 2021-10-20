# privenv.test.coffee

import assert from 'assert'
import test from 'ava'

import {
	undef, pass, isString, isHash, isEmpty, nonEmpty,
	} from '@jdeighan/coffee-utils'
import {log, setLogger} from '@jdeighan/coffee-utils/log'
import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	hPrivEnv, resetPrivEnv, setPrivEnvVar, logPrivEnv,
	} from '@jdeighan/coffee-utils/privenv'

simple = new UnitTester()

# ----------------------------------------------------------------------------

(() ->
	resetPrivEnv()
	setPrivEnvVar('DIR_ROOT', '/usr/johnd')
	setPrivEnvVar('DIR_COMPONENTS', '/usr/johnd/components')

	simple.equal 24, hPrivEnv['DIR_ROOT'], '/usr/johnd'

	strLogs = ''
	setLogger (line) -> strLogs += "#{line}\n"
	logPrivEnv()

	simple.equal 30, strLogs, """
			PRIVATE ENVIRONMENT:
				DIR_ROOT = '/usr/johnd'
				DIR_COMPONENTS = '/usr/johnd/components'
				----------------------------------------
			"""
	)()

# ----------------------------------------------------------------------------
