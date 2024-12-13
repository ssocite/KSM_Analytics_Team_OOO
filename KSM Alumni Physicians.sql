With
-- Employment table subquery
employ As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc As fld_of_work
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
  Where employment.primary_emp_ind = 'Y'
),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_PHONE_IND,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND,
       spec.ACTIVE_WITH_RESTRICTIONS
From rpt_pbh634.v_entity_special_handling spec),

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number)

--- This pulls Doctors with KSM degree
select h.ID_NUMBER,
       h.RECORD_STATUS_CODE,
       entity.first_name,
       entity.last_name,
       h.REPORT_NAME,
       entity.institutional_suffix,
       entity.prof_suffix,
       employ.job_title,
       employ.employer_name,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       h.HOUSEHOLD_CITY,
       h.HOUSEHOLD_STATE,
       h.HOUSEHOLD_COUNTRY,
       KSM_Spec.NO_CONTACT,
       KSM_Spec.NO_EMAIL_IND,
       linked.linkedin_address
from rpt_pbh634.v_entity_ksm_households h
inner join entity on entity.id_number = h.id_number
left join employ on employ.id_number = h.id_number
left join KSM_Spec on KSM_Spec.id_number = h.id_number
left join linked on linked.id_number = h.id_number
where (
--- use suffix or MD/MBA program to find doctors
entity.prof_suffix like '%MD%'
or entity.prof_suffix like '%DO%'
or h.program = 'FT-MDMBA')
--- A lot of PHDs are not doctors, so we want to remove just PHDs.
--- Doctors should have MD or DO if they have Phd
and entity.prof_suffix != '%Phd%'
--- Just active or lost recrod
and h.RECORD_STATUS_CODE IN ('A','L')
--- KSM alumni
and h.PROGRAM is not null
--- No Contact/ No Email Exclude
and (KSM_Spec.NO_CONTACT is null
and      KSM_Spec.NO_EMAIL_IND is null)

order by entity.last_name asc
