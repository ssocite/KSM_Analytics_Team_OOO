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

--- L123: Renewables & Environment

--- Field of Specialty
--- L14 Law - Environmental Law
--- 004 - Engineering - Environmental
--- SUS - Sustainability & Cleantech
--- 315 - Manufacturing Plant - Green Mfg
--- 041 - Biological Sciences

emfin as (select *
  from employ
  --- Renewables & Environment
  --- Environmental Services
where  (Employ.fld_of_work_code IN ('L123','L38')
--- Law - Environmental Law
--- Engineering - Environmental
--- Sustainability & Cleantech
--- Manufacturing Plant - Green Mfg
---
or employ.fld_of_spec_code1 IN ('L14','004','SUS','315')
or Employ.job_title like '%Environment%'
or employ.job_title like '%Renew%'
or employ.job_title like '%Recycle%'
or employ.job_title like '%Recycling%'
or employ.job_title like '%Solar%'
or employ.job_title like '%Bio%'
or employ.job_title like '%Green%'
or Employ.employer_name like '%Environment%'
or employ.employer_name like '%Renew%'
or employ.employer_name like '%Recycle%'
or employ.employer_name like '%Recycling%'
or employ.employer_name like '%Solar%'
or employ.employer_name like '%Bio%'
or employ.employer_name like '%Green%'
)),

--- interest or Environmental Services - Renewables & Environment
i AS (select Distinct interest.id_number,
Listagg (i.short_desc, ';  ') Within Group (Order By i.short_desc) As short_desc
from interest
left join tms_interest i on i.interest_code = interest.interest_code
where interest.interest_code IN ('L38','LRN')
group by interest.id_number),


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
---e.record_status_code,
e.institutional_suffix,
e.gender_code,
h.FIRST_KSM_YEAR,
h.PROGRAM,
h.PROGRAM_GROUP,
h.HOUSEHOLD_CITY,
h.HOUSEHOLD_STATE,
h.HOUSEHOLD_GEO_PRIMARY_DESC,
employ.job_title,
employ.employer_name,
employ.fld_of_work as employment_industry,
employ.fld_spec as employment_fld_specialty,
i.short_desc as interest,
KSP.NO_CONTACT,
KSP.NO_EMAIL_IND,
a.prospect_manager,
a.lgos,
l.linkedin_address
FROM ENTITY e
inner join h on h.id_number = e.id_number
left join employ on employ.id_number = e.id_number
left join emfin on emfin.id_number = e.id_number
left join KSM_Spec KSP on KSP.id_number = e.id_number
left join assignment a on a.id_number = e.id_number
left join linked l on l.id_number = e.id_number
left join i on i.id_number = e.id_number
where (KSP.NO_CONTACT is null)
--- employed in environment OR interested in environment
and (emfin.id_number is not null
or i.id_number is not null)
order by e.last_name asc
