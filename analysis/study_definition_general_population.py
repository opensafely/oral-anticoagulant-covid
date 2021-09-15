from cohortextractor import (
    StudyDefinition,
    patients,
    codelist_from_csv,
    codelist,
    combine_codelists,
    filter_codes_by_category,
)

from common_variables import common_variables
from codelists import *


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "exponential_increase",
        "incidence": 0.7,
    },

    # STUDY POPULATION
    population=patients.satisfying(
        """
        registration_history AND
        (age >=18 AND age <= 110) AND
        (sex="M" OR sex="F") AND
        imd >0 AND 
        gp_consult_count>0 AND NOT (
        af OR
        lmwh_last_four_months OR 
        warfarin_last_four_months OR
        doac_last_four_months
        )
        """,
        registration_history=patients.registered_with_one_practice_between(
            "2019-02-28", "2020-02-29"
        ),
    ),
    **common_variables
)
