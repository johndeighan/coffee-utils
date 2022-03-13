// Generated by CoffeeScript 2.6.1
// DataStores.coffee
import pathlib from 'path';

import yaml from 'js-yaml';

import {
  writable,
  readable,
  get
} from 'svelte/store';

import {
  assert,
  undef,
  pass,
  error,
  isEmpty
} from '@jdeighan/coffee-utils';

import {
  localStore
} from '@jdeighan/coffee-utils/browser';

import {
  log
} from '@jdeighan/coffee-utils/log';

import {
  withExt,
  slurp,
  barf,
  newerDestFileExists
} from '@jdeighan/coffee-utils/fs';

import {
  untabify
} from '@jdeighan/coffee-utils/indent';

// ---------------------------------------------------------------------------
export var WritableDataStore = class WritableDataStore {
  constructor(value = undef) {
    this.store = writable(value);
  }

  subscribe(callback) {
    return this.store.subscribe(callback);
  }

  set(value) {
    return this.store.set(value);
  }

  update(func) {
    return this.store.update(func);
  }

};

// ---------------------------------------------------------------------------
export var LocalStorageDataStore = class LocalStorageDataStore extends WritableDataStore {
  constructor(masterKey1, defValue = undef) {
    var value;
    super(defValue);
    this.masterKey = masterKey1;
    value = localStore(this.masterKey);
    if (value != null) {
      this.set(value);
    }
  }

  // --- I'm assuming that when update() is called,
  //     set() will also be called
  set(value) {
    if (value == null) {
      error("LocalStorageStore.set(): cannont set to undef");
    }
    super.set(value);
    return localStore(this.masterKey, value);
  }

  update(func) {
    super.update(func);
    return localStore(this.masterKey, get(this.store));
  }

};

// ---------------------------------------------------------------------------
export var PropsDataStore = class PropsDataStore extends LocalStorageDataStore {
  constructor(masterKey) {
    super(masterKey, {});
  }

  setProp(name, value) {
    if (name == null) {
      error("PropStore.setProp(): empty key");
    }
    return this.update(function(hPrefs) {
      hPrefs[name] = value;
      return hPrefs;
    });
  }

};

// ---------------------------------------------------------------------------
export var ReadableDataStore = class ReadableDataStore {
  constructor() {
    this.store = readable(null, function(set) {
      this.setter = set; // store the setter function
      this.start(); // call your start() method
      return () => {
        return this.stop(); // return function capable of stopping
      };
    });
  }

  subscribe(callback) {
    return this.store.subscribe(callback);
  }

  start() {
    return pass;
  }

  stop() {
    return pass;
  }

};

// ---------------------------------------------------------------------------
export var DateTimeDataStore = class DateTimeDataStore extends ReadableDataStore {
  start() {
    // --- We need to store this interval for use in stop() later
    return this.interval = setInterval(function() {
      return this.setter(new Date(), 1000);
    });
  }

  stop() {
    return clearInterval(this.interval);
  }

};

// ---------------------------------------------------------------------------
export var MousePosDataStore = class MousePosDataStore extends ReadableDataStore {
  start() {
    // --- We need to store this handler for use in stop() later
    this.mouseMoveHandler = function(e) {
      return this.setter({
        x: e.clientX,
        y: e.clientY
      });
    };
    return document.body.addEventListener('mousemove', this.mouseMoveHandler);
  }

  stop() {
    return document.body.removeEventListener('mousemove', this.mouseMoveHandler);
  }

};

// ---------------------------------------------------------------------------
export var TAMLDataStore = class TAMLDataStore extends WritableDataStore {
  constructor(str) {
    super(taml(str));
  }

};

// ---------------------------------------------------------------------------
//         UTILITIES
// ---------------------------------------------------------------------------
export var taml = function(text) {
  if (text == null) {
    return undef;
  }
  return yaml.load(untabify(text, 1), {
    skipInvalid: true
  });
};

// ---------------------------------------------------------------------------
export var brewTamlStr = function(code, stub) {
  return `import {TAMLDataStore} from '@jdeighan/starbucks/stores';

export let ${stub} = new TAMLDataStore(\`${code}\`);`;
};

// ---------------------------------------------------------------------------
export var brewTamlFile = function(srcPath, destPath = undef, hOptions = {}) {
  var hInfo, jsCode, stub, tamlCode;
  if (destPath == null) {
    destPath = withExt(srcPath, '.js', {
      removeLeadingUnderScore: true
    });
  }
  if (hOptions.force || !newerDestFileExists(srcPath, destPath)) {
    hInfo = pathlib.parse(destPath);
    stub = hInfo.name;
    tamlCode = slurp(srcPath);
    jsCode = brewTamlStr(tamlCode, stub);
    barf(destPath, jsCode);
  }
};

// ---------------------------------------------------------------------------
