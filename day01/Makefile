.PHONY: run run-small

default: run

run-small:
	sed 's/   /	/g' input-small.txt | ocaml main.ml

run:
	sed 's/   /	/g' input.txt | ocaml main.ml