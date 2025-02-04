--- KSM alumni in NY
with h as (select *
from rpt_pbh634.v_entity_ksm_households
where rpt_pbh634.v_entity_ksm_households.PROGRAM is not null
and rpt_pbh634.v_entity_ksm_households.household_geo_primary_desc like '%New York%'
),

--- employment

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

industry as (select employ.id_number, employ.fld_of_work_code
from employ
/* advertising, animation, apperal and fashion,
Arts and Crafts, Broadcast Media, Event Services,
Fine Art, Graphic Design, Lux Goods and Jewerly, Media,
media production, motion pictures and film, Musuems, Music,
Newspapers, Online MEdia, Performing Arts, Photography,

*/
where employ.fld_of_work_code IN ('60','L05', 'L06','L08','L13',
'L33','L37','L39','L44','L54','L79', 'MPB', 'L86', 'L92','L93','L94',
'L96', 'L99', 'L104', 'L107', 'L146')),

i AS (select Distinct interest.id_number,
Listagg (i.short_desc, ';  ') Within Group (Order By i.short_desc) As short_desc
from interest
left join tms_interest i on i.interest_code = interest.interest_code
where interest.interest_code IN ('60','L05', 'L06','L08','L13',
'L33','L37','L39','L44','L54','L79', 'MPB', 'L86', 'L92','L93','L94',
'L96', 'L99', 'L104', 'L107', 'L146')
group by interest.id_number
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
employ.job_title,
employ.employer_name,
employ.fld_of_work as employment_industry,
i.short_desc as Interest,
KSP.NO_CONTACT,
KSP.NO_EMAIL_IND,
a.prospect_manager,
a.lgos,
l.linkedin_address
FROM ENTITY e
inner join h on h.id_number = e.id_number
left join employ on employ.id_number = e.id_number
left join industry on industry.id_number = e.id_number
left join i on i.id_number = e.id_number
left join KSM_Spec KSP on KSP.id_number = e.id_number
left join assignment a on a.id_number = e.id_number
left join linked l on l.id_number = e.id_number
where (KSP.NO_CONTACT is null)
and (industry.id_number is not null
or i.id_number is not null)
order by e.last_name asc
