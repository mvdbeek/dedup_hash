# Location of virtualenv used for development.
VENV?=.venv
BRANCH=curie2
GALAXY_REPO=https://github.com/mvdbeek/galaxy.git
CONDA_PREFIX?=.conda
CONDA_PREFIX_PATH?=`readlink -e .conda`
# Source virtualenv to execute command (flake8, sphinx, twine, etc...)
IN_VENV=if [ -f $(VENV)/bin/activate ]; then . $(VENV)/bin/activate; fi;

setup-venv: ## setup a development virutalenv in current directory
	if [ ! -d $(VENV) ]; then virtualenv $(VENV); exit; fi;
	$(IN_VENV) pip install -r requirements.txt

lint: setup-venv
	pip install tox watchdog && tox

db:
	if [ ! -d db_gx_rev_0127.sqlite ]; then wget https://github.com/jmchilton/galaxy-downloads/raw/master/db_gx_rev_0127.sqlite ; exit; fi;

setup_galaxy_clone:
	if [ ! -d .galaxy ]; then git clone --depth=50 --branch $(BRANCH) $(GALAXY_REPO) .galaxy; exit; fi;

planemo-test: setup-venv setup_galaxy_clone
	pip install planemo && if [ ! -d $(CONDA_PREFIX) ]; then planemo conda_init --conda_prefix $(CONDA_PREFIX);fi && \
		planemo conda_install --conda_prefix $(CONDA_PREFIX_PATH) . && \
		planemo test \
		--galaxy_database_seed db_gx_rev_0127.sqlite \
        --galaxy_root .galaxy \
		--galaxy_source $(GALAXY_REPO) \
		--galaxy_branch $(BRANCH) \
		--conda_dependency_resolution \
		--conda_prefix $(CONDA_PREFIX_PATH)

planemo-serve: setup-venv setup_galaxy_clone
	planemo serve \
        --galaxy_database_seed db_gx_rev_0127.sqlite \
        --galaxy_root .galaxy \
		--galaxy_source $(GALAXY_REPO) \
		--galaxy_branch $(BRANCH) \
		--conda_auto_install \
		--conda_dependency_resolution \
		--conda_prefix $(CONDA_PREFIX_PATH)

py-test:
	$(IN_VENV) python test/test_dedup_hash.py

clean:
	rm -Rf .venv .conda .galaxy dist/ *.egg-info tool_test_output.* .tox  || true
