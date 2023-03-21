# oral-anticoagulant-covid-outcome

# OpenSAFELY Association between oral anticoagulants and COVID-19-related outcomes: a population-based cohort study

This is the code and configuration for oral-anticoagulant-covid-outcome.

You can run this project via [Gitpod](https://gitpod.io) in a web browser by clicking on this badge: [![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod)](https://gitpod.io/#https://github.com/opensafely/oral-anticoagulant-covid-outcome)

* The paper is [here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9037187/)
* Raw model outputs, including charts, crosstabs, etc, are in `released_outputs/`
* If you are interested in how we defined our variables, take a look at the [study definition for people with atrial fibrillation](analysis/study_definition_af.py), [study definition for people in the general population](analysis/study_definition_general_population.py), [how we derive variables](analysis/common_variables.py); this is written in `python`, but non-programmers should be able to understand what is going on there
* If you are interested in how we defined our code lists, look in the [codelists folder](./codelists/). All codelists are available online at [OpenCodelists](https://codelists.opensafely.org/) for inspection and re-use by anyone
* Developers and epidemiologists interested in the framework should review [the OpenSAFELY documentation](https://docs.opensafely.org)

# About the OpenSAFELY framework

The OpenSAFELY framework is a Trusted Research Environment (TRE) for electronic
health records research in the NHS, with a focus on public accountability and
research quality.

Read more at [OpenSAFELY.org](https://opensafely.org).

# Licences
As standard, research projects have a MIT license. 
