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

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number),

s AS (Select spec.ID_NUMBER,
       spec.SPECIAL_HANDLING_CONCAT,
       spec.GAB,
       spec.TRUSTEE,
       spec.EBFA,
       spec.NO_CONTACT,
       spec.NO_PHONE_IND,
       spec.NO_EMAIL_IND,
       spec.NO_MAIL_IND
From rpt_pbh634.v_entity_special_handling spec),

g AS (Select give.ID_NUMBER,
give.NGC_LIFETIME,
give.NU_MAX_HH_LIFETIME_GIVING,
give.LAST_GIFT_DATE,
give.LAST_GIFT_ALLOC,
give.LAST_GIFT_RECOGNITION_CREDIT,
give.NGC_CFY,
give.NGC_PFY1,
give.NGC_PFY2,
give.NGC_PFY3,
give.NGC_PFY4,
give.NGC_PFY5
from rpt_pbh634.v_ksm_giving_summary give),

e AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Where email.preferred_ind = 'Y'),

a as (select distinct assign.id_number,
assign.prospect_manager,
assign.lgos,
assign.managers
from rpt_pbh634.v_assignment_summary assign)

select distinct house.ID_NUMBER,
house.REPORT_NAME,
entity.gender_code,
house.FIRST_KSM_YEAR,
house.PROGRAM,
house.PROGRAM_GROUP,
house.HOUSEHOLD_CITY,
house.HOUSEHOLD_COUNTRY,
employ.job_title,
employ.employer_name,
employ.fld_of_work,
linked.linkedin_address,
a.prospect_manager,
a.lgos,
g.NGC_LIFETIME,
g.NU_MAX_HH_LIFETIME_GIVING,
e.email_address,
s.NO_CONTACT,
s.NO_EMAIL_IND
from rpt_pbh634.v_entity_ksm_households house
inner join entity on entity.id_number = house.ID_NUMBER
left join a on a.id_number = house.id_number
left join employ on employ.id_number = house.ID_NUMBER
left join linked on linked.id_number = house.id_number
left join e on e.id_number = house.id_number
left join s on s.id_number = house.id_number
left join g on g.id_number = house.id_number
where house.PROGRAM is not null
--- remove no contacts
and s.NO_CONTACT is null
and house.HOUSEHOLD_COUNTRY IN ('Peru','Colombia')
order by employ.job_title ASC
