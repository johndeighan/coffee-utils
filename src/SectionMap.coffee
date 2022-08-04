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

	getBlock: (desc=undef, hProcs={}) ->

		debug "enter SectionMap.getBlock()", desc, hProcs

		if notdefined(desc)
			desc = @lSectionTree

		if isArray(desc)
			lBlocks = []
			setName = undef
			for item in desc
				if isArray(item) || isSectionName(item)
					# --- arrayToBlock() will skip undef items
					#     so, no need to check for undef block
					lBlocks.push @getBlock(item, hProcs)
				else if isSetName(item)
					setName = item
				else if isString(item)
					lBlocks.push item   # a literal string
				else
					croak "Bad item: #{OL(item)}"
			block = arrayToBlock(lBlocks)
		else if isSectionName(desc)
			block = @section(desc).getBlock()
			if defined(proc = hProcs[desc])
				block = proc(block)
		else if isSetName(desc)
			# --- pass array to getBlock()
			block = @getBlock(@hSets[desc], hProcs)
			if defined(proc = hProcs[desc])
				block = proc(block)
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
