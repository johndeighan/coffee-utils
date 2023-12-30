# server.coffee

import getline from 'readline-sync'
import {execSync} from 'child_process'

# ---------------------------------------------------------------------------
#   exec - run external commands

export exec = (cmd) =>

	buffer = execSync cmd, {
		windowsHide: true
		}
	return buffer.toString()
