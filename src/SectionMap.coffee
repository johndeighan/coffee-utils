# SectionMap.coffee

import {
	assert, croak, LOG, LOGVALUE, LOGTAML, debug, isTAML, fromTAML,
	} from '@jdeighan/exceptions'
import {
	pass, undef, def, notdef, OL, isEmpty, nonEmpty,
	isString, isHash, isArray, isUniqueTree, isNonEmptyString,
	isNonEmptyArray, isFunction, jsType, isArrayOfStrings,
	} from '@jdeighan/coffee-utils'
import {toBlock} from '@jdeighan/coffee-utils/block'
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

		debug "enter SectionMap()", tree, @hReplacers

		@checkTree tree
		@checkReplacers @hReplacers

		@hSections = {}            # --- {section name: Section Object}
		@hSets = {ALL: @lFullTree} # --- {set name: array of parts}

		@init @lFullTree

		debug 'hSections', @hSections
		debug 'hSets', @hSets
		debug "return from SectionMap()"

	# ..........................................................

	init: (lTree) ->

		debug "enter init()", lTree
		assert isArray(lTree), "not an array"
		assert nonEmpty(lTree), "empty array"

		firstItem = lTree[0]
		if isSetName(firstItem)
			debug "found set name #{OL(firstItem)}"
			lTree = lTree.slice(1)
			@mkSet firstItem, lTree

		for item in lTree
			if isArray(item)
				debug "init subtree"
				@init item
			else if isSectionName(item)
				debug "mkSection #{OL(item)}"
				@mkSection item
			else
				assert isString(item), "Bad item in tree: #{OL(item)}"
		debug "return from init()"
		return

	# ..........................................................

	mkSet: (name, lTree) ->

		assert isArray(lTree), "tree is not an array"
		assert nonEmpty(lTree), "set without sections"
		assert notdef(@hSets[name]), "set #{OL(name)} already exists"
		@hSets[name] = lTree
		return

	# ..........................................................

	mkSection: (name) ->

		assert notdef(@hSections[name]), "duplicate section name"
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

		if isString(desc)
			debug "enter SectionMap.getBlock(#{OL(desc)})"
		else if isArrayOfStrings(desc)
			debug "enter SectionMap.getBlock()", desc
		else
			croak "Bad desc: #{OL(desc)}"

		if isSectionName(desc)
			debug "item is a section name"
			# --- a section's getBlock() applies any replacer
			block = @section(desc).getBlock()
		else if isSetName(desc)
			debug "item is a set name"
			lBlocks = for item in @hSets[desc]
				if isArray(item)
					@getBlock item[0]
				else if isString(item)
					@getBlock item
				else
					croak "Item in set #{desc} is not a string or array"
			block = toBlock(lBlocks)
			replacer = @hReplacers[desc]
			debug "replacer for is #{OL(replacer)}"
			if def(replacer)
				block = replacer(block)
		else if isString(desc)
			debug "item is a literal string"
			# --- a literal string
			block = desc
		else if isArray(desc)
			debug "item is an array"
			lBlocks = for item in desc
				@getBlock(item)
			block = toBlock(lBlocks)
		else
			croak "Bad arg: #{OL(desc)}"

		debug "return from SectionMap.getBlock()", block
		return block

	# ..........................................................
	# --- does NOT call any replacers, and skips literal strings
	#     so only useful for isEmpty() and nonEmpty()

	allSections: (desc=undef) ->

		debug "enter allSections()", desc
		if notdef(desc)
			desc = @lFullTree

		if isSectionName(desc)
			debug "is section name"
			yield @section(desc)
		else if isSetName(desc)
			debug "is set name"
			for name in @hSets[desc]
				yield from @allSections(name)
		else if isArray(desc)
			debug "is array"
			for item in desc
				yield from @allSections(item)
		debug "return from allSections()"
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
		assert def(sect), "No section named #{OL(name)}"
		return sect

	# ..........................................................

	firstSection: (name) ->

		assert isSetName(name), "bad set name #{OL(name)}"
		lSubTree = @hSets[name]
		assert def(lSubTree), "no such set #{OL(name)}"
		return @section(lSubTree[0])

	# ..........................................................

	lastSection: (name) ->

		assert isSetName(name), "bad set name #{OL(name)}"
		lSubTree = @hSets[name]
		assert def(lSubTree), "no such set #{OL(name)}"
		return @section(lSubTree[lSubTree.length - 1])

	# ..........................................................

	checkTree: (tree) ->

		debug "enter checkTree()"
		if isString(tree)
			debug "tree is a string"
			assert isTAML(tree), "not TAML"
			@lFullTree = fromTAML(tree)
		else
			@lFullTree = tree

		assert isArray(@lFullTree), "not an array"
		assert nonEmpty(@lFullTree), "tree is empty"
		if isSetName(@lFullTree[0])
			LOGTAML 'lFullTree', @lFullTree
			croak "tree cannot begin with a set name"
		debug "return from checkTree()"
		return

	# ..........................................................

	checkReplacers: (h) ->

		assert isHash(h), "replacers is not a hash"
		for key,func of h
			assert isSetName(key) || isSectionName(key), "bad replacer key"
			assert isFunction(func),
					"replacer for #{OL(key)} is not a function"
		return

