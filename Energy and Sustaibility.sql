--- KSM alumni
with h as (select *
from rpt_pbh634.v_entity_ksm_households
where rpt_pbh634.v_entity_ksm_households.PROGRAM is not null),

--- employment in education

employ As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc As fld_of_work
  , employment.fld_of_spec_code1
  ,tms_fld_of_spec.short_desc as fld_spec
  , employer_name1,
    -- If there's an employer ID filled in, use the entity name
    Case
      When employer_id_number Is Not Null And employer_id_number != ' ' Then (
        Select pref_mail_name
        From entity
        Where id_number = employer_id_number)
      -- Otherwise use the write-in field
      Else trim(employer_name1 || ' ' || employer_name2)
    End As employer_name
  From employment
  Left Join tms_fld_of_work fow
       On fow.fld_of_work_code = employment.fld_of_work_code
       Left Join tms_fld_of_spec
       on tms_fld_of_spec.fld_of_spec_code = employment.fld_of_spec_code1
  Where employment.primary_emp_ind = 'Y'),

---- Interest: Social Impact
--- L18: Civic & Social Organization
--- L38: Environmental Services
--- L53: Government Relations
--- L59: Human Resources
--- L61: Individual & Family Services
--- L66: International Affairs
--- L71: Judiciary
--- L72: Law Enforcement
--- L73: Law Practice
--- L74: Legal Services
--- L75: Legislative Office
--- L93: Museums and Institutions
--- L97: Non-Profit Organization Management
--- L106: Philanthropy
--- L114: Public Policy
--- L115: Public Relations and Communications
--- L116: Public Safety
--- L123: Renewables & Environment

--- Field of Specialty
--- L14 Law - Environmental Law
--- 004 - Engineering - Environmental
--- SUS - Sustainability & Cleantech
--- 315 - Manufacturing Plant - Green Mfg
--- 041 - Biological Sciences

emfin as (select *
  from employ
where  (Employ.fld_of_work_code IN ('L18', 'L53', 'L59', 'L61', 'L66','L71','L73', 'L72',
'L74', 'L75', 'L38', 'L123', 'L93','L97','L106','L109','L114','L115','L116')
or employ.fld_of_spec_code1 IN ('L14','004','SUS','315','041')
or Employ.job_title like '%Social%'
or Employ.job_title like '%Responsibility%'
or employ.job_title like '%Impact%'
or employ.job_title like '%Fund%'
or employ.job_title like '%Ethic%'
or Employ.job_title like '%Enviroment%'
or employ.job_title like '%Renew%'
or employ.job_title like '%Recycle%'
or employ.job_title like '%Recycling%'
or employ.job_title like '%Solar%'
or employ.job_title like '%Wind%'
or employ.job_title like '%Bio%'
or employ.job_title like '%Green%'
)),


KSM_Spec AS (Select spec.ID_NUMBER,
       spec.SPECIAL_HANDLING_CONCAT,
       spec.GAB,
       spec.TRUSTEE,
       spec.EBFA,
       spec.NO_CONTACT,
       spec.NO_PHONE_IND,
       spec.NO_EMAIL_IND,
       spec.NO_MAIL_IND
From rpt_pbh634.v_entity_special_handling spec),

assignment as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number)

SELECT e.id_number,
e.first_name,
e.last_name,
e.record_type_code,
e.record_status_code,
e.institutional_suffix,
e.gender_code,
h.FIRST_KSM_YEAR,
h.PROGRAM,
h.PROGRAM_GROUP,
h.HOUSEHOLD_CITY,
h.HOUSEHOLD_STATE,
h.HOUSEHOLD_GEO_PRIMARY_DESC,
emfin.job_title,
emfin.employer_name,
emfin.fld_of_work as employment_industry,
emfin.fld_spec as employment_fld_specialty,
KSP.NO_CONTACT,
KSP.NO_EMAIL_IND,
a.prospect_manager,
a.lgos,
l.linkedin_address
FROM ENTITY e
inner join h on h.id_number = e.id_number
inner join emfin on emfin.id_number = e.id_number
left join KSM_Spec KSP on KSP.id_number = e.id_number
left join assignment a on a.id_number = e.id_number
left join linked l on l.id_number = e.id_number
where (KSP.NO_CONTACT is null
and KSP.NO_EMAIL_IND is null)
order by e.last_name asc
