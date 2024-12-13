--- KSM alumni
with h as (select *
from rpt_pbh634.v_entity_ksm_households
where rpt_pbh634.v_entity_ksm_households.PROGRAM is not null
),

--- PEVC Employment

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

   And (employment.fld_of_work_code In ('PLBO', '36', 'L140')
  Or employment.fld_of_spec_code1 In ('357', 'S25', 'S28', 'K07'))),

  --- PEVC Interest

P As (
Select i.id_number
     , listagg(i.interest_code, ', ') Within Group (Order By i.interest_code ASC) As Interest_Code
     , listagg(tint.short_desc, ', ') Within Group (Order By i.interest_code ASC) As PEVC_Interest
     , listagg(i.comment1, ', ') Within Group (Order By i.interest_code ASC) As Interest_Comment
From interest i
Inner Join tms_interest tint
      On i.interest_code = tint.interest_code
Where i.interest_code = 'LVC'
Group By i.id_number
),


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
Group By ec.id_number),

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
from rpt_pbh634.v_ksm_giving_summary give)

SELECT e.id_number,
e.first_name,
e.last_name,
e.institutional_suffix,
e.gender_code,
h.FIRST_KSM_YEAR,
h.PROGRAM,
h.PROGRAM_GROUP,
h.HOUSEHOLD_CITY,
h.HOUSEHOLD_COUNTRY,
employ.job_title,
employ.employer_name,
employ.fld_of_work as employment_industry,
p.PEVC_Interest,
KSP.NO_CONTACT,
KSP.NO_EMAIL_IND,
a.prospect_manager,
a.lgos,
l.linkedin_address,
g.NGC_LIFETIME,
g.NU_MAX_HH_LIFETIME_GIVING,
g.LAST_GIFT_DATE,
g.LAST_GIFT_ALLOC,
g.LAST_GIFT_RECOGNITION_CREDIT,
g.NGC_CFY,
g.NGC_PFY1,
g.NGC_PFY2,
g.NGC_PFY3,
g.NGC_PFY4,
g.NGC_PFY5
FROM ENTITY e
inner join h on h.id_number = e.id_number
left join employ on employ.id_number = e.id_number
left join KSM_Spec KSP on KSP.id_number = e.id_number
left join assignment a on a.id_number = e.id_number
left join linked l on l.id_number = e.id_number
left join p on p.id_number = e.id_number
left join g on g.id_number = e.id_number
--- Employed OR interested in private equity
where (employ.id_number is not null
or p.id_number is not null)
and h.first_ksm_year IN ('2014','2015','2016','2017','2018','2019')
and KSP.NO_CONTACT is null
order by e.last_name asc
