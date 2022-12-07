# GiftSet.coffee

import {produce, enableMapSet} from 'immer'
import {assert, croak, LOG, LOGVALUE} from '@jdeighan/base-utils'
import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'
import {
	undef, defined, notdefined, OL,
	isString, isNonEmptyString, isArray, isHash, isArrayOfStrings,
	isEmpty, nonEmpty,
	} from '@jdeighan/coffee-utils'

enableMapSet()

# ---------------------------------------------------------------------------

export LOGMAP = (label, map) ->

	lLines = ["MAP #{label}:"]
	for [key, value] from map.entries()
		lLines.push "   #{OL(key)}: #{OL(value)}"
	LOG lLines.join("\n")
	LOG()
	return

# ---------------------------------------------------------------------------

export addGift = produce (draft, giftName, hData={}) ->

	assert (draft instanceof Map), "draft is not a Map"
	if draft.get giftName
		throw new Error("Gift #{giftName} already exists")
	hValue = {hData...}
	hValue.name = giftName
	draft.set giftName, hValue
	return

# ---------------------------------------------------------------------------

export reserveGift = produce (draft, giftName, user) ->

	assert (draft instanceof Map), "draft is not a Map"
	gift = draft.get giftName
	assert gift?, "No such gift: #{giftName}"
	gift.reservedBy = user
	return

# ---------------------------------------------------------------------------

export cancelReservation = produce (draft, giftName) ->

	assert (draft instanceof Map), "draft is not a Map"
	gift = draft.get giftName
	assert defined(gift), "No such gift: #{giftName}"
	delete gift.reservedBy
	return

# ---------------------------------------------------------------------------


