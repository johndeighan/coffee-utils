// Generated by CoffeeScript 2.5.1
  // env_lib.coffee
import {
  strict as assert
} from 'assert';

// --- Use by simply importing and using hEnv
//     This module does no loading - it merely holds hEnv
export var hEnv = {};

// --- None of these callbacks should replace variable hEnv
export var hCallbacks = {
  getVar: function(name) {
    return hEnv[name];
  },
  setVar: function(name, value) {
    hEnv[name] = value;
  },
  clearVar: function(name) {
    delete hEnv[name];
  },
  clearAll: function() {
    var i, key, len, ref;
    ref = Object.keys(hEnv);
    for (i = 0, len = ref.length; i < len; i++) {
      key = ref[i];
      delete hEnv[name];
    }
  },
  names: function() {
    return Object.keys(hEnv);
  }
};
