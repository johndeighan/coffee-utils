# browser_utils.coffee

import {undef} from '@jdeighan/coffee-utils'

audio = undef   # audio context - create only when needed, then keep

# ---------------------------------------------------------------------------
#   beep - play a sound

export beep = (volume=100, freq=520, duration=200) ->

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
