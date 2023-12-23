# browser.coffee

import {undef, defined, notdefined} from '@jdeighan/base-utils'

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

export getLocalStore = (key, defValue={}) =>

	if (typeof localStorage == 'undefined')
		console.log "localStorage not available!"
		return undef

	value = localStorage.getItem(key)
	if defined(value)
		return JSON.parse(value)
	else
		localStorage.setItem key, JSON.stringify(defValue)
		return defValue

# ---------------------------------------------------------------------------

export setLocalStore = (key, value) =>

	if (typeof localStorage == 'undefined')
		console.log "localStorage not available!"
		return undef

	localStorage.setItem key, JSON.stringify(value)
	return

# ---------------------------------------------------------------------------
# --- only here for backward compatibility

export localStore = (key, value) =>

	if defined(value)
		setLocalStore key, value
	else
		getLocalStore key, undef
	return
