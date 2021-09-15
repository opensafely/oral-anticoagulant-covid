from cohortextractor import (
    StudyDefinition,
    patients,
    filter_codes_by_category,
    combine_codelists,
)

from codelists import *

study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },
    # STUDY POPULATION
    population=patients.all(),
    # registration_history AND
    # af AND
    # (age >=18 AND age <= 110) AND
    # imd >0

    registration_history=patients.registered_with_one_practice_between(
        "2019-02-28", "2020-02-29", return_expectations={"incidence": 0.9},
    ),
    
    af=patients.with_these_clinical_events(
        af_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),

    age=patients.age_as_of(
        "2020-03-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },  
    ),
        
    imd=patients.address_as_of(
        "2020-02-29",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),  
)
