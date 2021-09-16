from match import match

# input_af_oac is generated from 02a program
afmatchgeneralpopulation = {
    "case_csv": "input_af_oac",
    "match_csv": "input_general_population",
    "matches_per_case": 10,
    "min_matches_per_case": 1,
    "match_variables": {
        "sex": "category",
        "age": 1,
        "practice_id": "category",
    },
    "closest_match_variables": ["age"],
    "index_date_variable": "indexdate",
    "replace_match_index_date_with_case": "no_offset",
    "output_suffix": "_af_gen_pop"
}
match(**afmatchgeneralpopulation)
