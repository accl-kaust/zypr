.PHONY: help install doc

.DEFAULT: help
help:
	@echo "make install"
	@echo "       install documentation dependencies"
	@echo "make doc"
	@echo "       build & serve documentation"

install:
	python3 -m pip install -r requirements.txt

doc: install
	mkdocs serve