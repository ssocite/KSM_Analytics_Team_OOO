with campus as (select distinct degrees.id_number, degrees.campus_code, TMS_CAMPUS.short_desc
from degrees
left join TMS_CAMPUS on TMS_CAMPUS.campus_code = degrees.campus_code
where degrees.division_code = 'EMP'
and degrees.school_code = 'KSM'
and degrees.non_grad_code = ' '
and degrees.campus_code IN ('MIA','EV'))


select deg.ID_NUMBER,
       deg.REPORT_NAME,
       deg.RECORD_STATUS_CODE,
       deg.PROGRAM,
       deg.PROGRAM_GROUP,
       campus.short_desc as campus,
       deg.DEGREES_VERBOSE,
       deg.FIRST_KSM_YEAR,
       deg.CLASS_SECTION
from rpt_pbh634.v_entity_ksm_degrees deg
inner join campus on campus.id_number = deg.id_number
where deg.PROGRAM_GROUP = 'EMP'
