test:
	/usr/bin/env mocha --reporter dot --recursive -r should js/test

core:
	/usr/bin/env browserify ./js/browser/core.js > ./bin/core.js

workers:
	/usr/bin/env browserify ./js/browser/workers.js > ./bin/workers.js

.PHONY: test
.PHONY: core
.PHONY: workers