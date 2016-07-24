TOXARGS ?=

all: help

help:
	@echo "Commands:"
	@echo "- test"
	@echo "- coverage"
	@echo "- package"

test:
	tox $(TOXARGS)

coverage:
	py.test --cov ttvfast --cov-report html --cov-report term testing

package:
	python setup.py sdist bdist_wheel
