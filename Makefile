all: help

help:
	@echo "Commands:"
	@echo "- test"
	@echo "- coverage"

test:
	py.test testing

coverage:
	py.test --cov ttvfast --cov-report html testing
