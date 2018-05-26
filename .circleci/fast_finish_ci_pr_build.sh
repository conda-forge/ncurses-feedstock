#!/bin/bash

<<<<<<< HEAD:.circleci/fast_finish_ci_pr_build.sh
curl https://raw.githubusercontent.com/conda-forge/conda-forge-ci-setup-feedstock/branch2.0/recipe/conda_forge_ci_setup/ff_ci_pr_build.py | \
=======
curl https://raw.githubusercontent.com/conda-forge/conda-forge-ci-setup-feedstock/master/recipe/ff_ci_pr_build.py | \
>>>>>>> MNT: Re-rendered with conda-smithy 3.1.5 and pinning 2018.05.22:.circleci/fast_finish_ci_pr_build.sh
     python - -v --ci "circle" "${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}" "${CIRCLE_BUILD_NUM}" "${CIRCLE_PR_NUMBER}"
