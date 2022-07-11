# SectionMap.coffee

import {
	assert, pass, undef, defined, croak, OL, isEmpty, nonEmpty,
	isString, isHash, isArray, isUniqueTree, isNonEmptyString,
	isNonEmptyArray,
	} from '@jdeighan/coffee-utils'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'
import {indented} from '@jdeighan/coffee-utils/indent'
import {debug} from '@jdeighan/coffee-utils/debug'
import {Section} from '@jdeighan/coffee-utils/section'

# ---------------------------------------------------------------------------

isSectionName = (name) ->

	return isString(name) && name.match(/^[a-z][a-z0-9]*/)

# ---------------------------------------------------------------------------

isSetName = (name) ->

	return isString(name) && name.match(/^[A-Z][a-z0-9]*/)

# ---------------------------------------------------------------------------

export class SectionMap

	constructor: (lSectionTree) ->
		# --- lSectionTree is a tree of section names

		debug "enter SectionMap()", lSectionTree
		@lSectionTree = lSectionTree   # a tree of section names
		@hSets = {}
		@hSections = {}
		@addSections lSectionTree
		debug "return from SectionMap()", @hSections

	# ..........................................................

	addSections: (desc) ->
		# --- returns a flat array of sections that were added

		if isString(desc)
			assert nonEmpty(desc), "empty section name"
			assert isSectionName(desc), "bad section name #{OL(desc)}"
			assert (@hSections[desc] == undef), "duplicate section #{OL(desc)}"
			@hSections[desc] = new Section(desc)
			return [desc]
		else
			assert isArray(desc), "not an array or string #{OL(desc)}"
			name = undef
			lParts = []
			for item,i in desc
				if (i==0) && isSetName(item)
					name = item
				else
					lAdded = @addSections item
					for item in lAdded
						lParts.push item
			if defined(name)
				@addSet name, lParts
			return lParts
		return

	# ..........................................................

	addSet: (name, lSectionTree) ->

		debug "enter addSet()", name, lSectionTree

		# --- check the name
		assert isSetName(name), "not a valid set name #{OL(name)}"

		# --- check lSectionTree
		assert isArray(lSectionTree), "arg 2 not an array"
		for secName in lSectionTree
			assert isNonEmptyString(secName),
					"not a non-empty string #{OL(secName)}"
			assert defined(@hSections[secName]),
					"not a section name #{OL(secName)}"

		@hSets[name] = lSectionTree
		debug 'hSets', @hSets
		debug "return from addSet()"
		return

	# ..........................................................
	# --- sections returned in depth-first order from section tree
	#     Set names are simply skipped
	#     yields: [<level>, <section>]

	allSections: (desc=undef, level=0) ->

		debug "enter allSections()", desc, level
		if (desc == undef)
			desc = @lSectionTree
		if isArray(desc)
			for item in desc
				if isSectionName(item)
					result = [level, @section(item)]
					debug 'yield', result
					yield result
				else if isSetName(item)
					pass
				else
					assert isArray(item), "not an array #{OL(item)}"
					yield from @allSections(item, level+1)
		else if isSectionName(desc)
			result = [level, @section(desc)]
			debug 'yield', result
			yield result
		else if isSetName(desc)
			lTree = @hSets[desc]
			assert defined(lTree), "Not a Set: #{OL(desc)}"
			yield from @allSections(lTree, level)
		else
			croak "Bad item: #{OL(desc)}"
		debug "return from allSections()"
		return

	# ..........................................................
	# --- procFunc should be (name, text) -> return processedText

	getBlock: (procFunc=undef, lTree=undef) ->

		debug "enter getBlock()"
		if (lTree == undef)
			lTree = @lSectionTree
		else
			assert isArray(lTree), "not an array #{OL(lTree)}"

		lParts = []
		for part in lTree
			if isString(part)
				text = @section(part).getBlock()
				if nonEmpty(text) && defined(procFunc)
					text = procFunc(part, text)
			else if isNonEmptyArray(part)
				if isSectionName(part[0])
					text = @getBlock(procFunc, part)
				else if isSetName(part[0])
					text = @getBlock(procFunc, part.slice(1))
					if nonEmpty(text) && defined(procFunc)
						text = procFunc(part[0], text)
				else
					croak "Bad part: #{OL(part)}"
			else
				croak "Bad part: #{OL(part)}"
			if defined(text)
				lParts.push text

		debug 'lParts', lParts
		result = arrayToBlock(lParts)
		debug "return from getBlock()", result
		return result

	# ..........................................................

	section: (name) ->

		sect = @hSections[name]
		assert defined(sect), "No section named #{OL(name)}"
		return sect

	# ..........................................................

	firstSection: (name) ->

		assert isSetName(name), "bad set name #{OL(name)}"
		lSectionTree = @hSets[name]
		assert defined(lSectionTree), "no such set #{OL(name)}"
		assert nonEmpty(lSectionTree), "empty section #{OL(name)}"
		return @section(lSectionTree[0])

	# ..........................................................

	lastSection: (name) ->

		assert isSetName(name), "bad set name #{OL(name)}"
		lSectionTree = @hSets[name]
		assert defined(lSectionTree), "no such set #{OL(name)}"
		assert nonEmpty(lSectionTree), "empty section #{OL(name)}"
		return @section(lSectionTree[lSectionTree.length - 1])

	# ..........................................................

	length: (desc=undef) ->

		result = 0
		for [_, sect] from @allSections(desc)
			result += sect.length()
		return result

	# ..........................................................

	isEmpty: (desc=undef) ->

		return (@length(desc) == 0)

	# ..........................................................

	nonEmpty: (desc=undef) ->

		return (@length(desc) > 0)

	# ..........................................................

	getShape: () ->

		debug "enter getShape()"
		lParts = []
		for [level, sect] from @allSections()
			lParts.push indented(sect.name, level)
		result = arrayToBlock(lParts)
		debug "return from getShape()", result
		return result
