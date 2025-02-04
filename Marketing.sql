with employ As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc As fld_of_work
  , employer_name1,
    Case
      When employer_id_number Is Not Null And employer_id_number != ' ' Then (
        Select pref_mail_name
        From entity
        Where id_number = employer_id_number)
      Else trim(employer_name1 || ' ' || employer_name2)
    End As employer_name
  From employment
  Left Join tms_fld_of_work fow
       On fow.fld_of_work_code = employment.fld_of_work_code
  Where employment.primary_emp_ind = 'Y'
  ---- Marketing research and marketing and advertising
  and employment.fld_of_work_code IN ('L84','L83')
  ),

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

assign as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign)


select house.ID_NUMBER,
       house.REPORT_NAME,
       entity.first_name,
       entity.last_name,
       ---entity.gender_code,
       entity.institutional_suffix,
       house.RECORD_STATUS_CODE,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_GEO_PRIMARY_DESC,
       house.HOUSEHOLD_STATE,
       employ.job_title,
       employ.employer_name,
       employ.fld_of_work,
       ---assign.prospect_manager,
       ---assign.lgos,
       linked.linkedin_address,
       k.NO_CONTACT,
       k.NO_EMAIL_IND
from rpt_pbh634.v_entity_ksm_households house
inner join employ on employ.id_number = house.id_number
inner join entity on entity.id_number = house.ID_NUMBER
left join linked on linked.id_number = house.id_number
left join KSM_Spec k on k.id_number = house.id_number
Left Join assign on assign.id_number = house.ID_number
where house.PROGRAM is not null
order by house.report_name ASC
