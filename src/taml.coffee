# taml.coffee

import yaml from 'js-yaml'

import {assert, croak, isTAML, fromTAML, toTAML} from '@jdeighan/exceptions'
import {
	undef, defined, notdefined, OL, chomp, escapeStr,
	isString, isObject, isEmpty,
	} from '@jdeighan/coffee-utils'
import {splitLine} from '@jdeighan/coffee-utils/indent'
import {
	firstLine, toArray, toBlock,
	} from '@jdeighan/coffee-utils/block'
import {slurpTAML} from '@jdeighan/coffee-utils/fs'

export {isTAML, fromTAML, toTAML, slurpTAML}
