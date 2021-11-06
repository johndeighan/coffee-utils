# UnitTester.coffee

import test from 'ava'

import {
	assert, undef, pass, error, croak,
	isString, isFunction, isInteger, isArray,
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {log, currentLogger, setLogger} from '@jdeighan/coffee-utils/log'
import {
	debug, debugging, setDebugging,
	} from '@jdeighan/coffee-utils/debug'

# ---------------------------------------------------------------------------

export class UnitTester

	constructor: (whichTest='deepEqual', @fulltest=false) ->
		@hFound = {}
		@setWhichTest whichTest
		@justshow = false
		@testing = true
		@maxLineNum = undef

	# ........................................................................

	initialize: () ->     # override to do any initialization

		pass

	# ........................................................................

	justshow: (flag) ->

		@justshow = flag
		return

	# ........................................................................

	just_show: (flag) ->

		@justshow = flag
		return

	# ........................................................................

	setMaxLineNum: (n) ->

		@maxLineNum = n
		return

	# ........................................................................

	setWhichTest: (testName) ->
		@whichTest = testName
		return

	# ........................................................................

	truthy: (lineNum, input, expected=undef) ->
		@setWhichTest 'truthy'
		@test lineNum, input, expected
		return

	# ........................................................................

	falsy: (lineNum, input, expected=undef) ->
		@setWhichTest 'falsy'
		@test lineNum, input, expected
		return

	# ........................................................................

	equal: (lineNum, input, expected) ->
		@setWhichTest 'deepEqual'
		@test lineNum, input, expected
		return

	# ........................................................................

	notequal: (lineNum, input, expected) ->
		@setWhichTest 'notDeepEqual'
		@test lineNum, input, expected
		return

	# ........................................................................

	same: (lineNum, input, expected) ->
		@setWhichTest 'is'
		@test lineNum, input, expected
		return

	# ........................................................................

	different: (lineNum, input, expected) ->
		@setWhichTest 'not'
		@test lineNum, input, expected
		return

	# ........................................................................

	fails: (lineNum, func, expected) ->

		assert ! expected?, "UnitTester: fails doesn't allow expected"
		assert isFunction(func), "UnitTester: fails requires a function"

		# --- disable logging
		logger = currentLogger()
		setLogger (x) -> pass
		try
			func()
			ok = true
		catch err
			ok = false
		setLogger logger
		@setWhichTest 'falsy'
		@test lineNum, ok, expected
		return

	# ........................................................................

	succeeds: (lineNum, func, expected) ->

		assert ! expected?, "UnitTester: succeeds doesn't allow expected"
		assert isFunction(func), "UnitTester: succeeds requires a function"
		try
			func()
			ok = true
		catch err
			ok = false
		@setWhichTest 'truthy'
		@test lineNum, ok, expected
		return

	# ........................................................................

	same_list: (lineNum, list, expected) ->
		assert ! list? || isArray(list), "UnitTester: not an array"
		assert ! expected? || isArray(expected),
			"UnitTester: expected is not an array"

		@setWhichTest 'deepEqual'
		@test lineNum, list.sort(), expected.sort()
		return

	# ........................................................................

	not_same_list: (lineNum, list, expected) ->
		assert ! list? || isArray(list), "UnitTester: not an array"
		assert ! expected? || isArray(expected),
			"UnitTester: expected is not an array"

		@setWhichTest 'notDeepEqual'
		@test lineNum, list.sort(), expected.sort()
		return

	# ........................................................................

	normalize: (input) ->

		# --- Convert all whitespace to single space character
		#     Remove empty lines

		if isString(input)
			lLines = for line in blockToArray(input)
				line = line.trim()
				line.replace(/\s+/g, ' ')
			lLines = lLines.filter (line) -> line != ''
			return lLines.join('\n')
		else
			return input

	# ........................................................................

	test: (lineNum, input, expected) ->

		assert isInteger(lineNum),
			"UnitTester.test(): arg 1 must be an integer"

		@initialize()
		@lineNum = lineNum    # set an object property

		if (lineNum < 0) && process.env.FINALTEST
			error "Negative line numbers not allowed in FINALTEST"

		if ! @testing || (@maxLineNum && (lineNum > @maxLineNum))
			return

		if lineNum < -100000
			setDebugging true

		lineNum = @getLineNum(lineNum)   # corrects for duplicates
		errMsg = undef
		try
			got = @transformValue(input)
			if isString(got)
				got = @normalize(got)
		catch err
			errMsg = err.message || 'UNKNOWN ERROR'
			log "got ERROR: #{errMsg}"

		expected = @transformExpected(expected)
		if isString(expected)
			expected = @normalize(expected)

		if @justshow
			log "line #{lineNum}"
			if errMsg
				log "GOT ERROR #{errMsg}"
			else
				log got, "GOT:"
			log expected, "EXPECTED:"
			if lineNum < -100000
				setDebugging false
			return

		# --- We need to save this here because in the tests themselves,
		#     'this' won't be correct
		whichTest = @whichTest

		if lineNum < 0
			test.only "line #{lineNum}", (t) ->
				t[whichTest](got, expected)
			@testing = false
		else
			test "line #{lineNum}", (t) ->
				t[whichTest](got, expected)
		if lineNum < -100000
			setDebugging false
		return

	# ........................................................................

	transformValue: (input) ->
		return input

	# ........................................................................

	transformExpected: (input) ->
		log "CALL BASE CLASS transformExpected!!!"
		return input

	# ........................................................................

	getLineNum: (lineNum) ->

		if @fulltest && (lineNum < 0)
			error "UnitTester(): negative line number during full test!!!"

		# --- patch lineNum to avoid duplicates
		while @hFound[lineNum]
			if lineNum < 0
				lineNum -= 1000
			else
				lineNum += 1000
		@hFound[lineNum] = true
		return lineNum

# ---------------------------------------------------------------------------
