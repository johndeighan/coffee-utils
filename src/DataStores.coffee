# DataStores.coffee

import pathlib from 'path'
import {writable, readable, get} from 'svelte/store'

import {
	undef, defined, notdefined, pass, range, getOptions,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {fromTAML} from '@jdeighan/base-utils/taml'
import {localStore} from '@jdeighan/coffee-utils/browser'
import {
	withExt, slurp, barf, newerDestFileExists,
	} from '@jdeighan/coffee-utils/fs'

# ---------------------------------------------------------------------------

export class StaticDataStore

	constructor: (value) ->
		@value = value

	subscribe: (cbFunc) ->
		cbFunc @value
		return () ->
			pass()

	set: (val) ->
		croak "Can't set() a StaticDataStore"

	update: (func) ->
		croak "Can't update() a StaticDataStore"

# ---------------------------------------------------------------------------

export class WritableDataStore

	constructor: (value=undef) ->
		@store = writable value

	subscribe: (func) ->
		return @store.subscribe(func)

	set: (value) ->
		@store.set(value)
		return

	update: (func) ->
		@store.update(func)
		return

# ---------------------------------------------------------------------------

export class LocalStorageDataStore extends WritableDataStore

	constructor: (@masterKey, defValue=undef) ->

		# --- CoffeeScript forces us to call super first
		#     so we can't get the localStorage value first
		super defValue
		value = localStore(@masterKey)
		if defined(value)
			@set value

	# --- I'm assuming that when update() is called,
	#     set() will also be called

	set: (value) ->
		assert defined(value), "set(): cannot set to undef"
		super value
		localStore @masterKey, value
		return

	update: (func) ->
		super func
		localStore @masterKey, get(@store)
		return

# ---------------------------------------------------------------------------

export class PropsDataStore extends LocalStorageDataStore

	constructor: (masterKey, defValue=undef) ->
		super masterKey, {}

	setProp: (name, value) ->

		assert defined(name), "PropStore.setProp(): empty key"
		@update (hPrefs) ->
			hPrefs[name] = value
			return hPrefs
		return

# ---------------------------------------------------------------------------

export class ReadableDataStore

	constructor: () ->
		@store = readable null, (set) ->
			@setter = set        # store the setter function
			@start()             # call your start() method
			return () => @stop() # return function capable of stopping

	subscribe: (callback) ->
		return @store.subscribe(callback)

	start: () ->
		return

	stop: () ->
		return

# ---------------------------------------------------------------------------

export class DateTimeDataStore extends ReadableDataStore

	start: () ->
		# --- We need to store this interval for use in stop() later
		@interval = setInterval(() ->
			@setter new Date()
			, 1000)
		return

	stop: () ->
		clearInterval @interval
		return

# ---------------------------------------------------------------------------

export class MousePosDataStore extends ReadableDataStore

	start: () ->
		# --- We need to store this handler for use in stop() later
		@mouseMoveHandler = (e) ->
			@setter {
				x: e.clientX,
				y: e.clientY,
				}
		document.body.addEventListener('mousemove', @mouseMoveHandler)
		return

	stop: () ->
		document.body.removeEventListener('mousemove', @mouseMoveHandler)
		return

# ---------------------------------------------------------------------------

export class TAMLDataStore extends WritableDataStore

	constructor: (str) ->

		super fromTAML(str)

# ---------------------------------------------------------------------------
# --- Mainly for better understanding, I've implemented data stores
#     without using svelte's readable or writable data stores

export class BaseDataStore

	constructor: (@value=undef) ->
		@lSubscribers = []

	subscribe: (cbFunc) ->
		cbFunc @value
		@lSubscribers.push cbFunc
		return () ->
			index = @lSubscribers.indexOf cbFunc
			@lSubscribers.splice index, 1

	set: (val) ->
		@value = val
		return

	update: (func) ->
		@value = func(@value)
		@alertSubscribers()
		return

	alertSubscribers: () ->
		for cbFunc in @lSubscribers
			cbFunc @value
		return

# ---------------------------------------------------------------------------

export class ToDoDataStore extends BaseDataStore

	constructor: () ->
		lToDos = []   # save local reference to make code easier to grok
		super lToDos
		@lToDos = lToDos   # can't do this before calling super

	set: (val) ->
		croak "Don't use set()"

	update: (func) ->
		croak "Don't use update()"

	find: (name) ->
		# --- returns index
		for index in range(@lToDos.length)
			if (@lToDos[index].text == name)
				return index
		return undef

	clear: () ->
		# --- Don't set a new array. That would break our reference
		@lToDos.splice 0, @lToDos.length
		return

	add: (name) ->
		assert notdefined(@find(name)), "Todo #{name} already exists"
		@lToDos.push {
			text: name
			done: false
			}
		@alertSubscribers()
		return

	remove: (name) ->
		index = @find(name)
		@lToDos.splice index, 1
		@alertSubscribers()
		return

# ---------------------------------------------------------------------------
#         UTILITIES
# ---------------------------------------------------------------------------

export brewTamlStr = (code, stub) =>

	return """
			import {TAMLDataStore} from '@jdeighan/starbucks/stores';

			export let #{stub} = new TAMLDataStore(`#{code}`);
			"""

# ---------------------------------------------------------------------------

export brewTamlFile = (srcPath, destPath=undef, hOptions={}) =>
	# --- taml => js
	#     Valid Options:
	#        force

	if notdefined(destPath)
		destPath = withExt(srcPath, '.js')
	{force} = getOptions(hOptions)
	if force || ! newerDestFileExists(srcPath, destPath)
		hInfo = pathlib.parse(destPath)
		stub = hInfo.name

		tamlCode = slurp(srcPath)
		jsCode = brewTamlStr(tamlCode, stub)
		barf destPath, jsCode
	return

# ---------------------------------------------------------------------------
