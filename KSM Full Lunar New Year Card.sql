/*


• Catracks IDs
• First Name
• Last Name
• Country
• Program
• Gift Officer, if they have one
• Kellogg Alumni Board of Asia (Y/N)
• GAB (Y/N)
• Trustee (Y/N)
• No Email Code (Y/N)
• No Contact Code (Y/N)
•     Include KSM alumni that have a business address in the requested countries even if their household address is not located in them

*/

--- Household address
--- This will pull household address in the countries requested

with hh as (select rpt_pbh634.v_entity_ksm_households.ID_NUMBER
from rpt_pbh634.v_entity_ksm_households
where rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_COUNTRY IN ('China',
'Hong Kong', 'Vietnam', 'South Korea', 'Singapore',
'Malaysia', 'Philippines', 'Indonesia', 'Thailand', 'Taiwan')),

---- Business Address for the next three subquries

G as (Select
gc.*
From table(rpt_pbh634.ksm_pkg_tmp.tbl_geo_code_primary) gc
Inner Join address
On address.id_number = gc.id_number
And address.xsequence = gc.xsequence),

--- Continent

C as (select *
from RPT_PBH634.v_addr_continents),

--- This will pull the most recent and active business address in the countries requested.

b as (Select DISTINCT
        a.Id_number
      ,  max (tms_address_type.short_desc) keep (dense_rank first order by a.start_dt desc) AS Address_Type
      ,  max (a.city) keep (dense_rank first order by a.start_dt desc) as city
      ,  max (a.state_code) keep (dense_rank first order by a.start_dt desc) as state_code
      ,  max (c.country) keep (dense_rank first order by a.start_dt desc) as country
      ,  max (a.start_dt) keep (dense_rank first order by a.start_dt desc) as start_dt
      ,  max (G.GEO_CODE_PRIMARY_DESC) keep (dense_rank first order by a.start_dt desc) AS BUSINESS_GEO_CODE
      FROM address a
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN C ON C.country_code = A.COUNTRY_CODE
      LEFT JOIN g ON g.id_number = A.ID_NUMBER
      AND g.xsequence = a.xsequence
      WHERE (a.addr_status_code = 'A'
      AND a.addr_type_code = 'B')
      AND tms_country.short_desc IN ('China',
'Hong Kong', 'Vietnam', 'South Korea', 'Singapore',
'Malaysia', 'Philippines', 'Indonesia', 'Thailand', 'Taiwan')
Group By a.id_number),

--- special handling codes requested

KSM_Spec AS (Select spec.ID_NUMBER,
spec.NO_CONTACT,
spec.NO_EMAIL_IND,
spec.GAB,
spec.TRUSTEE,
spec.EBFA
From rpt_pbh634.v_entity_special_handling spec),


--- Non Alumni Donors included too! Use the prospect pool

p as  (Select *
From rpt_pbh634.v_ksm_prospect_pool p
--- We Just Want People from this Pull!
where p.PERSON_OR_ORG = 'P'),

--- LGOs, PM

assign as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

--- All of Dean Cornelli's Visits
--- Pick the distinct IDs that have had at least one visit and pull their most recent visit with the Dean

dean as (
select
    f.id_number,
    max (f.credited) keep (dense_rank first order by contact_date desc) as credited_ID,
    max (f.credited_name) keep (dense_rank first order by contact_date desc) as credited_name,
    max (f.contact_type) keep (dense_rank first order by contact_date desc) as contact_type,
    max (f.contact_purpose) keep (dense_rank first order by contact_date desc) as contact_purpose,
    max (f.contacted_name) keep (dense_rank first order by contact_date desc) as contact_name,
    max (f.prospect_name) keep (dense_rank first order by contact_date desc) as prospect_name,
    max (f.contact_date) keep (dense_rank first order by contact_date desc) as contact_date,
    max (f.description) keep (dense_rank first order by contact_date desc) as description_,
    max (f.summary) keep (dense_rank first order by contact_date desc) as summary
from rpt_pbh634.v_contact_reports_fast f
where f.contact_type_code = 'V'
and f.credited = '0000804796'
group by f.id_number
),

--- Manually adding Leontine Chuang,
--- Anderson and Imelda  Tanoto

l as (select entity.id_number
from entity
where entity.id_number IN ('0000282677', '0000647543',
'0000842786')),

--- Club Leader in Selected Countries

club as (select c.id_Number,
       Listagg (c.Club_Title, ';  ') Within Group (Order By c.Club_Title) As Club_Title,
       Listagg (c.Leadership_Title, ';  ') Within Group (Order By c.Leadership_Title) As Leader_Title
from v_ksm_club_leaders c
where (c.Club_Title like '%China%'
or c.Club_Title like '%Hong Kong%'
or c.Club_Title like '%Vietnam%'
or c.Club_Title like '%South Korea%'
or c.Club_Title like '%Singapore%'
or c.Club_Title like '%Malaysia%'
or c.Club_Title like '%Philippines%'
or c.Club_Title like '%Indonesia%'
or c.Club_Title like '%Thailand%'
or c.Club_Title like '%Taiwan%')
group by c.id_number),

tp as (select p.id_number,
P.evaluation_rating,
P.Officer_rating
from nu_prs_trp_prospect P),

e AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Where email.preferred_ind = 'Y'),
--- Alternative Emails

ae AS (select distinct email.id_number
       , Listagg (email.email_address, ';  ') Within Group (Order By email.email_address) As Alt_Email
From email
Where email.preferred_ind = 'N'
And email.email_status_code = 'A'
Group By email.id_number)


select distinct h.id_number,
       entity.record_type_code,
       entity.record_status_code,
--- First Name
       entity.first_name,
--- Last Name
       entity.last_name,
       entity.Gender_Code,
       entity.institutional_suffix,
--- Program Information
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
--- Household Address Information
       h.HOUSEHOLD_CITY,
       h.HOUSEHOLD_ZIP,
       h.HOUSEHOLD_STATE,
       h.HOUSEHOLD_COUNTRY,
       h.HOUSEHOLD_CONTINENT,
       case when hh.id_number is null then b.city end as business_city,
         case when hh.id_number is null then b.state_code end as business_state,
           case when hh.id_number is null then b.country end as business_country,
--- Club Leadership Flag: The Club and Leadership position
case when club.id_Number is not null then club.club_title end as club_title,
case when club.id_Number is not null then club.Leader_Title end as Leader_Title,

---- Prospect Manager
       assign.prospect_manager,
---- LGO
       assign.lgos,
--- Managers Concat
       assign.managers,
       tp.evaluation_rating,
       tp.Officer_rating,
--- GAB, Trustee, No Contact, No Email Special Handling Codes
       KSM_Spec.GAB as GAB_IND,
       KSM_Spec.TRUSTEE as Trustee_IND,
       KSM_spec.EBFA,
       e.email_address,
       ae.Alt_Email,
       KSM_Spec.NO_CONTACT,
       KSM_Spec.NO_EMAIL_IND,
       dean.credited_ID,
       dean.credited_name,
       dean.contact_type,
       dean.contact_purpose,
       dean.contact_name,
       dean.prospect_name,
       dean.contact_date,
       dean.description_,
       dean.summary

from rpt_pbh634.v_entity_ksm_households h
--- Pulling in Non KSM Alumni too. So, we want KSM prospects too from the prospect pool
left join p on p.id_number = h.id_number
left join KSM_Spec on KSM_Spec.id_number = h.id_number
left join entity on entity.id_number = h.id_number
left join assign on assign.id_number = h.id_number
--- Household Address
left join hh on hh.id_number = h.id_number
--- Business Address
left join b on b.id_number = h.id_number
--- Dean's Visits on the card
left join dean on dean.id_number = h.id_number
--- Manually adding Leontine Denise Chuang #282677
left join l on l.id_number = h.id_number
--- Club member in ad hoc countries
left join club on club.id_number = h.id_number
--- Need to join TP pool - Because manual additions aren't in prospect pool
left join tp on tp.id_number = h.id_number
--- emails!
left join e on e.id_number = h.id_number
--- alt emails
left join ae on ae.id_number = h.id_number

Where
--- Anyone on the KSM prospect pool - And the one Manual Addition, And Any associatated club leader
(l.id_number is not null
or p.id_number is not null
or club.id_number is not null)

AND

--- Anyone from above with HH OR Business address in China, Hong Kong (separate from the rest of China), Vietnam, South Korea,
---- Singapore, Malaysia, Philippines, Indonesia, Thailand,

(--- Anyone with a HH address
hh.id_number is not null
--- Anyone with a business address
or b.id_number is not null
--- OR is a club leader in one of the requested countries
or club.id_number is not null
--- Manual Additions
or l.id_number is not null)


order by entity.last_name ASC
