// Generated by CoffeeScript 2.7.0
// SectionMap.coffee
var isSectionName, isSetName;

import {
  assert,
  croak,
  LOG,
  LOGVALUE,
  LOGTAML,
  debug,
  isTAML,
  fromTAML
} from '@jdeighan/exceptions';

import {
  pass,
  undef,
  def,
  notdef,
  OL,
  isEmpty,
  nonEmpty,
  isString,
  isHash,
  isArray,
  isUniqueTree,
  isNonEmptyString,
  isNonEmptyArray,
  isFunction,
  jsType,
  isArrayOfStrings
} from '@jdeighan/coffee-utils';

import {
  toBlock
} from '@jdeighan/coffee-utils/block';

import {
  Section
} from '@jdeighan/coffee-utils/section';

// ---------------------------------------------------------------------------
isSectionName = function(name) {
  return isString(name) && name.match(/^[a-z][a-z0-9_]*/);
};

// ---------------------------------------------------------------------------
isSetName = function(name) {
  return isString(name) && name.match(/^[A-Z][a-z0-9_]*/);
};

// ---------------------------------------------------------------------------
export var SectionMap = class SectionMap {
  constructor(tree, hReplacers = {}) {
    this.hReplacers = hReplacers;
    // --- tree is a tree of section/set names
    //        or a TAML string that converts to one
    // --- hReplacers are callbacks that are called
    //        when a set or section is processed
    //        should be <name> -> <function>
    //     <name> can be a section name or a set name
    //     <function> should be <block> -> <block>
    debug("enter SectionMap()", tree, this.hReplacers);
    this.checkTree(tree);
    this.checkReplacers(this.hReplacers);
    this.hSections = {}; // --- {section name: Section Object}
    this.hSets = {
      ALL: this.lFullTree // --- {set name: array of parts}
    };
    this.init(this.lFullTree);
    debug('hSections', this.hSections);
    debug('hSets', this.hSets);
    debug("return from SectionMap()");
  }

  // ..........................................................
  init(lTree) {
    var firstItem, i, item, len;
    debug("enter init()", lTree);
    assert(isArray(lTree), "not an array");
    assert(nonEmpty(lTree), "empty array");
    firstItem = lTree[0];
    if (isSetName(firstItem)) {
      debug(`found set name ${OL(firstItem)}`);
      lTree = lTree.slice(1);
      this.mkSet(firstItem, lTree);
    }
    for (i = 0, len = lTree.length; i < len; i++) {
      item = lTree[i];
      if (isArray(item)) {
        debug("init subtree");
        this.init(item);
      } else if (isSectionName(item)) {
        debug(`mkSection ${OL(item)}`);
        this.mkSection(item);
      } else {
        assert(isString(item), `Bad item in tree: ${OL(item)}`);
      }
    }
    debug("return from init()");
  }

  // ..........................................................
  mkSet(name, lTree) {
    assert(isArray(lTree), "tree is not an array");
    assert(nonEmpty(lTree), "set without sections");
    assert(notdef(this.hSets[name]), `set ${OL(name)} already exists`);
    this.hSets[name] = lTree;
  }

  // ..........................................................
  mkSection(name) {
    assert(notdef(this.hSections[name]), "duplicate section name");
    this.hSections[name] = new Section(name, this.hReplacers[name]);
  }

  // ..........................................................
  getBlock(desc = 'ALL') {
    var block, item, lBlocks, replacer;
    // ..........................................................
    // --- desc can be:
    //        a section name
    //        a set name
    //        an array of section or set names or literal strings
    //     i.e. it should NOT contain sub-arrays
    if (isString(desc)) {
      debug(`enter SectionMap.getBlock(${OL(desc)})`);
    } else if (isArrayOfStrings(desc)) {
      debug("enter SectionMap.getBlock()", desc);
    } else {
      croak(`Bad desc: ${OL(desc)}`);
    }
    if (isSectionName(desc)) {
      debug("item is a section name");
      // --- a section's getBlock() applies any replacer
      block = this.section(desc).getBlock();
    } else if (isSetName(desc)) {
      debug("item is a set name");
      lBlocks = (function() {
        var i, len, ref, results;
        ref = this.hSets[desc];
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          item = ref[i];
          if (isArray(item)) {
            results.push(this.getBlock(item[0]));
          } else if (isString(item)) {
            results.push(this.getBlock(item));
          } else {
            results.push(croak(`Item in set ${desc} is not a string or array`));
          }
        }
        return results;
      }).call(this);
      block = toBlock(lBlocks);
      replacer = this.hReplacers[desc];
      debug(`replacer for is ${OL(replacer)}`);
      if (def(replacer)) {
        block = replacer(block);
      }
    } else if (isString(desc)) {
      debug("item is a literal string");
      // --- a literal string
      block = desc;
    } else if (isArray(desc)) {
      debug("item is an array");
      lBlocks = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = desc.length; i < len; i++) {
          item = desc[i];
          results.push(this.getBlock(item));
        }
        return results;
      }).call(this);
      block = toBlock(lBlocks);
    } else {
      croak(`Bad arg: ${OL(desc)}`);
    }
    debug("return from SectionMap.getBlock()", block);
    return block;
  }

  // ..........................................................
  // --- does NOT call any replacers, and skips literal strings
  //     so only useful for isEmpty() and nonEmpty()
  * allSections(desc = undef) {
    var i, item, j, len, len1, name, ref;
    debug("enter allSections()", desc);
    if (notdef(desc)) {
      desc = this.lFullTree;
    }
    if (isSectionName(desc)) {
      debug("is section name");
      yield this.section(desc);
    } else if (isSetName(desc)) {
      debug("is set name");
      ref = this.hSets[desc];
      for (i = 0, len = ref.length; i < len; i++) {
        name = ref[i];
        yield* this.allSections(name);
      }
    } else if (isArray(desc)) {
      debug("is array");
      for (j = 0, len1 = desc.length; j < len1; j++) {
        item = desc[j];
        yield* this.allSections(item);
      }
    }
    debug("return from allSections()");
  }

  // ..........................................................
  isEmpty(desc = undef) {
    var ref, sect;
    ref = this.allSections(desc);
    for (sect of ref) {
      if (sect.nonEmpty()) {
        return false;
      }
    }
    return true;
  }

  // ..........................................................
  nonEmpty(desc = undef) {
    var ref, sect;
    ref = this.allSections(desc);
    for (sect of ref) {
      if (sect.nonEmpty()) {
        return true;
      }
    }
    return false;
  }

  // ..........................................................
  section(name) {
    var sect;
    sect = this.hSections[name];
    assert(def(sect), `No section named ${OL(name)}`);
    return sect;
  }

  // ..........................................................
  firstSection(name) {
    var lSubTree;
    assert(isSetName(name), `bad set name ${OL(name)}`);
    lSubTree = this.hSets[name];
    assert(def(lSubTree), `no such set ${OL(name)}`);
    return this.section(lSubTree[0]);
  }

  // ..........................................................
  lastSection(name) {
    var lSubTree;
    assert(isSetName(name), `bad set name ${OL(name)}`);
    lSubTree = this.hSets[name];
    assert(def(lSubTree), `no such set ${OL(name)}`);
    return this.section(lSubTree[lSubTree.length - 1]);
  }

  // ..........................................................
  checkTree(tree) {
    debug("enter checkTree()");
    if (isString(tree)) {
      debug("tree is a string");
      assert(isTAML(tree), "not TAML");
      this.lFullTree = fromTAML(tree);
    } else {
      this.lFullTree = tree;
    }
    assert(isArray(this.lFullTree), "not an array");
    assert(nonEmpty(this.lFullTree), "tree is empty");
    if (isSetName(this.lFullTree[0])) {
      LOGTAML('lFullTree', this.lFullTree);
      croak("tree cannot begin with a set name");
    }
    debug("return from checkTree()");
  }

  // ..........................................................
  checkReplacers(h) {
    var func, key;
    assert(isHash(h), "replacers is not a hash");
    for (key in h) {
      func = h[key];
      assert(isSetName(key) || isSectionName(key), "bad replacer key");
      assert(isFunction(func), `replacer for ${OL(key)} is not a function`);
    }
  }

};
