/* Enviroment subquery

Energy and Sustainability Industries
Environmental Services
Oil & Energy
Paper & Forest Products
Recreational Facilities and Services
Renewables & Environment
Utilities

*/

with m as (select
a.fld_of_work_code,
       a.short_desc,
       a.industry_group,
       a.AGR,
       a.ART,
       a.CONS,
       a.CORP,
       a.EDU,
       a.FIN,
       a.GOODS,
       a.GOVT,
       a.HLTH,
       a.LEG,
       a.MAN,
       a.MED,
       a.ORG,
       a.REC,
       a.SERV,
       a.TECH,
       a.TRAN
from v_industry_groups a
where a.fld_of_work_code IN ('L38','L98','L103','L121','L123','L139')),

-- General Employment and identifying the C-Suites

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
  Where employment.primary_emp_ind = 'Y'),


--- create an interest view

i as (select *
from nu_ksm_v_datamart_career_inter
--- Only want the enviromental Industries
inner join m on m.fld_of_work_code =  nu_ksm_v_datamart_career_inter.interest_code),

--- Concatanate that interest Query

--- This is the final interest list, which will concatanated interests
final_i as  (Select
    intr.catracks_id
    , Listagg(intr.interest_desc, '; ') Within Group (Order By interest_start_date Asc, interest_desc Asc)
      As interests_concat
  From i intr
  Group By intr.catracks_id),

--- Final employer
--- This will pull/create flag in C Suites

final_e as (select *
from employ
inner join m on m.fld_of_work_code = employ.fld_of_work_code),

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number),

Spec AS (Select rpt_pbh634.v_entity_special_handling.ID_NUMBER,
       rpt_pbh634.v_entity_special_handling.GAB,
       rpt_pbh634.v_entity_special_handling.TRUSTEE,
       rpt_pbh634.v_entity_special_handling.NO_CONTACT,
       rpt_pbh634.v_entity_special_handling.NO_SOLICIT,
       rpt_pbh634.v_entity_special_handling.NO_PHONE_IND,
       rpt_pbh634.v_entity_special_handling.NO_EMAIL_IND,
       rpt_pbh634.v_entity_special_handling.NO_MAIL_IND,
       rpt_pbh634.v_entity_special_handling.SPECIAL_HANDLING_CONCAT,
       rpt_pbh634.v_entity_special_handling.EBFA
From rpt_pbh634.v_entity_special_handling)


select house.ID_NUMBER,
       house.REPORT_NAME,
       entity.gender_code,
       house.RECORD_STATUS_CODE,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       employ.job_title,
       employ.employer_name,
       employ.fld_of_work as employment_industry,
       final_e.fld_of_work as employment_energy_industry_ind,
       final_i.interests_concat as energy_interest_concat,
case when employ.fld_of_work is null and final_i.interests_concat is null then 'Y' end as Other_Energy_IND,
       linked.linkedin_address

from rpt_pbh634.v_entity_ksm_households house
inner join employ on employ.id_number = house.ID_NUMBER
left join entity on entity.id_number = house.ID_NUMBER
left join final_i on final_i.catracks_id = house.id_number
left join final_e on final_e.id_number = house.id_number
left join linked on linked.id_number = house.id_number
left join spec on spec.id_number = house.id_number
where house.PROGRAM is not null
and (
--- Industry/Interest in Enviromental Industries
final_i.catracks_id is not null
or final_e.id_number is not null
--- Enviroment and sustainable company
or employ.employer_name like '%Petroleum%'
or employ.employer_name like '%Natural%'
or employ.employer_name like '%Enviroment%'
or employ.employer_name like '%Renew%'
or employ.employer_name like '%Energy%'
or employ.employer_name like '%Oil%'
or employ.employer_name like '%Gas%'
or employ.employer_name like '%Solar%'
or employ.employer_name like '%Sun%'
or employ.employer_name like '%Weather%'
or employ.employer_name like '%Climate%'
or employ.employer_name like '%Utility%'
or employ.employer_name like '%Electric%'
or employ.employer_name like '%Water%'
or employ.employer_name like '%Wind%')
--- No Contact/No Email
and  (spec.NO_CONTACT is null
and    spec.NO_EMAIL_IND is null)
order by house.REPORT_NAME ASC
