SELECT 
  s.student_id, 
  CONCAT(s.first_name, ' ', s.last_name) AS student_name,
  c.course_id,
  c.course_name,
  ROW_NUMBER() OVER (PARTITION BY s.student_id ORDER BY e.start_date) 
    AS course_sequence,
  e.start_date,
  e.end_date
  
  FROM education.enrolment AS e
  INNER JOIN education.student AS s
  ON e.student_id = s.student_id
  
  INNER JOIN education.course as c
  on e.course_id = c.course_id
  
  WHERE start_date <= {before_date}
  
  ORDER BY student_id, start_date