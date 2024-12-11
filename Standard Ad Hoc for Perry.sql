with h as (select *
from rpt_pbh634.v_entity_ksm_households
where rpt_pbh634.v_entity_ksm_households.PROGRAM is not null
and rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_GEO_CODES IN ('Houston TX')),

TP AS (SELECT TP.ID_NUMBER,
       TP.EVALUATION_RATING,
       TP.OFFICER_RATING
From nu_prs_trp_prospect TP),


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

KSM_Give AS (Select give.ID_NUMBER,
give.NGC_LIFETIME,
give.NU_MAX_HH_LIFETIME_GIVING,
give.LAST_GIFT_DATE,
give.LAST_GIFT_ALLOC,
give.LAST_GIFT_RECOGNITION_CREDIT
from rpt_pbh634.v_ksm_giving_summary give),

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

c as (/* Last Contact Report - Date, Author, Type, Subject
(# Contact Reports - Contacts within FY and 5FYs
*/
select cr.id_number,
max (cr.credited) keep (dense_rank First Order By cr.contact_date DESC) as credited,
max (cr.credited_name) keep (dense_rank First Order By cr.contact_date DESC) as credited_name,
max (cr.contacted_name) keep (dense_rank First Order By cr.contact_date DESC) as contacted_name,
max (cr.contact_type) keep (dense_rank First Order By cr.contact_date DESC) as contact_type,
max (cr.contact_date) keep (dense_rank First Order By cr.contact_date DESC) as contact_Date,
max (cr.contact_purpose) keep (dense_rank First Order By cr.contact_date DESC) as contact_purpose,
max (cr.description) keep (dense_rank First Order By cr.contact_date DESC) as description_,
max (cr.summary) keep (dense_rank First Order By cr.contact_date DESC) as summary_
from rpt_pbh634.v_contact_reports_fast cr
group by cr.id_number
),

armod as (Select en.ID_NUMBER,
en.AE_MODEL_SCORE
From rpt_pbh634.v_ksm_model_alumni_engagement en)

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
KSP.NO_CONTACT,
KSP.NO_EMAIL_IND,
TP.EVALUATION_RATING,
TP.OFFICER_RATING,
a.prospect_manager,
a.lgos,
KG.NGC_LIFETIME,
KG.NU_MAX_HH_LIFETIME_GIVING,
KG.LAST_GIFT_ALLOC,
KG.LAST_GIFT_RECOGNITION_CREDIT,
C.credited,
C.contact_purpose,
C.credited_name,
C.contacted_name,
C.contact_type,
trunc (C.contact_Date) as contact_date,
C.description_,
C.summary_,
armod.AE_MODEL_SCORE

FROM ENTITY e
inner join h on h.id_number = e.id_number
left join employ on employ.id_number = e.id_number
left join KSM_Give KG on KG.id_number = e.id_number
left join KSM_Spec KSP on KSP.id_number = e.id_number
left join assignment a on a.id_number = e.id_number
left join TP on TP.id_number = e.id_number
left join c on c.id_number = e.id_number
left join armod on armod.id_number = e.id_number
where KSP.NO_CONTACT is null
order by e.last_name asc
