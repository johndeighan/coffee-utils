// Generated by CoffeeScript 2.7.0
// browser.coffee
var audio;

import {
  undef
} from '@jdeighan/coffee-utils';

audio = undef; // audio context - create only when needed, then keep


// ---------------------------------------------------------------------------
//   beep - play a sound
export var beep = function(volume = 100, freq = 520, duration = 200) {
  var u, v;
  if (audio === undef) {
    audio = new AudioContext();
  }
  v = audio.createOscillator();
  u = audio.createGain();
  v.connect(u);
  v.frequency.value = freq;
  v.type = "square";
  u.connect(audio.destination);
  u.gain.value = volume * 0.01;
  v.start(audio.currentTime);
  v.stop(audio.currentTime + duration * 0.001);
};

// ---------------------------------------------------------------------------
export var localStore = function(key, value = undef) {
  // --- if value is undef, returns the current value
  if (typeof localStorage === 'undefined') {
    return;
  }
  if (value != null) {
    localStorage.setItem(key, JSON.stringify(value));
  } else {
    value = localStorage.getItem(key);
    if (value != null) {
      return JSON.parse(localStorage.getItem(key));
    } else {
      return undef;
    }
  }
};