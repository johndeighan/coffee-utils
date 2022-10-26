# SectionMap.coffee

import {assert, croak} from '@jdeighan/exceptions'
import {LOG} from '@jdeighan/exceptions/log'
import {debug} from '@jdeighan/exceptions/debug'
import {
	pass, undef, defined, notdefined, OL, isEmpty, nonEmpty,
	isString, isHash, isArray, isUniqueTree, isNonEmptyString,
	isNonEmptyArray,
	} from '@jdeighan/coffee-utils'
import {toBlock} from '@jdeighan/coffee-utils/block'
import {isTAML, fromTAML} from '@jdeighan/coffee-utils/taml'
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
			@SectionTree = fromTAML(@lSectionTree)

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

	getBlock: (desc=undef, hReplacers={}) ->
		# ..........................................................
		# --- hReplacers are callbacks that are called
		#        when a set or section is processed
		#        should be <name> -> <function>
		#     <name> can be a section name or a set name
		#     <function> should be <block> -> <block>
		# --- desc can be:
		#        undef - same as the array @lSectionTree
		#        a section name
		#        a set name
		#        an array, which may begin with a set name


		debug "enter SectionMap.getBlock()", desc, hReplacers

		# --- desc can only be a string or an array
		assert ! isHash(desc), "hash as 1st parameter is deprecated"

		if notdefined(desc)
			debug "desc is entire tree"
			desc = @lSectionTree

		if isSectionName(desc)
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
		else if isArray(desc)
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

			block = toBlock(lBlocks)
			debug "block is", block
			if defined(setName)
				if defined(proc = hReplacers[setName])
					block = proc(block)
					debug "REPLACE #{setName} with", block
				else
					debug "NO REPLACER for #{setName}"
		else
			croak "Bad 1st arg: #{OL(desc)}"
		debug "return from SectionMap.getBlock()", block
		return block

	# ..........................................................

	allSections: (desc=undef) ->

		if notdefined(desc)
			desc = @lSectionTree
		if isSectionName(desc)
			yield @section(desc)
		else if isSetName(desc)
			yield from @allSections(@hSets[desc])
		else if isArray(desc)
			for item in desc
				yield from @allSections(item)
		return

	# ..........................................................

	isEmpty: (desc=undef) ->

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
