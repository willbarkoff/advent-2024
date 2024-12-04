.PHONY: run

default: run

node_modules: package.json
	npm install

run: node_modules
	npx tsx main.ts