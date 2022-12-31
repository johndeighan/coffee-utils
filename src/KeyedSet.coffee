# KeyedSet.coffee

import {
	undef, defined, notdefined, OL, deepCopy,
	isString, isNonEmptyString, isArray, isHash,
	isEmpty, nonEmpty,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'
import {isArrayOfStrings} from '@jdeighan/coffee-utils'

# ---------------------------------------------------------------------------

export class KeyedSet extends Map

	constructor: (@setName, lKeyNames, @sep='|') ->
		# --- lKeyNames can be:
		#        1. a non-empty string
		#        2. an array of non-empty strings

		dbgEnter 'KeyedSet'
		super()
		assert isNonEmptyString(@setName), "bad set name: #{OL(@setName)}"
		if isString(lKeyNames)
			assert nonEmpty(lKeyNames), "empty string key name"
			@lKeyNames = [lKeyNames]
			@numKeys = 1
		else if isArray(lKeyNames)
			assert nonEmpty(lKeyNames), "empty key name array"
			for name in lKeyNames
				assert isNonEmptyString(name),
						"name not a non-empty string: #{OL(name)}"
			@numKeys = lKeyNames.length
			@lKeyNames = lKeyNames
		else
			croak "Invalid key names: #{OL(lKeyNames)}"
		dbg "key is #{OL(@lKeyNames)}"
		dbgReturn 'KeyedSet'

	# ..........................................................

	add: (keyVal, hData={}) ->

		dbgEnter 'add', keyVal, hData
		assert ! @has(keyVal), "adding duplicate key #{OL(keyVal)}"
		assert isHash(hData), "hData not a hash: #{OL(hData)}"
		dbg "not a duplicate"

		hItem = deepCopy hData

		# --- Add key values to hItem
		lKeyVals = @getKeyValues keyVal
		for name,i in @lKeyNames
			assert notdefined(hItem[name]),
					"hData has key #{name}"
			hItem[name] = lKeyVals[i]

		key = @getKey(keyVal)
		dbg 'key', key
		dbg 'value', hItem
		@set key, hItem    # set() is a method in Map, the base class
		@length = @size    # add to all methods that change size
		dbgReturn 'add'
		return this   # allow chaining

	# ..........................................................

	getKey: (keyVal) ->
		# --- Get the actual key used in the underlying Map object

		dbgEnter 'getKey'
		key = @getKeyValues(keyVal).join(@sep)
		dbgReturn 'getKey', key
		return key

	# ..........................................................

	getKeyValues: (keyVal) ->
		# --- Accepts either a string or an array of strings
		#     But all keys must be non-empty strings
		#     Always returns an array

		dbgEnter 'getKeyValues', keyVal
		if isString(keyVal)
			lKeyVals = [keyVal]
		else if isArray(keyVal)
			lKeyVals = keyVal
		else
			croak "Bad key value: #{OL(keyVal)}"
		assert (lKeyVals.length == @numKeys), "Bad # keys in #{OL(keyVal)}"
		for val in lKeyVals
			assert isNonEmptyString(val), "Bad key val: #{OL(val)}"
		dbgReturn 'getKeyValues', lKeyVals
		return lKeyVals

	# ..........................................................

	has: (keyVal) ->

		return super @getKey(keyVal)

	# ..........................................................

	update: (keyVal, hData={}) ->

		dbgEnter 'update', keyVal, hData
		key = @getKey(keyVal)
		dbg "key = #{OL(key)}"
		hItem = @get(key)
		dbg 'hItem', hItem
		assert defined(hItem), "updating missing key #{OL(keyVal)}"
		for key,val of hData
			hItem[key] = val
		dbgReturn 'update'
		return this   # allow chaining

	# ..........................................................

	remove: (keyVal) ->

		key = @getKey(keyVal)
		if ! @delete key
			croak "No key #{OL(keyVal)} in #{@setName}"
		@length = @size    # add to all methods that change size
		return this   # allow chaining

	# ..........................................................

	getAllItems: () ->
		# --- Useful for unit tests, but it's usually better
		#     to use a generator like .entries()

		return Array.from(@values())

	# ..........................................................

	get: (keyVal) ->
		# --- Override to require that it exists

		item = super @getKey(keyVal)
		assert defined(item), "No such item: #{OL(keyVal)} in #{@setName}"
		return item

	# ..........................................................

	dump: () ->

		console.log "DUMP #{@setName}:"
		for [key, value] from @entries()
			console.log "#{OL(key)}: #{OL(value)}"

# ---------------------------------------------------------------------------
