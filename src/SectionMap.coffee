# SectionMap.coffee

import {
	pass, undef, defined, notdefined, OL, isEmpty, nonEmpty,
	isString, isHash, isArray, isNonEmptyString,
	isFunction, jsType, toBlock, isArrayOfStrings, isNonEmptyArray,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG, LOGVALUE, LOGTAML} from '@jdeighan/base-utils/log'
import {
	dbg, dbgEnter, dbgReturn, dbgYield, dbgResume,
	} from '@jdeighan/base-utils/debug'
import {isTAML, fromTAML} from '@jdeighan/base-utils/taml'

import {Section} from '@jdeighan/coffee-utils/section'

# ---------------------------------------------------------------------------

isSectionName = (name) ->

	return isString(name) && name.match(/^[a-z][a-z0-9_]*/)

# ---------------------------------------------------------------------------

isSetName = (name) ->

	return isString(name) && name.match(/^[A-Z][a-z0-9_]*/)

# ---------------------------------------------------------------------------

export class SectionMap

	constructor: (tree, @hReplacers={}) ->
		# --- tree is a tree of section/set names
		#        or a TAML string that converts to one
		# --- hReplacers are callbacks that are called
		#        when a set or section is processed
		#        should be <name> -> <function>
		#     <name> can be a section name or a set name
		#     <function> should be <block> -> <block>

		dbgEnter "SectionMap", tree, @hReplacers

		@checkTree tree
		@checkReplacers @hReplacers

		@hSections = {}            # --- {section name: Section Object}
		@hSets = {ALL: @lFullTree} # --- {set name: array of parts}

		@init @lFullTree

		dbg 'hSections', @hSections
		dbg 'hSets', @hSets
		dbgReturn "SectionMap"

	# ..........................................................

	init: (lTree) ->

		dbgEnter "init", lTree
		assert isArray(lTree), "not an array"
		assert nonEmpty(lTree), "empty array"

		firstItem = lTree[0]
		if isSetName(firstItem)
			dbg "found set name #{OL(firstItem)}"
			lTree = lTree.slice(1)
			@mkSet firstItem, lTree

		for item in lTree
			if isArray(item)
				dbg "init subtree"
				@init item
			else if isSectionName(item)
				dbg "mkSection #{OL(item)}"
				@mkSection item
			else
				assert isString(item), "Bad item in tree: #{OL(item)}"
		dbgReturn "init"
		return

	# ..........................................................

	mkSet: (name, lTree) ->

		assert isArray(lTree), "tree is not an array"
		assert nonEmpty(lTree), "set without sections"
		assert notdefined(@hSets[name]), "set #{OL(name)} already exists"
		@hSets[name] = lTree
		return

	# ..........................................................

	mkSection: (name) ->

		assert notdefined(@hSections[name]), "duplicate section name"
		@hSections[name] = new Section(name, @hReplacers[name])
		return

	# ..........................................................

	getBlock: (desc='ALL') ->
		# ..........................................................
		# --- desc can be:
		#        a section name
		#        a set name
		#        an array of section or set names or literal strings
		#     i.e. it should NOT contain sub-arrays

		dbgEnter "SectionMap.getBlock", desc
		if ! isString(desc) && ! isArrayOfStrings(desc)
			croak "Bad desc: #{OL(desc)}"

		if isSectionName(desc)
			dbg "item is a section name"
			# --- a section's getBlock() applies any replacer
			block = @section(desc).getBlock()
		else if isSetName(desc)
			dbg "item is a set name"
			lBlocks = for item in @hSets[desc]
				if isArray(item)
					@getBlock item[0]
				else if isString(item)
					@getBlock item
				else
					croak "Item in set #{desc} is not a string or array"
			block = toBlock(lBlocks)
			replacer = @hReplacers[desc]
			dbg "replacer for is #{OL(replacer)}"
			if defined(replacer)
				block = replacer(block)
		else if isString(desc)
			dbg "item is a literal string"
			# --- a literal string
			block = desc
		else if isArray(desc)
			dbg "item is an array"
			lBlocks = for item in desc
				@getBlock(item)
			block = toBlock(lBlocks)
		else
			croak "Bad arg: #{OL(desc)}"

		dbgReturn "SectionMap.getBlock", block
		return block

	# ..........................................................
	# --- does NOT call any replacers, and skips literal strings
	#     so only useful for isEmpty() and nonEmpty()

	allSections: (desc=undef) ->

		dbgEnter "allSections", desc
		if notdefined(desc)
			desc = @lFullTree

		if isSectionName(desc)
			dbg "is section name"
			dbgYield "allSections", @section(desc)
			yield @section(desc)
			dbgResume "allSections"
		else if isSetName(desc)
			dbg "is set name"
			for name in @hSets[desc]
				dbgYield "allSections"
				yield from @allSections(name)
				dbgResume "allSections"
		else if isArray(desc)
			dbg "is array"
			for item in desc
				dbgYield "allSections"
				yield from @allSections(item)
				dbgResume "allSections"
		dbgReturn "allSections"
		return

	# ..........................................................

	isEmpty: (desc=undef) ->

		for sect from @allSections(desc)
			if sect.nonEmpty()
				return false
		return true

	# ..........................................................

	nonEmpty: (desc=undef) ->

		for sect from @allSections(desc)
			if sect.nonEmpty()
				return true
		return false

	# ..........................................................

	section: (name) ->

		sect = @hSections[name]
		assert defined(sect), "No section named #{OL(name)}"
		return sect

	# ..........................................................

	firstSection: (name) ->

		assert isSetName(name), "bad set name #{OL(name)}"
		lSubTree = @hSets[name]
		assert defined(lSubTree), "no such set #{OL(name)}"
		return @section(lSubTree[0])

	# ..........................................................

	lastSection: (name) ->

		assert isSetName(name), "bad set name #{OL(name)}"
		lSubTree = @hSets[name]
		assert defined(lSubTree), "no such set #{OL(name)}"
		return @section(lSubTree[lSubTree.length - 1])

	# ..........................................................

	checkTree: (tree) ->

		dbgEnter "checkTree"
		if isString(tree)
			dbg "tree is a string"
			assert isTAML(tree), "not TAML"
			@lFullTree = fromTAML(tree)
		else
			@lFullTree = tree

		assert isArray(@lFullTree), "not an array"
		assert nonEmpty(@lFullTree), "tree is empty"
		if isSetName(@lFullTree[0])
			LOGTAML 'lFullTree', @lFullTree
			croak "tree cannot begin with a set name"
		dbgReturn "checkTree"
		return

	# ..........................................................

	checkReplacers: (h) ->

		assert isHash(h), "replacers is not a hash"
		for key,func of h
			assert isSetName(key) || isSectionName(key), "bad replacer key"
			assert isFunction(func),
					"replacer for #{OL(key)} is not a function"
		return

