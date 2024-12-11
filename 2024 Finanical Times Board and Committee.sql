WITH KAC AS (select k.id_number,
       k.committee_code,
       k.short_desc,
       k.status
From table (rpt_pbh634.ksm_pkg_tmp.tbl_committee_kac) k),

GAB AS (Select g.id_number,
       g.short_desc,
       g.status
From table(rpt_pbh634.ksm_pkg_tmp.tbl_committee_gab) g),

G as (Select
gc.*
From table(rpt_pbh634.ksm_pkg_tmp.tbl_geo_code_primary) gc
Inner Join address
On address.id_number = gc.id_number
And address.xsequence = gc.xsequence),

--- Continent

C as (select *
from RPT_PBH634.v_addr_continents),

--- Home

Home as (Select DISTINCT
      a.Id_number
      ,  max(tms_address_type.short_desc) AS Address_Type
      ,  max(a.city) as city
      ,  max (a.state_code) as state_code
      ,  max (c.country) as country
      ,  max (a.start_dt)
      ,  max (G.GEO_CODE_PRIMARY_DESC) AS home_GEO_CODE
      ,  max (C.continent) as continent
      FROM address a
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN C ON C.country_code = A.COUNTRY_CODE
      LEFT JOIN g ON g.id_number = A.ID_NUMBER
      AND g.xsequence = a.xsequence
      WHERE (a.addr_status_code = 'A'
      AND a.addr_type_code = 'H')
      Group By a.id_number),

--- Business

Business As(Select DISTINCT
        a.Id_number
      ,  max(tms_address_type.short_desc) AS Address_Type
      ,  max(a.city) as city
      ,  max (a.state_code) as state_code
      ,  max (c.country) as country
      ,  max (a.start_dt)
      ,  max (G.GEO_CODE_PRIMARY_DESC) AS BUSINESS_GEO_CODE
      ,  max (C.continent) as continent
      FROM address a
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN C ON C.country_code = A.COUNTRY_CODE
      LEFT JOIN g ON g.id_number = A.ID_NUMBER
      AND g.xsequence = a.xsequence
      WHERE (a.addr_status_code = 'A'
      AND a.addr_type_code = 'B')
      Group By a.id_number),


--- women's leadership

W AS (Select p.id_number,
       p.short_desc,
       p.status
From table(rpt_pbh634.ksm_pkg_tmp.tbl_committee_womensLeadership) P),

--- Exec Board of Asia

A AS (Select a.id_number,
       a.short_desc,
       a.status
From table(rpt_pbh634.ksm_pkg_tmp.tbl_committee_asia) A),

--- Young Alumni

YA AS (Select y.id_number,
       y.short_desc,
       y.status
From table(rpt_pbh634.ksm_pkg_tmp.tbl_committee_yab) y),

S AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_PHONE_IND,
       spec.NO_EMAIL_IND,
       spec.NO_MAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

emplid as (Select ids_base.id_number
    , ids_base.ids_type_code
    , ids_base.other_id
  From entity e --- Kellogg Alumni Only
  Left Join ids_base
    On ids_base.id_number = e.id_number
  Where ids_base.ids_type_code In ('SES')) --- SES = EMPLID + KSF = Salesforce ID + NET = NetID + KEX = KSM EXED ID



Select entity.id_number,
       emplid.other_id as emplid,
       entity.record_type_code,
       entity.first_name,
       entity.last_name,
       entity.gender_code,
       entity.institutional_suffix,
       home.city as home_city,
       home.state_code as home_state,
       home.home_GEO_CODE as home_geo_code,
       home.country as home_country,
       business.city as business_city,
       business.state_code as business_state,
       business.BUSINESS_GEO_CODE as business_geo_code,
       business.country as business_country,
       TMS_COUNTRY.short_desc as citizenship1_desc,
       TMS_COUNTRY2.short_desc as citizenship2_desc,
       case when TMS_COUNTRY.short_desc != 'United States' and TMS_COUNTRY.short_desc is not null
                   or TMS_COUNTRY2.short_desc != 'United States' and TMS_COUNTRY2.short_desc is not null then 'International Citizen' end as International_Citizen,
       case when KAC.id_number is not null then 'X' end as KAC_IND,
         case when GAB.id_number is not null then 'X' END as GAB_IND,
           case when A.id_number is not null then 'X' END as EXEC_ASIA_IND,
             case when YA.id_number is not null then 'X' End as Young_Alumni_Board_IND,
               case when W.id_number is not null then 'X' End as WOMEN_LEADERSHIP_IND,

      S.NO_CONTACT,
      S.NO_PHONE_IND,
      S.NO_EMAIL_IND,
      S.NO_MAIL_IND
from entity
left join KAC ON KAC.id_number = entity.id_number
left join GAB ON GAB.id_number = entity.id_number
left join A ON A.id_number = entity.id_number
left join W ON W.id_number = entity.id_number
left join YA ON YA.id_number = entity.id_number
left join TMS_COUNTRY on TMS_COUNTRY.country_code = entity.citizen_cntry_code1
left join TMS_COUNTRY TMS_COUNTRY2 on TMS_COUNTRY2.country_code = entity.citizen_cntry_code2
left join S ON S.ID_NUMBER = entity.id_number
left join home on home.id_number = entity.id_number
left join business on business.id_number = entity.id_number
left join emplid on emplid.id_number = entity.id_number
Where (KAC.id_number is not null
or GAB.id_number is not null
or A.id_number is not null
or W.id_number is not null
or YA.id_number is not null)
order by entity.last_name asc
