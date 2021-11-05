import {TAMLDataStore} from '@jdeighan/starbucks/stores';

export let file = new TAMLDataStore(`---
-
	first: 1
	second: 2
-
	kind: cmd
	cmd: include
`);
