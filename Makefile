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
	@-rm -r dist/* 2>/dev/null
	@-rm -r build/* 2>/dev/null
	python setup.py sdist bdist_wheel
	for file in dist/*; do gpg --detach-sign -a $$file; done
