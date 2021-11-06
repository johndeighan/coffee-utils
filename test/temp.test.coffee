# log.test.cielo

import {undef, escapeStr} from '@jdeighan/coffee-utils'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'
import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	stringify, setStringifier, log, setLogger, tamlStringify,
	} from '@jdeighan/coffee-utils/log'

simple = new UnitTester()

# ---------------------------------------------------------------------------

class LogTester extends UnitTester

	transformValue: (lLines) ->
		return arrayToBlock(lLines)

	# --- when logging, \t becomes 3 spaces
	transformExpected: (expected) ->
		if expected.indexOf("\t") != -1
			log "TRANSFORM '#{escapeStr(expected)}'"
			newStr = expected.replace("\t", '   ')
			log "TRANSFORM '#{escapeStr(newStr)}'"
			return newStr
		else
			log "OK"
			return expected

	normalize: (text) ->
		return text

tester = new LogTester()

# ---------------------------------------------------------------------------

lLines = undef
setLogger (str) ->
	lLines.push(str)
	return

(() ->
	lLines = []
	log 'abc'
	log 'name', {
		fname: 'John',
		home: 'Blacksburg, VA',
		}
	tester.equal 136, lLines, """
		abc
		name:
			---
			fname: John
			home: Blacksburg, VA
		"""
	)()
