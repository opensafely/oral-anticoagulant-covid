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
    #    registration_history AND
    #    (age >=18 AND age <= 110) AND
    #    (sex="M" OR sex="F") AND
    #    imd >0 AND 
    #    gp_consult_count>0 AND NOT (
    #    af OR
    #    lmwh_last_four_months OR 
    #    warfarin_last_four_months OR
    #    doac_last_four_months
    #    )
    registration_history=patients.registered_with_one_practice_between(
        "2019-02-28", "2020-02-29", return_expectations={"incidence": 0.9},
    ),
    
    age=patients.age_as_of(
        "2020-03-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },  
    ),

    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
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
    
    gp_consult_count=patients.with_gp_consultations(
        between=["2019-03-01", "2020-02-29"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 4, "stddev": 2},
            "date": {"earliest": "2019-03-01", "latest": "2020-02-29"},
            "incidence": 0.7,
        },
    ),

    af=patients.with_these_clinical_events(
        af_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}
        },
    ),

   # Treatment variable 
    lmwh_last_four_months=patients.with_these_medications(
        lmwh_codes,
        between=["2019-11-01", "2020-02-29"],
        returning="date",
        find_last_match_in_period=True,
        include_month=True,
        include_day=False,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-02-29"}
        },
    ),
 
    warfarin_last_four_months=patients.with_these_medications(
        warfarin_codes,
        between=["2019-11-01", "2020-02-29"],
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-02-29"}
        },
    ),

    doac_last_four_months=patients.with_these_medications(
        doac_codes,
        between=["2019-11-01", "2020-02-29"],
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-02-29"}
        },
    ),
)
