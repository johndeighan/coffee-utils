// Generated by CoffeeScript 2.7.0
// SectionMap.coffee
var isSectionName, isSetName;

import {
  assert,
  error,
  croak
} from '@jdeighan/unit-tester/utils';

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
  isUniqueTree,
  isNonEmptyString,
  isNonEmptyArray
} from '@jdeighan/coffee-utils';

import {
  arrayToBlock
} from '@jdeighan/coffee-utils/block';

import {
  indented
} from '@jdeighan/coffee-utils/indent';

import {
  LOG
} from '@jdeighan/coffee-utils/log';

import {
  debug
} from '@jdeighan/coffee-utils/debug';

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
  constructor(lSectionTree) {
    this.lSectionTree = lSectionTree;
    // --- lSectionTree is a tree of section/set names
    debug("enter SectionMap()", this.lSectionTree);
    assert(isArray(this.lSectionTree), "not an array");
    // --- keys are section names, values are Section objects
    this.hSections = {};
    // --- keys are set names, values are subtrees of lSectionTree
    this.hSets = {};
    this.build(this.lSectionTree);
    debug("return from SectionMap()", this.hSections);
  }

  // ..........................................................
  build(lTree) {
    var firstItem, i, item, j, len, len1, ref;
    debug("enter build()", lTree);
    assert(isArray(lTree), "not an array");
    assert(nonEmpty(lTree), "empty array");
    firstItem = lTree[0];
    if (isSetName(firstItem)) {
      assert(lTree.length >= 2, "set without sections");
      this.hSets[firstItem] = lTree;
      ref = lTree.slice(1);
      for (i = 0, len = ref.length; i < len; i++) {
        item = ref[i];
        if (isArray(item)) {
          this.build(item);
        } else if (isSectionName(item)) {
          this.hSections[item] = new Section(item);
        } else if (!isString(item)) { // string would be literal
          croak(`Bad section tree: ${OL(this.lSectionTree)}`);
        }
      }
    } else {
      for (j = 0, len1 = lTree.length; j < len1; j++) {
        item = lTree[j];
        if (isArray(item)) {
          this.build(item);
        } else if (isSectionName(item)) {
          this.hSections[item] = new Section(item);
        } else {
          croak(`Bad section tree: ${OL(this.lSectionTree)}`);
        }
      }
    }
    debug("return from build()", this.hSections, this.hSets);
  }

  // ..........................................................
  // --- hProc should be <name> -> <function>
  //     <name> can be a section name or a set name
  //     <function> should be <block> -> <block>
  // --- desc can be:
  //        an array, which may begin with a set name
  //        a section name
  //        a set name
  //        undef (equivalent to being set to @SectionTree)
  getBlock(desc = undef, hReplacers = {}) {
    var block, i, item, lBlocks, len, proc, setName, subBlock;
    debug("enter SectionMap.getBlock()", desc, hReplacers);
    // --- desc can only be a string or an array
    //     so, if it's a hash, then it's really the hReplacers
    //     and the real desc is undef
    if (isHash(desc)) {
      debug("arg 1 is hReplacers, no desc");
      assert(isEmpty(hReplacers), "invalid parms");
      hReplacers = desc;
      desc = this.lSectionTree;
    } else if (notdefined(desc)) {
      desc = this.lSectionTree;
    }
    if (isArray(desc)) {
      lBlocks = [];
      setName = undef;
      for (i = 0, len = desc.length; i < len; i++) {
        item = desc[i];
        subBlock = undef;
        if (isArray(item)) {
          subBlock = this.getBlock(item, hReplacers);
        } else if (isSectionName(item)) {
          subBlock = this.getBlock(item, hReplacers);
        } else if (isSetName(item)) {
          setName = item;
        } else if (isString(item)) {
          subBlock = item; // a literal string
        } else {
          croak(`Bad item: ${OL(item)}`);
        }
        if (defined(subBlock)) {
          lBlocks.push(subBlock);
        }
      }
      block = arrayToBlock(lBlocks);
      if (defined(setName)) {
        if (defined(proc = hReplacers[setName])) {
          debug(`REPLACE ${setName}`);
          block = proc(block);
        } else {
          debug(`NO REPLACER for ${setName}`);
        }
      }
    } else if (isSectionName(desc)) {
      block = this.section(desc).getBlock();
      if (defined(proc = hReplacers[desc])) {
        debug(`REPLACE ${desc}`);
        block = proc(block);
      } else {
        debug(`NO REPLACER for ${desc}`);
      }
    } else if (isSetName(desc)) {
      // --- pass array to getBlock()
      block = this.getBlock(this.hSets[desc], hReplacers);
    } else {
      croak(`Bad 1st arg: ${OL(desc)}`);
    }
    debug("return from SectionMap.getBlock()", block);
    return block;
  }

  // ..........................................................
  isEmpty() {
    var name, ref, sect;
    ref = this.hSections;
    for (name in ref) {
      sect = ref[name];
      if (sect.nonEmpty()) {
        return false;
      }
    }
    return true;
  }

  // ..........................................................
  nonEmpty() {
    var name, ref, sect;
    ref = this.hSections;
    for (name in ref) {
      sect = ref[name];
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
    return this.section(lSubTree[1]);
  }

  // ..........................................................
  lastSection(name) {
    var lSubTree;
    assert(isSetName(name), `bad set name ${OL(name)}`);
    lSubTree = this.hSets[name];
    assert(defined(lSubTree), `no such set ${OL(name)}`);
    return this.section(lSubTree[lSubTree.length - 1]);
  }

};
