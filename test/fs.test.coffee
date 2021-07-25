# fs.test.coffee

import {withExt} from '../fs_utils.js'
import {AvaTester} from 'ava-tester'

tester = new AvaTester()

# ---------------------------------------------------------------------------

tester.equal 75, withExt('file.starbucks', 'svelte'), 'file.svelte'

