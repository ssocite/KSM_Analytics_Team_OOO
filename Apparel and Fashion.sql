with employ As (
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
  Where employment.primary_emp_ind = 'Y'),

--- Black Management Association as a student
a as (SELECT Distinct
stact.id_number,
stact.student_activity_code,
s.short_desc,
stact.student_particip_code,
stact.start_dt
  FROM  student_activity stact
LEFT JOIN TMS_STUDENT_ACT s on s.student_activity_code = stact.student_activity_code
 WHERE  stact.student_activity_code = 'KSA57'),

spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND
From rpt_pbh634.v_entity_special_handling spec),

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number),

f as (Select interest.id_number,
interest.interest_code,
TMS_INTEREST.short_desc
from interest
left join TMS_INTEREST ON TMS_INTEREST.interest_code = interest.interest_code
where interest.interest_code = 'L06')

select distinct m.id_number,
       e.first_name,
       e.last_name,
       m.FIRST_KSM_YEAR,
       m.PROGRAM,
       m.PROGRAM_GROUP,
       employ.job_title,
       employ.employer_name,
       employ.fld_of_work,
       f.short_desc as interest,
       linked.linkedin_address
from VT_ALUMNI_MARKET_SHEET m
inner join entity e on e.id_number = m.id_number
left join f on f.id_number = m.id_number
left join spec on spec.id_number = m.id_number
left join employ on employ.id_number = m.id_number
left join linked on linked.id_number = m.id_number
/*
From Request
Can I please have a list of all FT & EW alumni who identify as Black or who have
participated with BMA as a student*/

where (employ.fld_of_work = 'Apparel & Fashion'
or f.short_desc = 'Apparel & Fashion')

and (spec.NO_CONTACT is null)
