// Generated by CoffeeScript 2.7.0
// server.coffee
import getline from 'readline-sync';

import {
  execSync
} from 'child_process';

// ---------------------------------------------------------------------------
//   exec - run external commands
export var exec = (cmd) => {
  var buffer;
  buffer = execSync(cmd, {
    windowsHide: true
  });
  return buffer.toString();
};

//# sourceMappingURL=server.js.map
