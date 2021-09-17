# temp.coffee

import {log} from '@jdeighan/coffee-utils/log'
import {mydir, forEachFile} from '@jdeighan/coffee-utils/fs'
import {debug, setDebugging} from '@jdeighan/coffee-utils/debug'

testDir = mydir(`import.meta.url`)

# ---------------------------------------------------------------------------

main = () ->
	callback = (fname, dir, level) ->
		log "#{'   '.repeat(level)}  #{fname} in #{dir}"

	forEachFile(testDir, callback, /\.txt$/)

# ---------------------------------------------------------------------------

main()
