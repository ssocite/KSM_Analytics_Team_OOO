/* Kellogg Veterans Pull

Veterans

- Look for current employer
- Look for past employer
- Use Zach's R code to get the yellow ribbon list in the job titles
- Anyone in the KVA - Student Kellogg Veterans Association
- Anyone with a Military Prefix
*/

--- KVA members

with veterans as (select distinct stact.id_number,
stact.student_activity_code
  FROM  student_activity stact
 WHERE  stact.student_activity_code = 'KVA'),

--- Primary Employer

e as( Select id_number
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


--- Non Primary Employer - Past employer
 pe as( Select id_number
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
    End As employer_name,
    employment.date_modified
  From employment
  Left Join tms_fld_of_work fow
       On fow.fld_of_work_code = employment.fld_of_work_code
  Where employment.primary_emp_ind != 'Y'),


---- Past Employer in Armed Forces

/*

To avoid duplicates let's pull the most recent modified past employer in the military

*/

pve as (select pe.id_number,
max (pe.job_title) keep (dense_rank first order by pe.date_modified DESC) as past_job_title,
max (pe.employer_name) keep (dense_rank first order by pe.date_modified DESC) as past_employer_name,
max (pe.fld_of_work) keep (dense_rank first order by pe.date_modified DESC) as past_fld_of_work
from pe


where (pe.employer_name like '%Air Force%'
  or pe.employer_name like '%Armed Forces%'
--- Army
--- Watch out for companies with Army in title
--- Ex: Salvation Army
  or (pe.employer_name like '%Army%'
--- Exclude companies from data review
  and pe.employer_name not like '%Salvation Army%'
    and pe.employer_name not like '%BrandArmy%'
  and pe.employer_name not like '%Hind Musafir Agcy.%'
  and pe.employer_name not like '%Swiss Army Brands Inc%')
  or pe.employer_name like '%Coast Guard%'
  or pe.employer_name like '%Marine Corps%'

or (pe.employer_name like '%Military%'
and pe.employer_name not like '%University of Phoenix Overseas Military Campus%')

--- Navy
--- Watch out for companies with Navy in Name
  or (pe.employer_name like '%Navy%'
  --- Found Old Navy in Employer Data
  and pe.employer_name not like '%Old Navy%'
  --- Navy Pier not in military
  and pe.employer_name not like '%Navy Pier Inc.%'
  and pe.employer_name not like '%Navy Pier Incorporated%')

  or pe.employer_name like '%Space Force%'
  or pe.employer_name like '%u.s. air force%'
  or pe.employer_name like '%u.s. army%'
  or pe.employer_name like '%u.s. coast guard%'
  or pe.employer_name like '%u.s. marine corps%'
  or pe.employer_name like '%u.s. navy%'
  or pe.employer_name like '%u.s. space force%'
  or pe.employer_name like '%united states air force%'
  or pe.employer_name like '%united states army%'
  or pe.employer_name like '%united states coast guard%'
  or pe.employer_name like '%united states marine corps%'
  or pe.employer_name like '%united states navy%'
  or pe.employer_name like '%united states space force%'
  or pe.employer_name like '%us air force%'
  or pe.employer_name like '%us army%'
  or pe.employer_name like '%us coast guard%'
  or pe.employer_name like '%united states space force%'
  or pe.employer_name like '%us marine corps%'
  or pe.employer_name like '%us navy%'
  or pe.employer_name like '%us space force%'
  or pe.employer_name like '%usaf%'
  or pe.employer_name like '%uscg%'
  or pe.employer_name like '%usmc%'
  or pe.employer_name like '%usn %')
  or pe.fld_of_work = 'MIL'
  group by pe.id_number),

--- Ids gathered from last query to trigger past flag in the final query
pefin as (select distinct pve.id_number
from pve),



--- Current Employer in Veterans

ve as (select e.id_number, e.job_title, e.employer_name, e.fld_of_work
  from e
  where (e.employer_name like '%Air Force%'
  or e.employer_name like '%Armed Forces%'


--- Army

--- Watch out for companies with Army in title
--- Ex: Salvation Army
  or (e.employer_name like '%Army%'
  and e.employer_name not like '%Salvation Army%'
    and e.employer_name not like '%BrandArmy%'
  and e.employer_name not like '%Hind Musafir Agcy.%'
  and e.employer_name not like '%Swiss Army Brands Inc%' )

  or e.employer_name like '%Coast Guard%'
  or e.employer_name like '%Marine Corps%'

or (e.employer_name like '%Military%'
and e.employer_name not like '%University of Phoenix Overseas Military Campus%')

--- Navy
--- Watch out for companies with Navy in Name

  or (e.employer_name like '%Navy%'
  --- Found Old Navy in Employer Data
  and e.employer_name not like '%Old Navy%'
  --- Navy Pier not in military
  and e.employer_name not like '%Navy Pier Inc.%'
  and e.employer_name not like '%Navy Pier Incorporated%')

  or e.employer_name like '%Space Force%'
  or e.employer_name like '%u.s. air force%'
  or e.employer_name like '%u.s. army%'
  or e.employer_name like '%u.s. coast guard%'
  or e.employer_name like '%u.s. marine corps%'
  or e.employer_name like '%u.s. navy%'
  or e.employer_name like '%u.s. space force%'
  or e.employer_name like '%united states air force%'
  or e.employer_name like '%united states army%'
  or e.employer_name like '%united states coast guard%'
  or e.employer_name like '%united states marine corps%'
  or e.employer_name like '%united states navy%'
  or e.employer_name like '%united states space force%'
  or e.employer_name like '%us air force%'
  or e.employer_name like '%us army%'
  or e.employer_name like '%us coast guard%'
  or e.employer_name like '%united states space force%'
  or e.employer_name like '%us marine corps%'
  or e.employer_name like '%us navy%'
  or e.employer_name like '%us space force%'
  or e.employer_name like '%usaf%'
  or e.employer_name like '%uscg%'
  or e.employer_name like '%usmc%'
  or e.employer_name like '%usn %')
  or e.fld_of_work = 'MIL'
  order by e.employer_name asc),

--- Special Handling Codes

KSM_Spec AS (Select spec.ID_NUMBER,
spec.NO_CONTACT,
spec.NO_EMAIL_IND,
spec.GAB,
spec.TRUSTEE,
spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),


linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number),

--- This subquery will pull the giving information that Kam is mentoning
Giving as (select
rpt_pbh634.v_ksm_giving_summary.ID_NUMBER,
rpt_pbh634.v_ksm_giving_summary.NGC_LIFETIME,
rpt_pbh634.v_ksm_giving_summary.NGC_CFY,
rpt_pbh634.v_ksm_giving_summary.NGC_PFY1,
rpt_pbh634.v_ksm_giving_summary.NGC_PFY2,
rpt_pbh634.v_ksm_giving_summary.NGC_PFY3,
rpt_pbh634.v_ksm_giving_summary.NGC_PFY4,
rpt_pbh634.v_ksm_giving_summary.NGC_PFY5,
rpt_pbh634.v_ksm_giving_summary.LAST_GIFT_DATE,
rpt_pbh634.v_ksm_giving_summary.NU_MAX_HH_LIFETIME_GIVING
from rpt_pbh634.v_ksm_giving_summary),

hh as (select *
from rpt_pbh634.v_ksm_giving_trans),

max_gift as (select hh.ID_NUMBER,
max (hh.DATE_OF_RECORD) keep (dense_rank First Order By hh.CREDIT_AMOUNT DESC,
hh.DATE_OF_RECORD DESC, hh.TX_NUMBER desc) As Date_of_record,
max (hh.CREDIT_AMOUNT)  keep (dense_rank First Order By hh.CREDIT_AMOUNT DESC,
hh.DATE_OF_RECORD DESC, hh.TX_NUMBER desc) As max_credit
from hh
group by hh.ID_NUMBER)

select entity.id_number,
       entity.record_type_code,
       entity.record_status_code,
       entity.prefix,
       entity.report_name,
       d.FIRST_KSM_YEAR,
       d.PROGRAM,
       d.PROGRAM_GROUP,
       h.HOUSEHOLD_CITY,
       h.HOUSEHOLD_STATE,
       h.HOUSEHOLD_COUNTRY,
       case when ve.id_number is not null then 'Y' end as primary_military_employed,
       case when pefin.id_number is not null then 'Y' end as past_military_employed,
       veterans.student_activity_code as KVA_Indicator,
       e.job_title as current_job_title,
       e.employer_name as current_employer,
       e.fld_of_work as current_fld_of_work,
       pve.past_job_title,
       pve.past_employer_name,
       pve.past_fld_of_work,
       linked.linkedin_address,
       giving.NGC_LIFETIME,
giving.NGC_CFY,
giving.NGC_PFY1,
giving.NGC_PFY2,
giving.NGC_PFY3,
giving.NGC_PFY4,
giving.NGC_PFY5,
giving.LAST_GIFT_DATE,
giving.NU_MAX_HH_LIFETIME_GIVING,
     max_gift.DATE_OF_RECORD as date_of_record_max_gift,
       max_gift.max_credit as max_gift_credit


from entity
left join rpt_pbh634.v_entity_ksm_households h on h.id_number = entity.id_number
inner join rpt_pbh634.v_entity_ksm_degrees d on d.id_number = entity.id_number
left join e on e.id_number = entity.id_number
left join ve on ve.id_number = entity.id_number
left join veterans on veterans.id_number = entity.id_number
left join pefin on pefin.id_number = entity.id_number
left join KSM_Spec on KSM_Spec.id_number = entity.id_number
left join pve on pve.id_number = entity.id_number
left join linked on linked.id_number = entity.id_number
left join Giving on Giving.id_number = entity.id_number
left join max_gift on max_gift.id_number = entity.id_number

--- Anyone in KVA, Current or Past Employment, Or Military Prefixes

where (ve.id_number is not null
or veterans.id_number is not null
or pefin.id_number is not null

--- Military Prefixes!
or entity.prefix = 'Capt.'
or entity.prefix = 'Col.'
or entity.prefix = 'Gen.'
or entity.prefix = 'Gnry. Sgt.'
or entity.prefix = 'Lt.'
or entity.prefix = 'Lt. Col.'
or entity.prefix = 'Lt. Comdr.'
or entity.prefix = 'Lt. Gen.'
or entity.prefix = 'Maj.'
or entity.prefix = 'Maj. Gen.'
or entity.prefix = 'Maj. Gen. Dr.'
or entity.prefix = 'Sgt.'
or entity.prefix = 'Spcl. Agent')

and entity.record_status_code IN ('A','L')
and (KSM_Spec.NO_CONTACT is null and
KSM_Spec.NO_EMAIL_IND is null)
order by  entity.last_name ASC
