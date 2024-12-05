--- We want KSM alumni that are primary households
--- We also want a spouse that is KSM alumni in the final list (case when in the final query)
with h as (select h.ID_NUMBER,
       h.REPORT_NAME,
       h.PREF_MAIL_NAME,
       h.HOUSEHOLD_PRIMARY,
       h.HOUSEHOLD_NAME,
       h.RECORD_STATUS_CODE,
       h.DEGREES_CONCAT,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       h.SPOUSE_ID_NUMBER,
       h.SPOUSE_REPORT_NAME,
       h.SPOUSE_FIRST_KSM_YEAR,
       h.SPOUSE_SUFFIX,
       h.SPOUSE_PROGRAM,
       h.SPOUSE_PROGRAM_GROUP
From rpt_pbh634.v_entity_ksm_households h
--- We just want KSM Alumni, Active Records and Primary Householders
where h.PROGRAM is not null
and h.RECORD_STATUS_CODE = 'A'
and h.HOUSEHOLD_PRIMARY = 'Y'),

--- Pulls in Preferred Address

KSM_Address AS

(Select Address.Id_Number,
        Address.Addr_Type_Code,
        TMS_ADDRESS_TYPE.short_desc as address_type,
        Address.Addr_Pref_Ind,
        address.company_name_1,
        address.street1,
        address.street2,
        address.street3,
        address.city,
        --- add zipcode
        address.zipcode,
        Address.State_Code,
        TMS_States.short_desc As State,
        Address.Country_Code,
        TMS_COUNTRY.short_desc,
               Case When TMS_Country.short_desc is null then 'United States'
         Else TMS_Country.short_desc END AS Country
From Address
Left Join TMS_ADDRESS_TYPE on TMS_ADDRESS_TYPE.addr_type_code = Address.Addr_Type_Code
Left Join TMS_COUNTRY ON TMS_COUNTRY.country_code = address.country_code
Left Join TMS_States ON TMS_States.state_code = Address.State_Code
Where Address.Addr_Pref_Ind = 'Y'),

--- Special Handling Codes:

KSM_SH AS
(Select spec.ID_NUMBER,
       spec.SPEC_HND_CODES,
       spec.MAILING_LIST_CONCAT,
       spec.ML_CODES,
       spec.NO_CONTACT,
       spec.NO_MAIL_IND
From rpt_pbh634.v_entity_special_handling spec),

--- Taking out the that 89 KM EXC Code (Kellogg World Alumni Magazine) has a control of Exclude)
--- Make sure to left join and then where is null to exclude

MC as (
SELECT m.id_number
 FROM  mailing_list m
 WHERE  m.mail_list_code = '89'
   AND  M.MAIL_LIST_STATUS_CODE = 'A'
   AND  m.mail_list_ctrl_code = 'EXC')

select h.ID_NUMBER,
       h.HOUSEHOLD_PRIMARY,
       h.PREF_MAIL_NAME,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       case when h.SPOUSE_PROGRAM is not null then h.SPOUSE_ID_NUMBER end as ksm_spouse_id_number,
       case when h.SPOUSE_PROGRAM is not null then h.SPOUSE_REPORT_NAME end as KSM_Spouse_Name,
         case when h.SPOUSE_PROGRAM is not null then h.SPOUSE_SUFFIX end as KSM_Spouse_Name,
       KSM_Address.addr_pref_ind as preferred_address_ind,
       KSM_Address.addr_type_code as preferred_address_type,
       KSM_Address.address_type as preferred_address_type_desc,
       Case when KSM_Address.Addr_Type_Code = 'B'
         or KSM_Address.Addr_Type_Code = 'AB' then  KSM_Address.company_name_1 end as company,
       KSM_Address.street1,
       KSM_Address.street2,
       KSM_Address.street3,
       KSM_Address.city,
       KSM_Address.zipcode,
       KSM_Address.state,
       KSM_Address.Country
From h
--- Looking for preferred address only
Inner Join KSM_Address ON KSM_Address.id_number = h.ID_NUMBER
Left Join KSM_SH on KSM_SH.id_number = h.id_number
Left Join MC On MC.id_number = H.id_number
--- Take out No contact
where (KSM_SH.no_contact is null
--- Take Out No Mail
and KSM_SH.no_mail_ind is null
--- Double Check the Exlcusion of 89 KM EXC Code (Kellogg World Alumni Magazine) has a control of Exclude)
and MC.id_number is null)
and KSM_Address.Country = 'United States'
order by KSM_Address.state ASC
