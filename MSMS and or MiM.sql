--- special handling

with s AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT
       From rpt_pbh634.v_entity_special_handling spec),

--- Email - preferred

em AS (select email.id_number,
       email.email_address
From email
Where email.preferred_ind = 'Y'),

d as (select *
from rpt_pbh634.v_entity_ksm_degrees d
Where d.degrees_concat Like '%MSMS%')

select e.id_number,
e.first_name,
e.last_name,
e.INSTITUTIONAL_SUFFIX,
d.degrees_verbose,
d.degrees_concat,
d.first_ksm_year,
d.program,
em.email_address,
s.NO_EMAIL_IND,
s.NO_CONTACT
from entity e
inner join d on d.id_number = e.id_number
left join s on s.id_number = e.id_number
left join em on em.id_number = e.id_number
where e.record_status_code IN ('A','L')
order by d.first_ksm_year asc
