--- See 2024 Dean Personalized Lunar New Year in XComment 

SELECT rpt_pbh634.v_entity_ksm_households.ID_NUMBER,
       rpt_pbh634.v_entity_ksm_households.REPORT_NAME,
       rpt_pbh634.v_entity_ksm_households.PROGRAM,
       m_l.mail_list_type_code,
       m_l.mail_list_status_code,
       m_l.mail_list_code,
       m_l.mail_list_code,
       m_l.mail_list_ctrl_code,
       m_l.start_dt,
       m_l.xcomment
  FROM  mailing_list m_l
  Inner JOIN rpt_pbh634.v_entity_ksm_households on 
 rpt_pbh634.v_entity_ksm_households.ID_NUMBER = m_l.id_number
 WHERE  m_l.mail_list_code = 'KDLNY'
