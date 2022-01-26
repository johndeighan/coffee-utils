# server_utils.coffee

import getline from 'readline-sync'
import {execSync} from 'child_process'

# ---------------------------------------------------------------------------
#   exec - run external commands

export exec = (cmd) ->

	buffer = execSync cmd, {
		windowsHide: true
		}
	return buffer.toString()

# ---------------------------------------------------------------------------
#   ask - ask a question
#         later, on a web page, prompt the user for answer to question

export ask = (prompt) ->

	answer = getline.question("{prompt}? ")
	return answer
