// Generated by CoffeeScript 2.6.1
// external.coffee
import getline from 'readline-sync';

import {
  execSync
} from 'child_process';

// ---------------------------------------------------------------------------
//   exec - run external commands
export var exec = function(cmd) {
  var buffer;
  buffer = execSync(cmd, {
    windowsHide: true
  });
  return buffer.toString();
};

// ---------------------------------------------------------------------------
//   ask - ask a question
//         later, on a web page, prompt the user for answer to question
export var ask = function(prompt) {
  var answer;
  answer = getline.question("{prompt}? ");
  return answer;
};
