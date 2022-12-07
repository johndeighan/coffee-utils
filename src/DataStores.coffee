# DataStores.coffee

import pathlib from 'path'
import {writable, readable, get} from 'svelte/store'

import {assert, croak} from '@jdeighan/base-utils'
import {undef, pass} from '@jdeighan/coffee-utils'
import {localStore} from '@jdeighan/coffee-utils/browser'
import {
	withExt, slurp, barf, newerDestFileExists,
	} from '@jdeighan/coffee-utils/fs'
import {fromTAML} from '@jdeighan/coffee-utils/taml'
import {createDraft, finishDraft, produce} from 'immer'

# ---------------------------------------------------------------------------

export class WritableDataStore

	constructor: (value=undef) ->
		@store = writable value

	subscribe: (func) ->
		return @store.subscribe(func)

	set: (value) ->
		@store.set(value)

	update: (func) ->
		@store.update(func)

# ---------------------------------------------------------------------------

export class BaseDataStore

	constructor: (@value=undef) ->
		@lSubscribers = []

	subscribe: (func) ->
		func @value
		@lSubscribers.push func
		return () ->
			pos = @lSubscribers.indexOf func
			@lSubscribers.splice pos, 1

	set: (val) ->
		@value = val
		@alertSubscribers()
		return

	update: (func) ->
		@value = func(@value)
		@alertSubscribers()
		return

	alertSubscribers: () ->
		for func in @lSubscribers
			func @value
		return

# ---------------------------------------------------------------------------

export class ImmerDataStore extends BaseDataStore

	constructor: () ->
		super []    # initialize with an empty array

	getNewState: () ->

		return produce state, draft =>
			@addGift draft, description, image
		return

	addGift: (draft, description, image) ->
		draft.push {
			id: 1
			description
			image
			}

# ---------------------------------------------------------------------------

export class ToDoDataStore
	# --- implemented with immer

	constructor: () ->
		@lToDos = []
		@lSubscribers = []

	subscribe: (func) ->
		func(@lToDos)
		@lSubscribers.push func
		return () ->
			index = @lSubscribers.indexOf func
			@lSubscribers.splice index, 1

	alertSubscribers: () ->
		for func in @lSubscribers
			func(@lToDos)
		return

	set: (value) ->
		# --- Set new value
		@alertSubscribers()

	update: (func) ->
		# --- Update value
		@alertSubscribers()

	add: (name) ->
		@lToDos.push {
			text: name
			done: false
			}
		return

# ---------------------------------------------------------------------------

export class LocalStorageDataStore extends WritableDataStore

	constructor: (@masterKey, defValue=undef) ->

		# --- CoffeeScript forces us to call super first
		#     so we can't get the localStorage value first
		super defValue
		value = localStore(@masterKey)
		if value?
			@set value

	# --- I'm assuming that when update() is called,
	#     set() will also be called

	set: (value) ->
		if ! value?
			croak "LocalStorageStore.set(): cannont set to undef"
		super value
		localStore @masterKey, value

	update: (func) ->
		super func
		localStore @masterKey, get(@store)

# ---------------------------------------------------------------------------

export class PropsDataStore extends LocalStorageDataStore

	constructor: (masterKey) ->
		super masterKey, {}

	setProp: (name, value) ->
		if ! name?
			croak "PropStore.setProp(): empty key"
		@update (hPrefs) ->
			hPrefs[name] = value
			return hPrefs

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
		pass

	stop: () ->
		pass

# ---------------------------------------------------------------------------

export class DateTimeDataStore extends ReadableDataStore

	start: () ->
		# --- We need to store this interval for use in stop() later
		@interval = setInterval(() ->
			@setter new Date()
			, 1000)

	stop: () ->
		clearInterval @interval

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

	stop: () ->
		document.body.removeEventListener('mousemove', @mouseMoveHandler)

# ---------------------------------------------------------------------------

export class TAMLDataStore extends WritableDataStore

	constructor: (str) ->

		super fromTAML(str)

# ---------------------------------------------------------------------------
#         UTILITIES
# ---------------------------------------------------------------------------

export brewTamlStr = (code, stub) ->

	return """
			import {TAMLDataStore} from '@jdeighan/starbucks/stores';

			export let #{stub} = new TAMLDataStore(`#{code}`);
			"""

# ---------------------------------------------------------------------------

export brewTamlFile = (srcPath, destPath=undef, hOptions={}) ->
	# --- taml => js
	#     Valid Options:
	#        force

	if ! destPath?
		destPath = withExt(srcPath, '.js', {removeLeadingUnderScore:true})
	if hOptions.force || ! newerDestFileExists(srcPath, destPath)
		hInfo = pathlib.parse(destPath)
		stub = hInfo.name

		tamlCode = slurp(srcPath)
		jsCode = brewTamlStr(tamlCode, stub)
		barf destPath, jsCode
	return

# ---------------------------------------------------------------------------
