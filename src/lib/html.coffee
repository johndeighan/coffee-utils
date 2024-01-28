# html.coffee

import {
	undef, defined, notdefined, words, isEmpty, nonEmpty,
	toBlock, OL, getOptions,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'
import {indented} from '@jdeighan/base-utils/indent'

hNoEnd = {}
for tagName in words('area base br col command embed hr img input' \
		+ ' keygen link meta param source track wbr')
	hNoEnd[tagName] = true

# ---------------------------------------------------------------------------

export parsetag = (line) =>

	if lMatches = line.match(///^
			(?:
				([A-Za-z][A-Za-z0-9_]*)  # variable name
				\s*
				=
				\s*
				)?                       # variable is optional
			([A-Za-z][A-Za-z0-9_]*)     # tag name
			(?:
				\:
				( [a-z]+ )
				)?
			(\S*)                       # modifiers (class names, etc.)
			\s*
			(.*)                        # attributes & enclosed text
			$///)
		[_, varName, tagName, subtype, modifiers, rest] = lMatches
	else
		croak "parsetag(): Invalid HTML: '#{line}'"

	# --- Handle classes - subtypes and added via .<class>
	lClasses = []
	if nonEmpty(subtype) && (tagName != 'svelte')
		lClasses.push subtype

	if modifiers
		# --- currently, these are only class names
		while lMatches = modifiers.match(///^
				\. ([A-Za-z][A-Za-z0-9_]*)
				///)
			[all, className] = lMatches
			lClasses.push className
			modifiers = modifiers.substring(all.length)
		if modifiers
			croak "parsetag(): Invalid modifiers in '#{line}'"

	# --- Handle attributes
	hAttr = {}     # { name: { value: <value>, quote: <quote> }, ... }

	if varName
		hAttr['bind:this'] = {value: varName, quote: '{'}

	if (tagName == 'script') && (subtype == 'startup')
		hAttr['context'] = {value: 'module', quote: '"'}

	if rest
		while lMatches = rest.match(///^
				(?:
					(?:
						(?:
							( bind | on )          # prefix
							:
							)?
						([A-Za-z][A-Za-z0-9_]*)   # attribute name
						)
					=
					(?:
						  \{ ([^}]*) \}           # attribute value
						| " ([^"]*) "
						| ' ([^']*) '
						|   ([^"'\s]+)
						)
					|
					\{
					([A-Za-z][A-Za-z0-9_]*)
					\}
					) \s*
				///)
			[all, prefix, attrName, br_val, dq_val, sq_val, uq_val, ident] = lMatches
			if ident
				hAttr[ident] = { value: ident, shorthand: true }
			else
				if br_val
					value = br_val
					quote = '{'
				else
					assert ! prefix?, "prefix requires use of {...}"
					if dq_val
						value = dq_val
						quote = '"'
					else if sq_val
						value = sq_val
						quote = "'"
					else
						value = uq_val
						quote = ''

				if prefix
					attrName = "#{prefix}:#{attrName}"

				if attrName == 'class'
					for className in value.split(/\s+/)
						lClasses.push className
				else
					if hAttr.attrName?
						croak "parsetag(): Multiple attributes named '#{attrName}'"
					hAttr[attrName] = { value, quote }

			rest = rest.substring(all.length)

	# --- The rest is contained text
	rest = rest.trim()
	if lMatches = rest.match(///^
			['"]
			(.*)
			['"]
			$///)
		rest = lMatches[1]

	# --- Add class attribute to hAttr if there are classes
	if (lClasses.length > 0)
		hAttr.class = {
			value: lClasses.join(' '),
			quote: '"',
			}

	# --- Build the return value
	hToken = {
		type: 'tag'
		tagName
		}

	if subtype
		hToken.subtype = subtype
		hToken.orgtag = "#{tagName}:#{subtype}"
	else
		hToken.orgtag = tagName

	# --- if tagName == 'svelte', set hToken.tagName to hToken.orgtag
	if (tagName == 'svelte')
		hToken.tagName = hToken.orgtag

	if nonEmpty(hAttr)
		hToken.hAttr = hAttr

	# --- Is there contained text?
	if rest
		hToken.text = rest

	return hToken

# ---------------------------------------------------------------------------
# --- export only for unit testing

export attrStr = (hAttr) =>

	if ! hAttr
		return ''
	str = ''
	for attrName in Object.getOwnPropertyNames(hAttr)
		{value, quote, shorthand} = hAttr[attrName]
		if shorthand
			str += " {#{value}}"
		else
			if quote == '{'
				bquote = '{'
				equote = '}'
			else
				bquote = equote = quote
			str += " #{attrName}=#{bquote}#{value}#{equote}"
	return str

# ---------------------------------------------------------------------------

export tag2str = (hToken, type='begin') =>

	{tagName, hAttr} = hToken
	if (type == 'begin')
		str = "<#{tagName}"    # build the string bit by bit
		if nonEmpty(hAttr)
			str += attrStr(hAttr)
		str += '>'
		return str
	else if (type == 'end')
		if hNoEnd[tagName]
			return undef
		else
			return "</#{tagName}>"
	else
		croak "type must be 'begin' or 'end'"

# ---------------------------------------------------------------------------
#    elem - indent text, surround with HTML tags

export elem = (tagName, hAttr=undef, text=undef, oneIndent="\t") =>

	if isEmpty(text)
		hToken = {tagName, hAttr}
		return tag2str(hToken, 'begin') + tag2str(hToken, 'end')
	else
		hToken = {tagName, hAttr, text}
		return toBlock([
			tag2str(hToken, 'begin')
			indented(text, 1, oneIndent)
			tag2str(hToken, 'end')
			])

# ---------------------------------------------------------------------------

export formatHTML = (html, hOptions={}) =>

	dbgEnter 'formatHTML', html, hOptions
	{oneIndent} = getOptions(hOptions, {
		oneIndent: '   '
		})

	if (notdefined(html))
		dbgReturn 'formatHTML', ''
		return ''
	html = html.trim()    # remove any leading/trailing whitespace
	if (html == '')
		dbgReturn 'formatHTML', ''
		return ''

	assert html.charAt(0) == '<', "Bad HTML, no < at start"
	assert html.charAt(html.length-1) == '>', "Bad HTML, no > at end"

	# --- Remove leading '<' and trailing '>'
	html = html.substring(1, html.length-1)

	hNoEndTag = {}
	for tag in words("""
			br hr img input link base
			meta param area embed
			col track source
			""")
		hNoEndTag[tag] = true

	lParts = []
	level = 0

	for elem in html.split(/>\s*</)
		dbg "ELEM: #{OL(elem)}"
		[_, endMarker, tagName, rest] = elem.match(///^
			(\/)?                     # possible end tag
			([A-Za-z][A-Za-z0-9-]*)   # tag name
			(.*)                      # everything else
			$///)
		if endMarker
			dbg "   TAG: #{OL(tagName)} - END MARKER"
		else
			dbg "   TAG: #{OL(tagName)} - NO END MARKER"

		if endMarker && (level > 0)
			# --- If end tag, reduce level
			dbg "   reduce level #{level} to #{level-1}"
			level -= 1

		dbg "   ADD #{OL(elem)} at level #{level}"
		lParts.push oneIndent.repeat(level), "<#{elem}>\n"

		if ! endMarker && ! hNoEndTag[tagName] && !rest.endsWith('/'+tagName)
			dbg "   inc level #{level} to #{level+1}"
			level += 1

	result = lParts.join('').trim()
	dbgReturn 'formatHTML', result
	return result
