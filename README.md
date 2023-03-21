# oral-anticoagulant-covid

# OpenSAFELY Association between oral anticoagulants and COVID-19-related outcomes: a population-based cohort study

[View on OpenSAFELY](https://jobs.opensafely.org/repo/https%253A%252F%252Fgithub.com%252Fopensafely%252Foral-anticoagulant-covid)

Details of the purpose and any published outputs from this project can be found at the link above.

* The paper is [here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9037187/)
* Raw model outputs, including charts, crosstabs, etc, are in `released_outputs/`
* If you are interested in how we defined our variables, take a look at the [study definition for people with atrial fibrillation](analysis/study_definition_af.py), [study definition for people in the general population](analysis/study_definition_general_population.py), [how we derive variables](analysis/common_variables.py); this is written in `python`, but non-programmers should be able to understand what is going on there
* If you are interested in how we defined our code lists, look in the [codelists folder](./codelists/). All codelists are available online at [OpenCodelists](https://codelists.opensafely.org/) for inspection and re-use by anyone
* Developers and epidemiologists interested in the framework should review [the OpenSAFELY documentation](https://docs.opensafely.org)

The contents of this repository MUST NOT be considered an accurate or valid representation of the study or its purpose. 
This repository may reflect an incomplete or incorrect analysis with no further ongoing work.
The content has ONLY been made public to support the OpenSAFELY [open science and transparency principles](https://www.opensafely.org/about/#contributing-to-best-practice-around-open-science) and to support the sharing of re-usable code for other subsequent users.
No clinical, policy or safety conclusions must be drawn from the contents of this repository.

# About the OpenSAFELY framework

The OpenSAFELY framework is a Trusted Research Environment (TRE) for electronic
health records research in the NHS, with a focus on public accountability and
research quality.

Read more at [OpenSAFELY.org](https://opensafely.org).

# Licences
As standard, research projects have a MIT license. 
