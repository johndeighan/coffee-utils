# browser.coffee

import {undef, defined, notdefined} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'

audio = undef   # audio context - create only when needed, then keep

# ---------------------------------------------------------------------------
#   beep - play a sound

export beep = (volume=100, freq=520, duration=200) =>

	if audio == undef
		audio = new AudioContext()
	v = audio.createOscillator()
	u = audio.createGain()
	v.connect(u)
	v.frequency.value = freq
	v.type = "square"
	u.connect(audio.destination)
	u.gain.value = volume * 0.01
	v.start(audio.currentTime)
	v.stop(audio.currentTime + duration * 0.001)
	return

# ---------------------------------------------------------------------------

export localStorageAvailable = () ->

	storage = window.localStorage
	if notdefined(storage)
		return false
	try
		x = '__storage_test__'
		storage.setItem x, x
		got = storage.getItem x
		storage.removeItem x
		return (got == x)
	catch e
		return false

# ---------------------------------------------------------------------------

export getLocalStore = (key, defValue={}) =>

	assert localStorageAvailable(), "no localStorage"
	if localStorage.hasOwnProperty(key)
		return JSON.parse(localStorage.getItem(key))
	else
		localStorage.setItem key, JSON.stringify(defValue)
		return defValue

# ---------------------------------------------------------------------------

export setLocalStore = (key, value) =>

	assert localStorageAvailable(), "no localStorage"
	localStorage.setItem key, JSON.stringify(value)
	return
