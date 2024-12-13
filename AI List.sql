with employ as (
Select employment.id_number,
   employment.job_title,
    Case
      When employer_id_number Is Not Null And employer_id_number != ' ' Then (
        Select pref_mail_name
        From entity
        Where id_number = employer_id_number)
      -- Otherwise use the write-in field
      Else trim(employer_name1 || ' ' || employer_name2)
    End As employer_name
  ,fow.short_desc
  ,case when v.tech is not null and v.fld_of_work_code != 'L140' then 'Tech/AI' end as tech_AI_employment
  From employment
  --- JUST KSM ALUMNI
  Inner Join rpt_pbh634.v_entity_ksm_degrees d on d.id_number = employment.id_number
  Left Join tms_fld_of_work fow
       On fow.fld_of_work_code = employment.fld_of_work_code
--- Health
left join v_industry_groups v on v.fld_of_work_code = employment.fld_of_work_code
Where employment.primary_emp_ind = 'Y'
and (v.short_desc like '%Computer & Network Security%'
or v.short_desc   like '%Semiconductors%'
or v.short_desc   like '%Information Technology and Services%'
or v.short_desc   like '%Computer Hardware%'
or v.short_desc   like '%Internet%'
or v.short_desc   like '%Computer Software%'
or v.short_desc   like '%Computer Networking%'
or v.short_desc   like '%Wireless%'




)),

mbai AS (select committee.id_number,
       TMS_COMMITTEE_TABLE.short_desc
FROM committee
Left Join TMS_COMMITTEE_TABLE on committee.committee_code = TMS_COMMITTEE_TABLE.committee_code
where committee.committee_code = 'MBAAC'
and committee.committee_status_code = 'C'),


ksm_giving as
(Select Give.ID_NUMBER,
       give.NGC_LIFETIME,
       give.NU_MAX_HH_LIFETIME_GIVING
From RPT_PBH634.v_Ksm_Giving_Summary Give),

assign as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

ksm_prospect AS (
Select TP.ID_NUMBER,
       TP.PREF_MAIL_NAME,
       TP.LAST_NAME,
       TP.FIRST_NAME,
       TP.PROSPECT_MANAGER,
       TP.EVALUATION_RATING,
       TP.OFFICER_RATING
From nu_prs_trp_prospect TP),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT,
       spec.GAB,
       spec.TRUSTEE,
       spec.EBFA
From rpt_pbh634.v_entity_special_handling spec),

armod as (Select en.ID_NUMBER,
en.AE_MODEL_SCORE
From rpt_pbh634.v_ksm_model_alumni_engagement en)


Select
house.id_number,
entity.record_type_code,
house.REPORT_NAME,
house.RECORD_STATUS_CODE,
entity.institutional_suffix,
house.FIRST_KSM_YEAR,
house.PROGRAM,
employ.job_title,
employ.employer_name,
employ.short_desc as employment_industry,
case when mbai.id_number is not null then 'MBAi Advisory Council' end as MBAi_Advisory_council,
employ.tech_AI_employment,
house.HOUSEHOLD_CITY,
house.HOUSEHOLD_STATE,
house.HOUSEHOLD_COUNTRY,
assign.prospect_manager,
assign.lgos,
ksm_prospect.EVALUATION_RATING,
ksm_prospect.OFFICER_RATING,
ksm_giving.NGC_LIFETIME as KSM_NGC_Lifetime,
ksm_giving.NU_MAX_HH_LIFETIME_GIVING,
armod.AE_MODEL_SCORE,
KSM_Spec.NO_EMAIL_IND,
KSM_Spec.NO_CONTACT,
KSM_Spec.GAB,
KSM_Spec.TRUSTEE,
KSM_Spec.EBFA

From rpt_pbh634.v_entity_ksm_households house
Left Join ksm_prospect ON ksm_prospect.ID_NUMBER = house.id_number
Left Join ksm_giving ON ksm_giving.id_number = house.id_number
Left Join assign on assign.id_number = house.ID_number
Left Join employ on employ.id_number = house.id_number
Left Join KSM_Spec on KSM_Spec.id_number = house.id_number
Left Join entity on entity.id_number = house.id_number
Left Join mbai on mbai.id_number = house.id_number
left join armod on armod.id_number = house.id_number
--- Remove No contacts!
Where (KSM_Spec.NO_CONTACT is null
and KSM_Spec.NO_EMAIL_IND is null)
--- Employed in industries OR MBAi advisory council
--- Some MBAi Folks are not KSM alumni?
and (mbai.id_number is not null
or employ.id_number is not null)
Order By house.REPORT_NAME ASC
