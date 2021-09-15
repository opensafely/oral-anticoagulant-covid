from cohortextractor import (
    codelist_from_csv,
    codelist,
)

# OUTCOME CODELISTS
covid_identification = codelist_from_csv(
    "codelists/opensafely-covid-identification.csv",
    system="icd10",
    column="icd10_code",
)

# DEMOGRAPHIC CODELIST
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)

# SMOKING CODELIST
clear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

unclear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-unclear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

# HAZARDOUS ALCOHOL USE CODELIST
hazardous_alcohol_codes = codelist_from_csv(
    "codelists/opensafely-hazardous-alcohol-drinking.csv", system="ctv3", column="code",
)

# CLINICAL CONDITIONS CODELISTS
heart_failure_codes = codelist_from_csv(
    "codelists/opensafely-heart-failure.csv", system="ctv3", column="CTV3ID",
)

hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension.csv", system="ctv3", column="CTV3ID",
)

diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes.csv", system="ctv3", column="CTV3ID",
)

hba1c_new_codes = codelist(["XaPbt", "Xaeze", "Xaezd"], system="ctv3")
hba1c_old_codes = codelist(["X772q", "XaERo", "XaERp"], system="ctv3")

lung_cancer_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer.csv", system="ctv3", column="CTV3ID",
)

haem_cancer_codes = codelist_from_csv(
    "codelists/opensafely-haematological-cancer.csv", system="ctv3", column="CTV3ID",
)

other_cancer_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv",
    system="ctv3",
    column="CTV3ID",
)

aplastic_codes = codelist_from_csv(
    "codelists/opensafely-aplastic-anaemia.csv", system="ctv3", column="CTV3ID",
)

hiv_codes = codelist_from_csv(
    "codelists/opensafely-hiv.csv", system="ctv3", column="CTV3ID",
)

permanent_immune_codes = codelist_from_csv(
    "codelists/opensafely-permanent-immunosuppression.csv",
    system="ctv3",
    column="CTV3ID",
)

organ_transplant_codes = codelist_from_csv(
    "codelists/opensafely-solid-organ-transplantation.csv",
    system="ctv3",
    column="CTV3ID",
)

spleen_codes = codelist_from_csv(
    "codelists/opensafely-asplenia.csv", system="ctv3", column="CTV3ID",
)

sickle_cell_codes = codelist_from_csv(
    "codelists/opensafely-sickle-cell-disease.csv", system="ctv3", column="CTV3ID",
)

temp_immune_codes = codelist_from_csv(
    "codelists/opensafely-temporary-immunosuppression.csv",
    system="ctv3",
    column="CTV3ID",
)

stroke_codes  = codelist_from_csv(
    "codelists/opensafely-stroke-updated.csv",
    system="ctv3",
    column="CTV3ID",
)

tia_codes  = codelist_from_csv(
    "codelists/opensafely-transient-ischaemic-attack.csv",
    system="ctv3",
    column="code",
)

antiphospholipid_codes  = codelist_from_csv(
    "codelists/opensafely-antiphospholipid-syndrome.csv",
    system="ctv3",
    column="code",
)

pad_codes  = codelist_from_csv(
    "codelists/opensafely-peripheral-arterial-disease.csv",
    system="ctv3",
    column="code",
)

valvular_af_codes  = codelist_from_csv(
    "codelists/opensafely-valvular-atrial-fibrillation.csv",
    system="ctv3",
    column="code",
)

creatinine_codes = codelist(["XE2q5"], system="ctv3")

has_bled_codes = codelist(["XaY6z"], system="ctv3")

#The following is an imperfect description but left as is for consistency until resolution of https://github.com/ebmdatalab/opencodelists/issues/39
esrf_codes = codelist_from_csv(
    "codelists/opensafely-chronic-kidney-disease.csv", system="ctv3", column="CTV3ID",
)

copd_codes = codelist_from_csv(
    "codelists/opensafely-current-copd.csv", system="ctv3", column="CTV3ID",
)

other_respiratory_codes = codelist_from_csv(
    "codelists/opensafely-other-respiratory-conditions.csv",
    system="ctv3",
    column="CTV3ID",
)

mi_codes = codelist_from_csv(
    "codelists/opensafely-myocardial-infarction.csv",
    system="ctv3",
    column="CTV3ID",
)

vte_codes = codelist_from_csv(
    "codelists/opensafely-venous-thromboembolic-disease.csv",
    system="ctv3",
    column="CTV3Code",
)

af_codes = codelist_from_csv(
    "codelists/opensafely-atrial-fibrillation-clinical-finding.csv",
    system="ctv3",
    column="CTV3Code",
)


# VACCINATION
flu_med_codes = codelist_from_csv(
    "codelists/opensafely-influenza-vaccination.csv",
    system="snomed",
    column="snomed_id",
)

flu_clinical_given_codes = codelist_from_csv(
    "codelists/opensafely-influenza-vaccination-clinical-codes-given.csv",
    system="ctv3",
    column="CTV3ID",
)

flu_clinical_not_given_codes = codelist_from_csv(
    "codelists/opensafely-influenza-vaccination-clinical-codes-not-given.csv",
    system="ctv3",
    column="CTV3ID",
)

dementia_codes = codelist_from_csv(
    "codelists/opensafely-dementia-complete.csv",
    system="ctv3",
    column="code",
)

# MEDICATIONS
warfarin_codes = codelist_from_csv(
    "codelists/opensafely-warfarin.csv",
    system="snomed",
    column="id",
    )

doac_codes = codelist_from_csv(
    "codelists/opensafely-direct-acting-oral-anticoagulants-doac.csv",
    system="snomed",
    column="id",
)

lmwh_codes = codelist_from_csv(
    "codelists/opensafely-low-molecular-weight-heparins-dmd.csv",
    system="snomed",
    column="dmd_id",
)

oestrogen_codes = codelist_from_csv(
    "codelists/opensafely-oestrogen-and-oestrogen-like-drugs.csv",
    system="snomed",
    column="dmd_id",
)

antiplatelet_codes = codelist_from_csv(
    "codelists/opensafely-antiplatelets.csv",
    system="snomed",
    column="dmd_id",
)

aspirin_codes = codelist_from_csv(
    "codelists/opensafely-aspirin.csv",
    system="snomed",
    column="id",
)

nsaid_codes = codelist_from_csv(
    "codelists/opensafely-nsaids-oral.csv",
    system="snomed",
    column="snomed_id",
)

mi_ons = codelist_from_csv(
    "codelists/opensafely-cardiovascular-secondary-care.csv",
    system="icd10",
    column="icd",
    category_column="mi",
)

stroke_ons = codelist_from_csv(
    "codelists/opensafely-stroke-secondary-care.csv", 
    system="icd10", 
    column="icd",
    category_column="type",
)

gi_bleed_ons = codelist_from_csv(
    "codelists/opensafely-gastrointestinal-bleeding-icd-10.csv",
    system="icd10",
    column="code",
)

vte_ons = codelist_from_csv(
    "codelists/opensafely-venous-thromboembolism-icd-10.csv",
    system="icd10",
    column="code",
)