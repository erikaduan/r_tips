-----------------------------------------------------------------
-- CREATE education DATABASE ------------------------------------
-----------------------------------------------------------------
USE master

DROP DATABASE IF EXISTS sandpit
CREATE DATABASE sandpit
USE sandpit

-----------------------------------------------------------------
-- CREATE student SCHEMA and TABLES -----------------------------
-----------------------------------------------------------------
CREATE TABLE education_student (
    student_id INT NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    dob DATE NOT NULL,

    PRIMARY KEY (student_id)
)

CREATE TABLE education_platform (
    platform_id INT NOT NULL,
    platform_name VARCHAR(20) NOT NULL,
    company_name VARCHAR(20) NOT NULL,
    is_active BIT,

    PRIMARY KEY (platform_id)
)

CREATE TABLE education_course (
    course_id VARCHAR(10) NOT NULL,
    course_name VARCHAR(100), 
    course_length INT, 
    course_desc VARCHAR(100),
    platform_id INT NOT NULL, 

    FOREIGN KEY(platform_id) REFERENCES education_platform (platform_id),
    PRIMARY KEY (course_id)
)

CREATE TABLE education_enrolment (
    enrolment_id INT NOT NULL,
    student_id INT NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    start_date DATE NOT NULL, 
    end_date DATE,

    FOREIGN KEY(student_id) REFERENCES education_student (student_id),
    FOREIGN KEY(course_id) REFERENCES education_course (course_id),
    PRIMARY KEY (enrolment_id)
)

-----------------------------------------------------------------
-- INSERT INTO table records ------------------------------------
-----------------------------------------------------------------
INSERT INTO education_student VALUES
(1, 'Frodo', 'Baggins', '19871129'),
(2, 'Samwise', 'Gamgee', '19860218'),
(3, 'Merry', 'Brandybuck', '19870503'),
(4, 'Peregrin', 'Took', '19900321')

INSERT INTO education_platform VALUES
(1, 'Happy Gardeners', 'Shire School', 1),
(2, 'Jolly Bakers', 'Shire School', 1),
(3, 'Burglar Training', 'Gandalf Guide', 0),
(4, 'Seeing Wise', 'Palantir Inc', NULL)

INSERT INTO education_course VALUES
('SG01', 'Growing vegetable pie ingredients', 90, 'All good hobbits should know that vegetable pies cannot be vegetarian', 1),
('SG02', 'Growing flowers', 35, 'Hobbits should not just grow plants for eating!', 1),
('SB01', 'Breakfast pies', 1, 'Savoury pies and sweet pies for breakfast and second breakfast', 2),
('SB02', 'Emergency dwarven bread', 10, 'Bake these goods to politely send unexpected guests off on their way again', 2),
('GG01', 'Pity pathetic creatures', 1, 'Many that live deserve death. Some that die deserve life. Can you give it to them, hobbits?', 3),
('MORDOR666', 'See shiny orbs', NULL, '5/5 experience! Just ask the wisest wizard Saruman', 4)

INSERT INTO education_enrolment VALUES
(1, 2, 'SG01', '19990301', '19980730'),
(2, 2, 'SG02', '20000201', '20000410'),
(3, 2, 'SB01', '19990801', '19990802'),
(4, 2, 'SG01', '20010301', '20010730'),
(5, 2, 'SG01', '20050301', '20050730'),
(6, 2, 'SG01', '20100301', '20100730'),
(7, 1, 'SG02', '20000201', '20000410'),
(8, 1, 'GG01', '20210902', '20210903'),
(9, 3, 'SB01', '20080801', '20080802'),
(10, 4, 'SG01', '20080301', '20080303'),
(11, 4, 'MORDOR666', '20220713', NULL)