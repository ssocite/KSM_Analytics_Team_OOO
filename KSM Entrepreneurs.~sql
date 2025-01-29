with employ As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc As fld_of_work
  , employer_name1
  , employment.self_employ_ind
    -- If there's an employer ID filled in, use the entity name
  , Case
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
  ----- Founder, Owner or Marked as Self Employed
  And (employment.job_title LIKE '%Founder%'
    OR UPPER(employment.job_title) LIKE '%OWNER%'
    OR employment.self_employ_ind ='Y')),

i AS (select Distinct interest.id_number,
Listagg (i.short_desc, ';  ') Within Group (Order By i.short_desc) As short_desc
from interest
left join tms_interest i on i.interest_code = interest.interest_code
where interest.interest_code IN ('E8')
group by interest.id_number
),


KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number)

select house.ID_NUMBER,
       e.gender_code,
       e.first_name,
       e.last_name,
       house.REPORT_NAME,
       house.RECORD_STATUS_CODE,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       house.HOUSEHOLD_COUNTRY,
       employ.job_title,
       employ.employer_name,
       employ.fld_of_work,
       i.short_desc as interest_Entrepreneur,
       employ.self_employ_ind,
       s.NO_CONTACT,
       s.NO_EMAIL_IND,
       linked.linkedin_address
from rpt_pbh634.v_entity_ksm_households house
inner join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = house.ID_NUMBER
inner join entity e on e.id_number = house.id_number
left join employ on employ.id_number = house.ID_NUMBER
left join i on i.id_number = house.id_number
left join linked on linked.id_number = house.id_number
left join KSM_Spec s on s.id_number = house.id_number
where s.NO_CONTACT is null
and (i.id_number is not null
or employ.id_number is not null)
order by e.last_name ASC
