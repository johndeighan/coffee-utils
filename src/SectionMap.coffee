# SectionMap.coffee

import {assert, error, croak} from '@jdeighan/unit-tester/utils'
import {
	pass, undef, defined, notdefined, OL, isEmpty, nonEmpty,
	isString, isHash, isArray, isUniqueTree, isNonEmptyString,
	isNonEmptyArray,
	} from '@jdeighan/coffee-utils'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'
import {indented} from '@jdeighan/coffee-utils/indent'
import {LOG} from '@jdeighan/coffee-utils/log'
import {debug} from '@jdeighan/coffee-utils/debug'
import {isTAML, taml} from '@jdeighan/coffee-utils/taml'
import {Section} from '@jdeighan/coffee-utils/section'

# ---------------------------------------------------------------------------

isSectionName = (name) ->

	return isString(name) && name.match(/^[a-z][a-z0-9_]*/)

# ---------------------------------------------------------------------------

isSetName = (name) ->

	return isString(name) && name.match(/^[A-Z][a-z0-9_]*/)

# ---------------------------------------------------------------------------

export class SectionMap

	constructor: (@lSectionTree) ->
		# --- lSectionTree is a tree of section/set names

		debug "enter SectionMap()", @lSectionTree

		if isTAML(@lSectionTree)
			@SectionTree = taml(@lSectionTree)

		assert isArray(@lSectionTree), "not an array"

		# --- keys are section names, values are Section objects
		@hSections = {}

		# --- keys are set names, values are subtrees of lSectionTree
		@hSets = {}

		@build @lSectionTree
		debug "return from SectionMap()", @hSections

	# ..........................................................

	build: (lTree) ->

		debug "enter build()", lTree
		assert isArray(lTree), "not an array"
		assert nonEmpty(lTree), "empty array"

		firstItem = lTree[0]
		if isSetName(firstItem)
			assert (lTree.length >= 2), "set without sections"
			@hSets[firstItem] = lTree
			for item in lTree.slice(1)
				if isArray(item)
					@build item
				else if isSectionName(item)
					@hSections[item] = new Section(item)
				else if ! isString(item)    # string would be literal
					croak "Bad section tree: #{OL(@lSectionTree)}"
		else
			for item in lTree
				if isArray(item)
					@build item
				else if isSectionName(item)
					@hSections[item] = new Section(item)
				else
					croak "Bad section tree: #{OL(@lSectionTree)}"
		debug "return from build()", @hSections, @hSets
		return

	# ..........................................................
	# --- hProc should be <name> -> <function>
	#     <name> can be a section name or a set name
	#     <function> should be <block> -> <block>
	# --- desc can be:
	#        an array, which may begin with a set name
	#        a section name
	#        a set name
	#        undef (equivalent to being set to @SectionTree)

	getBlock: (desc=undef, hReplacers={}) ->

		debug "enter SectionMap.getBlock()", desc, hReplacers

		# --- desc can only be a string or an array
		#     so, if it's a hash, then it's really the hReplacers
		#     and the real desc is undef

		if isHash(desc)
			debug "arg 1 is hReplacers, no desc"
			assert isEmpty(hReplacers), "invalid parms"
			hReplacers = desc
			desc = @lSectionTree
		else if notdefined(desc)
			debug "desc is entire tree"
			desc = @lSectionTree

		if isArray(desc)
			debug "item is an array"
			lBlocks = []
			setName = undef
			for item in desc
				subBlock = undef
				if isSetName(item)
					debug "set name is #{item}"
					setName = item
				else if isSectionName(item) || isArray(item)
					subBlock = @getBlock(item, hReplacers)
					if defined(subBlock)
						debug "add subBlock", subBlock
						lBlocks.push subBlock
					else
						debug "subBlock is undef"
				else if isString(item) && nonEmpty(item)
					debug "add string", item
					lBlocks.push item
				else
					croak "Bad item: #{OL(item)}"

			block = arrayToBlock(lBlocks)
			debug "block is", block
			if defined(setName)
				if defined(proc = hReplacers[setName])
					block = proc(block)
					debug "REPLACE #{setName} with", block
				else
					debug "NO REPLACER for #{setName}"
		else if isSectionName(desc)
			debug "item is a section name"
			block = @section(desc).getBlock()
			if defined(proc = hReplacers[desc])
				debug "REPLACE #{desc}"
				block = proc(block)
			else
				debug "NO REPLACER for #{desc}"
		else if isSetName(desc)
			debug "item is a set name"
			block = @getBlock(@hSets[desc], hReplacers)
		else
			croak "Bad 1st arg: #{OL(desc)}"
		debug "return from SectionMap.getBlock()", block
		return block

	# ..........................................................

	isEmpty: () ->

		for name,sect of @hSections
			if sect.nonEmpty()
				return false
		return true

	# ..........................................................

	nonEmpty: () ->

		for name,sect of @hSections
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
		return @section(lSubTree[1])

	# ..........................................................

	lastSection: (name) ->

		assert isSetName(name), "bad set name #{OL(name)}"
		lSubTree = @hSets[name]
		assert defined(lSubTree), "no such set #{OL(name)}"
		return @section(lSubTree[lSubTree.length - 1])
