with a as (select
v_all_address.id_number,
     v_all_address.primary_address_type,
     v_all_address.primary_city,
     v_all_address.primary_geo,
     v_all_address.primary_state,
     v_all_address.primary_zipcode,
     v_all_address.primary_country,
     v_all_address.primary_country_code,
     v_all_address.continent,
     v_all_address.non_preferred_home_type,
     v_all_address.non_preferred_home_city,
     v_all_address.non_pref_home_geo,
     v_all_address.non_preferred_home_state,
     v_all_address.non_preferred_home_zipcode,
     v_all_address.non_preferred_home_country,
     v_all_address.non_pref_home_country_code,
     v_all_address.non_preferred_home_continent,
     v_all_address.non_preferred_business_type,
     v_all_address.non_preferred_business_geo,
     v_all_address.non_preferred_business_city,
     v_all_address.non_preferred_business_state,
     v_all_address.non_preferred_business_zipcode,
     v_all_address.non_preferred_business_country,
     v_all_address.non_pref_business_country_code,
     v_all_address.non_preferred_busin_continent,
     v_all_address.alt_home_type,
     v_all_address.alt_home_geo,
     v_all_address.alt_home_city,
     v_all_address.alt_home_state,
     v_all_address.alt_home_zipcode,
     v_all_address.alt_home_country,
     v_all_address.alt_home_country_code,
     v_all_address.alt_home_continent,
     v_all_address.alt_bus_type,
     v_all_address.alt_business_geo,
     v_all_address.alt_bus_city,
     v_all_address.alt_bus_state,
     v_all_address.alt_bus_zipcode,
     v_all_address.alt_bus_country,
     v_all_address.alt_bus_country_code,
     v_all_address.alt_bus_continent,
     v_all_address.seasonal_Type,
     v_all_address.SEASONAL_GEO_CODE,
     v_all_address.seasonal_city,
     v_all_address.seasonal_state,
     v_all_address.seasonal_zipcode,
     v_all_address.seasonal_country,
     v_all_address.seasonal_country_code,
     v_all_address.seasonal_continent,
     v_all_address.lookup_geo,
     v_all_address.lookup_state,
     v_all_address.lookup_zipcode,
     v_all_address.lookup_country,
     v_all_address.lookup_continent
     from v_all_address
     where v_all_address.lookup_country like '%Brazil%'),

     KSM_Spec AS (Select spec.ID_NUMBER,
       spec.SPECIAL_HANDLING_CONCAT,
       spec.GAB,
       spec.TRUSTEE,
       spec.EBFA,
       spec.NO_CONTACT,
       spec.NO_PHONE_IND,
       spec.NO_EMAIL_IND,
       spec.NO_MAIL_IND
From rpt_pbh634.v_entity_special_handling spec)


select  rpt_pbh634.v_entity_ksm_households.ID_NUMBER,
        rpt_pbh634.v_entity_ksm_households.REPORT_NAME,
        rpt_pbh634.v_entity_ksm_households.INSTITUTIONAL_SUFFIX,
        rpt_pbh634.v_entity_ksm_households.FIRST_KSM_YEAR,
        rpt_pbh634.v_entity_ksm_households.PROGRAM,
        rpt_pbh634.v_entity_ksm_households.PROGRAM_GROUP,
        rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_CITY,
        rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_STATE,
        rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_ZIP,
        rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_GEO_PRIMARY_DESC,
        rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_COUNTRY,
     a.primary_city,
     a.primary_country,
     a.non_preferred_home_city,
     a.non_preferred_home_country,
     a.non_preferred_business_city,
     a.non_preferred_business_country,
     a.alt_home_city,
     a.alt_home_country,
     a.alt_bus_city,
     a.alt_bus_country,
     a.seasonal_city,
     a.seasonal_country,
     a.lookup_country,
      TMS_COUNTRY.short_desc as citizenship1_desc,
       TMS_COUNTRY2.short_desc as citizenship2_desc
from rpt_pbh634.v_entity_ksm_households
left join a on a.id_number  = rpt_pbh634.v_entity_ksm_households.id_number
inner join entity e on e.id_number = rpt_pbh634.v_entity_ksm_households.id_number
left join TMS_COUNTRY on TMS_COUNTRY.country_code = e.citizen_cntry_code1
left join TMS_COUNTRY TMS_COUNTRY2 on TMS_COUNTRY2.country_code = e.citizen_cntry_code2
left join KSM_Spec on KSM_Spec.id_number = rpt_pbh634.v_entity_ksm_households.ID_NUMBER
where rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_GEO_CODES like '%New York%'
--- Have an Any Address in Brazil OR Have a Citzenship in Brazil
and (a.id_number is not null
or TMS_COUNTRY.short_desc  = 'Brazil'
or TMS_COUNTRY2.short_desc  = 'Brazil')
and KSM_Spec.NO_CONTACT is null
and rpt_pbh634.v_entity_ksm_households.PROGRAM is not null
