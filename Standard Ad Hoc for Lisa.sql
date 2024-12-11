with v as (select v.id_number,
       v.primary_address_type,
       v.primary_city,
       v.primary_geo,
       v.primary_state,
       v.primary_zipcode,
       v.primary_country,
       v.primary_country_code,
       v.continent,
       v.non_preferred_home_type,
       v.non_preferred_home_city,
       v.non_pref_home_geo,
       v.non_preferred_home_state,
       v.non_preferred_home_zipcode,
       v.non_preferred_home_country,
       v.non_pref_home_country_code,
       v.non_preferred_home_continent,
       v.non_preferred_business_type,
       v.non_preferred_business_geo,
       v.non_preferred_business_city,
       v.non_preferred_business_state,
       v.non_preferred_business_zipcode,
       v.non_preferred_business_country,
       v.non_pref_business_country_code,
       v.non_preferred_busin_continent,
       v.alt_home_type,
       v.alt_home_geo,
       v.alt_home_city,
       v.alt_home_state,
       v.alt_home_zipcode,
       v.alt_home_country,
       v.alt_home_country_code,
       v.alt_home_continent,
       v.alt_bus_type,
       v.alt_business_geo,
       v.alt_bus_city,
       v.alt_bus_state,
       v.alt_bus_zipcode,
       v.alt_bus_country,
       v.alt_bus_country_code,
       v.alt_bus_continent,
       v.seasonal_Type,
       v.SEASONAL_GEO_CODE,
       v.seasonal_city,
       v.seasonal_state,
       v.seasonal_zipcode,
       v.seasonal_country,
       v.seasonal_country_code,
       v.seasonal_continent,
       v.lookup_geo,
       v.lookup_state,
       v.lookup_zipcode,
       v.lookup_country,
       v.lookup_continent
from v_all_address v
where  v.lookup_country like '%Spain%'),


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
from rpt_pbh634.v_ksm_giving_summary give)

select house.ID_NUMBER,
       house.REPORT_NAME,
       entity.gender_code,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       employ.job_title,
       employ.employer_name,
       employ.fld_of_work,
       linked.linkedin_address,
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
g.NGC_PFY5,
v.primary_address_type,
       v.primary_city,
       v.primary_country,
       v.non_preferred_home_city,
       v.non_preferred_home_country,
       v.non_preferred_business_city,
       v.non_preferred_business_country,
       v.alt_home_city,
       v.alt_home_country,
       v.alt_bus_city,
       v.alt_bus_country,
       v.seasonal_city,
       v.seasonal_country,
       v.lookup_country
from rpt_pbh634.v_entity_ksm_households house
inner join entity on entity.id_number = house.ID_NUMBER
inner join v on v.id_number = house.id_number
left join employ on employ.id_number = house.ID_NUMBER

left join linked on linked.id_number = house.id_number
left join s on s.id_number = house.id_number
left join g on g.id_number = house.id_number
where house.PROGRAM is not null
--- remove no contacts
and s.NO_CONTACT is null
order by employ.job_title ASC
