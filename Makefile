# Location of virtualenv used for development.
VENV?=.venv
CONDA_PREFIX?=.conda
# Source virtualenv to execute command (flake8, sphinx, twine, etc...)
IN_VENV=if [ -f $(VENV)/bin/activate ]; then . $(VENV)/bin/activate; fi;

setup-venv: ## setup a development virutalenv in current directory
	if [ ! -d $(VENV) ]; then virtualenv $(VENV); exit; fi;
	$(IN_VENV) pip install -r requirements.txt

lint: setup-venv # Run a test.
	pip install tox && tox

test: setup-venv
	pip install planemo && planemo conda_init --conda_prefix $(CONDA_PREFIX) && \
		planemo conda_install --conda_prefix $(CONDA_PREFIX) . && \
		planemo test --conda_dependency_resolution --conda_prefix $(CONDA_PREFIX)

clean:
	rm -Rf .venv .conda dist/ *.egg-info tool_test_output.* .tox  || true
