// Generated by CoffeeScript 2.7.0
// SectionMap.coffee
var isSectionName, isSetName;

import {
  pass,
  undef,
  defined,
  notdefined,
  OL,
  isEmpty,
  nonEmpty,
  isString,
  isHash,
  isArray,
  isNonEmptyString,
  isFunction,
  jsType,
  toBlock,
  isArrayOfStrings,
  isNonEmptyArray
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG,
  LOGVALUE,
  LOGTAML
} from '@jdeighan/base-utils/log';

import {
  dbg,
  dbgEnter,
  dbgReturn,
  dbgYield,
  dbgResume
} from '@jdeighan/base-utils/debug';

import {
  isTAML,
  fromTAML
} from '@jdeighan/base-utils/taml';

import {
  Section
} from '@jdeighan/coffee-utils/section';

// ---------------------------------------------------------------------------
isSectionName = (name) => {
  return isString(name) && name.match(/^[a-z][a-z0-9_]*/);
};

// ---------------------------------------------------------------------------
isSetName = (name) => {
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
    dbgEnter("SectionMap", tree, this.hReplacers);
    this.checkTree(tree);
    this.checkReplacers(this.hReplacers);
    this.hSections = {}; // --- {section name: Section Object}
    this.hSets = {
      ALL: this.lFullTree // --- {set name: array of parts}
    };
    this.init(this.lFullTree);
    dbg('hSections', this.hSections);
    dbg('hSets', this.hSets);
    dbgReturn("SectionMap");
  }

  // ..........................................................
  init(lTree) {
    var firstItem, i, item, len;
    dbgEnter("init", lTree);
    assert(isArray(lTree), "not an array");
    assert(nonEmpty(lTree), "empty array");
    firstItem = lTree[0];
    if (isSetName(firstItem)) {
      dbg(`found set name ${OL(firstItem)}`);
      lTree = lTree.slice(1);
      this.mkSet(firstItem, lTree);
    }
    for (i = 0, len = lTree.length; i < len; i++) {
      item = lTree[i];
      if (isArray(item)) {
        dbg("init subtree");
        this.init(item);
      } else if (isSectionName(item)) {
        dbg(`mkSection ${OL(item)}`);
        this.mkSection(item);
      } else {
        assert(isString(item), `Bad item in tree: ${OL(item)}`);
      }
    }
    dbgReturn("init");
  }

  // ..........................................................
  mkSet(name, lTree) {
    assert(isArray(lTree), "tree is not an array");
    assert(nonEmpty(lTree), "set without sections");
    assert(notdefined(this.hSets[name]), `set ${OL(name)} already exists`);
    this.hSets[name] = lTree;
  }

  // ..........................................................
  mkSection(name) {
    assert(notdefined(this.hSections[name]), "duplicate section name");
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
    dbgEnter("SectionMap.getBlock", desc);
    if (!isString(desc) && !isArrayOfStrings(desc)) {
      croak(`Bad desc: ${OL(desc)}`);
    }
    if (isSectionName(desc)) {
      dbg("item is a section name");
      // --- a section's getBlock() applies any replacer
      block = this.section(desc).getBlock();
    } else if (isSetName(desc)) {
      dbg("item is a set name");
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
      dbg(`replacer for is ${OL(replacer)}`);
      if (defined(replacer)) {
        block = replacer(block);
      }
    } else if (isString(desc)) {
      dbg("item is a literal string");
      // --- a literal string
      block = desc;
    } else if (isArray(desc)) {
      dbg("item is an array");
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
    dbgReturn("SectionMap.getBlock", block);
    return block;
  }

  // ..........................................................
  // --- does NOT call any replacers, and skips literal strings
  //     so only useful for isEmpty() and nonEmpty()
  * allSections(desc = undef) {
    var i, item, j, len, len1, name, ref;
    dbgEnter("allSections", desc);
    if (notdefined(desc)) {
      desc = this.lFullTree;
    }
    if (isSectionName(desc)) {
      dbg("is section name");
      dbgYield("allSections", this.section(desc));
      yield this.section(desc);
      dbgResume("allSections");
    } else if (isSetName(desc)) {
      dbg("is set name");
      ref = this.hSets[desc];
      for (i = 0, len = ref.length; i < len; i++) {
        name = ref[i];
        dbgYield("allSections");
        yield* this.allSections(name);
        dbgResume("allSections");
      }
    } else if (isArray(desc)) {
      dbg("is array");
      for (j = 0, len1 = desc.length; j < len1; j++) {
        item = desc[j];
        dbgYield("allSections");
        yield* this.allSections(item);
        dbgResume("allSections");
      }
    }
    dbgReturn("allSections");
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
    assert(defined(sect), `No section named ${OL(name)}`);
    return sect;
  }

  // ..........................................................
  firstSection(name) {
    var lSubTree;
    assert(isSetName(name), `bad set name ${OL(name)}`);
    lSubTree = this.hSets[name];
    assert(defined(lSubTree), `no such set ${OL(name)}`);
    return this.section(lSubTree[0]);
  }

  // ..........................................................
  lastSection(name) {
    var lSubTree;
    assert(isSetName(name), `bad set name ${OL(name)}`);
    lSubTree = this.hSets[name];
    assert(defined(lSubTree), `no such set ${OL(name)}`);
    return this.section(lSubTree[lSubTree.length - 1]);
  }

  // ..........................................................
  checkTree(tree) {
    dbgEnter("checkTree");
    if (isString(tree)) {
      dbg("tree is a string");
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
    dbgReturn("checkTree");
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

//# sourceMappingURL=SectionMap.js.map
