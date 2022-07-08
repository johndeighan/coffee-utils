# SectionMap.coffee

import {
	assert, pass, undef, defined, croak, OL, isEmpty, nonEmpty,
	isString, isHash, isArray, isUniqueTree, isNonEmptyString,
	} from '@jdeighan/coffee-utils'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'
import {debug} from '@jdeighan/coffee-utils/debug'
import {Section} from '@jdeighan/coffee-utils/section'

# ---------------------------------------------------------------------------

isSectionName = (name) ->

	assert isString(name), "not a string"
	return name.match(/^[a-z][a-z0-9]*/)

# ---------------------------------------------------------------------------

isSetName = (name) ->

	assert isString(name), "not a string"
	return name.match(/^[A-Z][a-z0-9]*/)

# ---------------------------------------------------------------------------

export class SectionMap

	constructor: (lSections) ->
		# --- lSections is a tree of section names

		debug "enter SectionMap()", lSections
		@lSections = lSections   # a tree of section names
		@hSets = {}
		@hSections = {}
		@addSections lSections
		debug "return from SectionMap()", @hSections

	# ..........................................................

	# --- TODO: Allow array to start with a set name ---

	addSections: (desc) ->

		if isString(desc)
			assert nonEmpty(desc), "empty section name"
			assert desc.match(/^[a-z][a-z0-9]*$/), "bad section name #{OL(desc)}"
			assert (@hSections[desc] == undef), "duplicate section #{OL(desc)}"
			@hSections[desc] = new Section()
		else
			assert isArray(desc), "not an array or string #{OL(desc)}"
			for item in desc
				@addSections item
		return

	# ..........................................................
	# --- a generator - yield order is not guaranteed

	allSections: (desc) ->

		debug "enter allSections()"
		if (desc == undef)
			# --- We want to return all sections
			debug "yield all sections"
			for _,sect of @hSections
				yield sect
		else if isString(desc)
			if isSectionName(desc)
				debug "yield section #{OL(desc)}"
				yield @section(desc)
			else if isSetName(desc)
				debug "expand set #{OL(desc)}"
				debug 'hSets', @hSets
				lNames = @hSets[desc]
				assert defined(lNames), "no set named #{OL(desc)}"
				debug "set #{desc}", lNames
				for name in lNames
					debug "yield section #{OL(desc)}"
					yield @section(name)
			else
				croak "bad name #{OL(desc)}"
		else
			assert isArray(desc), "not an array"
			for name in desc
				debug "yield section #{OL(name)}"
				assert isString(name), "not a string #{OL(name)}"
				if isSectionName(name)
					yield @section(name)
				else if isSetName(name)
					for _,sect of @hSets[name]
						yield sect
				else
					croak "bad name #{OL(name)}"
		debug "return from allSections()"
		return

	# ..........................................................

	addSet: (name, lSections) ->

		debug "enter addSet()", name, lSections

		# --- check the name
		assert isSetName(name), "not a valid set name #{OL(name)}"

		# --- check lSections
		assert isArray(lSections), "arg 2 not an array"
		for secName in lSections
			assert isNonEmptyString(secName),
					"not a non-empty string #{OL(secName)}"
			assert defined(@hSections[secName]),
					"not a section name #{OL(secName)}"

		@hSets[name] = lSections
		debug 'hSets', @hSets
		debug "return from addSet()"
		return

	# ..........................................................

	section: (name) ->

		sect = @hSections[name]
		assert defined(sect), "No section named #{OL(name)}"
		return sect

	# ..........................................................

	firstSection: (name) ->

		assert isSetName(name), "bad set name #{OL(name)}"
		lSections = @hSets[name]
		assert defined(lSections), "no such set #{OL(name)}"
		assert nonEmpty(lSections), "empty section #{OL(name)}"
		return @section(lSections[0])

	# ..........................................................

	lastSection: (name) ->

		assert isSetName(name), "bad set name #{OL(name)}"
		lSections = @hSets[name]
		assert defined(lSections), "no such set #{OL(name)}"
		assert nonEmpty(lSections), "empty section #{OL(name)}"
		return @section(lSections[lSections.length - 1])

	# ..........................................................

	length: (desc=undef) ->

		result = 0
		for sect from @allSections(desc)
			result += sect.length()
		return result

	# ..........................................................

	isEmpty: (desc=undef) ->

		return (@length(desc) == 0)

	# ..........................................................

	nonEmpty: (desc=undef) ->

		return (@length(desc) > 0)

	# ..........................................................

	indent: (desc=undef, level=1) ->

		for sect from @allSections(desc)
			sect.indent(level)
		return

	# ..........................................................

	enclose: (name, pre, post) ->

		if isSectionName(name)
			sect = @section(name)
			if sect.nonEmpty()
				sect.indent()
				sect.prepend(pre)
				sect.add(post)
		else if isSetName(name)
			if @nonEmpty(name)
				@indent(name)
				@firstSection(name).prepend(pre)
				@lastSection(name).add(post)
		else
			croak "Bad name param #{OL(name)}"
		return

	# ..........................................................

	getBlock: () ->

		debug "enter getBlock()"
		@lAllBlocks = []
		debug 'lSections', @lSections
		@accumBlock @lSections
		debug 'lAllBlocks', @lAllBlocks
		result = arrayToBlock(@lAllBlocks)
		debug "return from getBlock()", result
		return result

	# ..........................................................

	accumBlock: (tree) ->

		if isString(tree)
			debug "accumBlock #{OL(tree)}"
			block = @section(tree).getBlock()
			if nonEmpty(block)
				@lAllBlocks.push block
		else
			assert isArray(tree), "not an array"
			for subtree in tree
				@accumBlock subtree
		return
