With ve as (Select
       v.id_number,
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
From   v_all_address v),


-- General Employment

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


--- Employment, but for Kellogg and Pepsi companies I could find

efinal as (Select employ.id_number
  , employ.job_title
  , employ.fld_of_work_code
  , employ.fld_of_work
  , employ.employer_name
from employ
where (employ.employer_name  Like '%Ant Group%'
or employ.employer_name  Like '%Stripe Inc%'
or employ.employer_name  Like '%Revolut%'
or employ.employer_name  Like '%Chime Financial%'
or employ.employer_name  Like '%Rapyd%'
or employ.employer_name  Like '%Plaid%'
or employ.employer_name  Like '%Brex Inc%'
or employ.employer_name  Like '%GoodLeap%'
or employ.employer_name  Like '%Bolt%'
or employ.employer_name  Like '%Checkout.com%'
or employ.employer_name  Like '%OakNorth%'
or employ.employer_name  Like '%Airwallex%'
or  employ.employer_name  Like'%Plaid%'
or  employ.employer_name  Like'%PayJoy%'
or  employ.employer_name  Like'%Ramp%'
or  employ.employer_name  Like'%Tradeshift%'
or  employ.employer_name  Like'%Debbie%'
or  employ.employer_name  Like'%Nav.it%'
or  employ.employer_name  Like'%Tala%'
or  employ.employer_name  Like'%Stripe%'
or  employ.employer_name  Like'%OpenSea%'
or  employ.employer_name  Like'%Talos%'
or  employ.employer_name  Like'%Current%'
or  employ.employer_name  Like'%Mercury%'
or  employ.employer_name  Like'%Greenwood Bank%'
or  employ.employer_name  Like'%Dave%'
or  employ.employer_name  Like'%BillGO%'
or  employ.employer_name  Like'%Divvy Homes%'
or  employ.employer_name  Like'%Avalanche%'
or  employ.employer_name  Like'%CoinFlip%'
or  employ.employer_name  Like'%Stax Payments%'
or  employ.employer_name  Like'%Melio%'
or  employ.employer_name  Like'%Greenlight%'
or  employ.employer_name  Like'%Rocket Money%'
or  employ.employer_name  Like'%Nibble Health%'
or  employ.employer_name  Like'%Petal%'
or  employ.employer_name  Like'%GoodLeap%'
or employ.employer_name  Like  '%Kraken%'
or employ.employer_name  =  'Bolt'
or employ.employer_name  =  'Modern Treasury'
or employ.employer_name  =  'Stripe'
or employ.employer_name  =  'Block'
or employ.employer_name  =  'SOFI'
or employ.employer_name  =  'Chime'
or employ.employer_name  =  'Chime - Mobile Banking'
or employ.employer_name  =  'Coinbase'
or employ.employer_name  =  'Circle'
or employ.employer_name  =  'Ripple'
or employ.employer_name  like  '%Ripple%'
or employ.employer_name  =  'Canaan Partners'
or employ.employer_name  Like  '%Galaxy Digital%'
or employ.employer_name  Like  '%Riot Blockchain%'
or employ.employer_name  Like  '%Silvergate Capital%'
or employ.employer_name  Like  '%Marathon Digital Holdings%'
or employ.employer_name  Like  '%Crypto%'
or employ.employer_name  Like  '%Blockchain%'
or employ.employer_name  Like  '%Bitcoin%'
or employ.employer_name  Like  '%DeFi%'
or employ.employer_name  Like  '%SpotOn%'
or employ.employer_name  =  'SpotOn'
OR employ.employer_name  =  'PayPal'
Or employ.employer_name  like  '%PayPal%'
OR employ.employer_name  =  'Mastercard'
Or employ.employer_name  =  'Mastercard Inc.'
Or employ.employer_name  like  '%Mastercard%'
OR employ.employer_name  Like  '%Stripe%'
OR employ.employer_name  =  'Stripe'
OR employ.employer_name  =  'Affirm'
OR employ.employer_name  Like  '%Affirm%'
OR employ.employer_name  Like  '%Square%'
OR employ.employer_name  =  'Square'

OR employ.employer_name  Like  '%Intuit%'
OR employ.employer_name  =  'Intuit'

OR employ.employer_name  Like  '%Robinhood%'
OR employ.employer_name  =  'Robinhood'

OR employ.employer_name  Like  '%Toast%'
OR employ.employer_name  =  'Toast'

OR employ.employer_name  Like  '%Ally Financial Inc%'
OR employ.employer_name  =  'Ally Financial Inc'

OR employ.employer_name  Like  '%Deel%'
OR employ.employer_name  =  'Deel'

OR employ.employer_name  Like  '%Brex Inc.%'
OR employ.employer_name  =  'Brex Inc.'


OR employ.employer_name  Like  '%OpenSea%'
OR employ.employer_name  =  'OpenSea'

OR employ.employer_name  Like  '%Plaid%'
OR employ.employer_name  =  'Plaid'

OR employ.employer_name  Like  '%Affirm Holdings Inc.%'
OR employ.employer_name  =  'Affirm Holdings Inc.'

OR employ.employer_name  Like  '%Block Inc.%'
OR employ.employer_name  =  'Block Inc.'

OR employ.employer_name  Like  '% Fiserv Inc.%'
OR employ.employer_name  =  'Fiserv Inc.'

)),

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
group by hh.ID_NUMBER),


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


a as (select distinct assign.id_number,
assign.prospect_manager,
assign.lgos,
assign.managers
from rpt_pbh634.v_assignment_summary assign),

TP AS (SELECT TP.ID_NUMBER,
       TP.EVALUATION_RATING,
       TP.OFFICER_RATING
From nu_prs_trp_prospect TP),

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number)


select efinal.id_number ,
d.REPORT_NAME,
d.RECORD_STATUS_CODE,
d.INSTITUTIONAL_SUFFIX,
d.SPOUSE_ID_NUMBER,
d.SPOUSE_REPORT_NAME,
d.PROGRAM,
d.PROGRAM_GROUP,
efinal.job_title,
efinal.employer_name,
efinal.fld_of_work,
linked.linkedin_address,
d.HOUSEHOLD_CITY,
d.HOUSEHOLD_STATE,
d.HOUSEHOLD_GEO_PRIMARY_DESC,
a.prospect_manager,
a.lgos,
a.managers,
TP.EVALUATION_RATING,
TP.OFFICER_RATING,
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
max_gift.max_credit as max_gift_credit,
spec.GAB,
spec.TRUSTEE,
spec.EBFA,
spec.NO_CONTACT,
spec.NO_SOLICIT,
spec.NO_PHONE_IND,
spec.NO_EMAIL_IND,
spec.NO_MAIL_IND,
spec.SPECIAL_HANDLING_CONCAT,
ve.primary_address_type,
ve.primary_city,
ve.primary_geo,
ve.primary_state,
ve.primary_country,
ve.non_preferred_home_type,
ve.non_preferred_home_city,
ve.non_pref_home_geo,
ve.non_preferred_home_state,
ve.non_preferred_home_country,
ve.non_preferred_business_type,
ve.non_preferred_business_geo,
ve.non_preferred_business_city,
ve.non_preferred_business_state,
ve.non_preferred_business_country,
ve.alt_home_type,
ve.alt_home_geo,
ve.alt_home_city,
ve.alt_home_state,
ve.alt_home_country,
ve.alt_bus_type,
ve.alt_business_geo,
ve.alt_bus_city,
ve.alt_bus_state,
ve.alt_bus_country,
ve.seasonal_Type,
ve.SEASONAL_GEO_CODE,
ve.seasonal_city,
ve.seasonal_state,
ve.seasonal_country,
ve.lookup_geo,
ve.lookup_state
from efinal
inner join rpt_pbh634.v_entity_ksm_households d on d.id_number = efinal.id_number
--- Any Active Address in Chicago
inner join ve on ve.id_number = efinal.id_number
left join Giving on Giving.id_number = efinal.id_number
left join max_gift on max_gift.id_number = efinal.id_number
left join a on a.id_number = efinal.id_number
left join Spec on Spec.id_number = efinal.id_number
left join TP on TP.id_number = efinal.id_number
left join linked on linked.id_number = efinal.id_number
where (
--- food industry
efinal.id_number is not null
--- KSM Alumni
and d.PROGRAM is not null
--- Active of Lost Records
and d.RECORD_STATUS_CODE IN ('A','L')
and spec.NO_CONTACT is null
)
order by efinal.employer_name asc
