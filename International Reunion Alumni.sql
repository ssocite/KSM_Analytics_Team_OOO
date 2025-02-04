With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Where email.preferred_ind = 'Y'),

g AS (Select give.ID_NUMBER,
give.NGC_LIFETIME,
give.NU_MAX_HH_LIFETIME_GIVING,
give.LAST_GIFT_DATE,
give.LAST_GIFT_ALLOC,
give.LAST_GIFT_RECOGNITION_CREDIT,
give.AF_CFY, give.AF_PFY1
from rpt_pbh634.v_ksm_giving_summary give)

select r.ID_NUMBER,
entity.first_name,
entity.last_name,
r.DEGREE_PROGRAM,
r.PROGRAM_GROUP,
r.CLASS_YEAR,
r.Country,
g.AF_CFY,
case when g.AF_CFY > 0 then 'Y' else '' end as AF_giver_25_ind,
g.AF_PFY1,
case when g.AF_PFY1 > 0 then 'AF Giver FY 24' else '' end as AF_giver_24_ind,
k.email_address as pref_email_address,
r.NO_EMAIL,
r.NO_CONTACT
from V_KSM_25_REUNION r
inner join entity on entity.id_number = r.ID_NUMBER
inner join KSM_Email k on k.id_number = r.ID_NUMBER
left join g on g.id_number = r.id_number
where (r.NO_CONTACT is null)
and r.RECORD_STATUS_CODE IN ('A','L')
and r.country != 'United States'
Order By r.CLASS_YEAR ASC
