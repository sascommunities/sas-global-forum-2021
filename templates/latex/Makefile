.DEFAULT_GOAL := help

generate:
	@echo "Creating SGF paper: $(paper)..."
	pdflatex -interaction=batchmode $(paper).tex ; true
	bibtex $(paper).aux ; true
	pdflatex -interaction=batchmode $(paper).tex ; true

clean:
	@echo "Cleaning up..."
	rm -f *.aux
	rm -f *.bbl
	rm -f *.blg
	rm -f *.fdb_latexmk
	rm -f *.fls
	rm -f *.synctex.gz
	rm -f *.log


help:
	@echo "This file should be run with the -k flag (or --ignore-errors with gnumake)"
	@echo "Usage: "
	@echo "	Generate PDF of paper: make -k generate [options]"
	@echo "	Clean working directory of temp files: make clean"
	@echo ""
	@echo "	Options: "
	@echo "		paper= The name of the tex file (without the extension) that you'd like to make"
	@echo "			This make file requires pdflatex and bibtex to be installed and on the PATH."
	@echo ""
	@echo "Example: "
	@echo ""
	@echo "	make -k generate paper=1141-2021_Blake"
	@echo "	make clean"