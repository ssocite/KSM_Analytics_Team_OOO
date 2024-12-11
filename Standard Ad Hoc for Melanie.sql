With h as (Select
h.id_number,
       h.REPORT_NAME,
       h.SPOUSE_ID_NUMBER,
       h.SPOUSE_REPORT_NAME,
       h.RECORD_STATUS_CODE,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       h.EVALUATION_RATING,
       h.evaluation_date,
       h.OFFICER_RATING,
       h.uor,
       h.uor_date,
       h.prospect_id,
       v.primary_address_type,
       v.primary_city,
       v.primary_geo,
       v.primary_state,
       v.primary_country,
       v.non_preferred_home_type,
       v.non_preferred_home_city,
       v.non_pref_home_geo,
       v.non_preferred_home_state,
       v.non_preferred_home_country,
       v.non_preferred_business_type,
       v.non_preferred_business_geo,
       v.non_preferred_business_city,
       v.non_preferred_business_state,
       v.non_preferred_business_country,
       v.alt_home_type,
       v.alt_home_geo,
       v.alt_home_city,
       v.alt_home_state,
       v.alt_home_country,
       v.alt_bus_type,
       v.alt_business_geo,
       v.alt_bus_city,
       v.alt_bus_state,
       v.alt_bus_country,
       v.seasonal_Type,
       v.SEASONAL_GEO_CODE,
       v.seasonal_city,
       v.seasonal_state,
       v.seasonal_country,
       v.lookup_geo,
       v.lookup_state
From rpt_pbh634.v_ksm_prospect_pool h
inner join v_all_address v on v.id_number = h.id_number
Where lookup_state Like '%AZ%'),


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

--- However Giving Summary does not have biggest gift
---- The 3 subquries below should pull an entity's largest gift and the date of that gift

hh as (select *
from rpt_pbh634.v_ksm_giving_trans),

max_gift as (select hh.ID_NUMBER,
max (hh.DATE_OF_RECORD) keep (dense_rank First Order By hh.CREDIT_AMOUNT DESC,
hh.DATE_OF_RECORD DESC, hh.TX_NUMBER desc) As Date_of_record,
max (hh.CREDIT_AMOUNT)  keep (dense_rank First Order By hh.CREDIT_AMOUNT DESC,
hh.DATE_OF_RECORD DESC, hh.TX_NUMBER desc) As max_credit
from hh
group by hh.ID_NUMBER),


--- pulling primary employer
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

--- KSM PM, LGO, Manager

a as (select distinct assign.id_number,
assign.prospect_manager,
assign.lgos,
assign.managers
from rpt_pbh634.v_assignment_summary assign),


--- Special Handling

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
From rpt_pbh634.v_entity_special_handling),


---- Phone

P as (Select t.id_number,
t.preferred_ind,
t.telephone_type_code,
t.area_code,
t.telephone_number
From telephone t
where t.preferred_ind = 'Y'),

--- Email

e AS (select email.id_number,
       email.email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y')


select h.id_number,
       h.REPORT_NAME,
       h.SPOUSE_ID_NUMBER,
       h.SPOUSE_REPORT_NAME,
       h.RECORD_STATUS_CODE,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       employ.fld_of_work,
       employ.employer_name,
       employ.job_title,
       h.prospect_id,
       a.prospect_manager,
       a.lgos,
       a.managers,
       h.EVALUATION_RATING,
       h.evaluation_date,
       h.OFFICER_RATING,
       h.uor,
       h.uor_date,
       --- giving - NGC lifetime, NU lifetime, Giving last 5FY, Date last gift, Max gift/date
       giving.NGC_LIFETIME,
       giving.NU_MAX_HH_LIFETIME_GIVING,
       giving.NGC_CFY,
       giving.NGC_PFY1,
       giving.NGC_PFY2,
       giving.NGC_PFY3,
       giving.NGC_PFY4,
       giving.NGC_PFY5,
       giving.LAST_GIFT_DATE,
       max_gift.DATE_OF_RECORD as date_of_record_max_gift,
       max_gift.max_credit as max_gift_credit,
       --- Just providing flags for email and phone
       --- I don't usually share contact info if lists are > 100
      case when e.email_address is not null then 'Y' Else 'N' END As pref_email_ind,
       case when p.id_number is not null then 'Y' else 'N' end as pref_phone_ind,
         --- Special Handling Codes Relevent to project
       spec.GAB,
       spec.TRUSTEE,
       spec.EBFA,
       spec.NO_CONTACT,
       spec.NO_SOLICIT,
       spec.NO_PHONE_IND,
       spec.NO_EMAIL_IND,
       spec.NO_MAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT,
       ---- Finding out Why an entity is on the list!
       ---- This will find any entity with an address in florida
       h.primary_address_type,
       h.primary_city,
       h.primary_geo,
       h.primary_state,
       h.primary_country,
       h.non_preferred_home_type,
       h.non_preferred_home_city,
       h.non_pref_home_geo,
       h.non_preferred_home_state,
       h.non_preferred_home_country,
       h.non_preferred_business_type,
       h.non_preferred_business_geo,
       h.non_preferred_business_city,
       h.non_preferred_business_state,
       h.non_preferred_business_country,
       h.alt_home_type,
       h.alt_home_geo,
       h.alt_home_city,
       h.alt_home_state,
       h.alt_home_country,
       h.alt_bus_type,
       h.alt_business_geo,
       h.alt_bus_city,
       h.alt_bus_state,
       h.alt_bus_country,
       h.seasonal_Type,
       h.SEASONAL_GEO_CODE,
       h.seasonal_city,
       h.seasonal_state,
       h.seasonal_country,
       h.lookup_geo,
       h.lookup_state
--- Base is prospect view
from h
left join giving on giving.id_number = h.id_number
left join max_gift on max_gift.id_number = h.id_number
left join p on p.id_number = h.id_number
left join employ on employ.id_number = h.id_number
left join a on a.id_number = h.id_number
left join e on e.id_number = h.id_number
left join Spec on Spec.id_number = h.id_number
order by h.report_name asc
