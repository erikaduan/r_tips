-----------------------------------------------------------------
-- CREATE education SCHEMA and TABLES ---------------------------
-----------------------------------------------------------------
DROP SCHEMA IF EXISTS education;
CREATE SCHEMA education;

CREATE TABLE `sandpit-338210.education.student` (
    student_id INT NOT NULL,
    first_name STRING NOT NULL,
    last_name STRING NOT NULL,
    dob DATE NOT NULL
);

CREATE TABLE `sandpit-338210.education.platform` (
    platform_id INT NOT NULL,
    platform_name STRING NOT NULL,
    company_name STRING NOT NULL,
    is_active BOOL
);

CREATE TABLE `sandpit-338210.education.course` (
    course_id STRING NOT NULL,
    course_name STRING,
    course_length INT,
    course_desc STRING,
    platform_id INT NOT NULL
);

CREATE TABLE `sandpit-338210.education.enrolment` (
    enrolment_id INT NOT NULL,
    student_id INT NOT NULL,
    course_id STRING NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE
);

-----------------------------------------------------------------
-- INSERT INTO table records ------------------------------------
-----------------------------------------------------------------
INSERT INTO `sandpit-338210.education.student` VALUES
(1, 'Frodo', 'Baggins', '1987-11-29'),
(2, 'Samwise', 'Gamgee', '1986-02-18'),
(3, 'Merry', 'Brandybuck', '1987-05-03'),
(4, 'Peregrin', 'Took', '1990-03-21');

INSERT INTO `sandpit-338210.education.platform` VALUES
(1, 'Happy Gardeners', 'Shire School', TRUE),
(2, 'Jolly Bakers', 'Shire School', TRUE),
(3, 'Burglar Training', 'Gandalf Guide', FALSE),
(4, 'Seeing Wise', 'Palantir Inc', NULL);

INSERT INTO `sandpit-338210.education.course` VALUES
('SG01', 'Growing vegetable pie ingredients', 90, 'All good hobbits should know that vegetable pies cannot be vegetarian', 1),
('SG02', 'Growing flowers', 35, 'Hobbits should not just grow plants for eating!', 1),
('SB01', 'Breakfast pies', 1, 'Savoury pies and sweet pies for breakfast and second breakfast', 2),
('SB02', 'Emergency dwarven bread', 10, 'Bake these goods to politely send unexpected guests off on their way again', 2),
('GG01', 'Pity pathetic creatures', 1, 'Many that live deserve death. Some that die deserve life. Can you give it to them, hobbits?', 3),
('MORDOR666', 'See shiny orbs', NULL, '5/5 experience! Just ask the wisest wizard Saruman', 4);

INSERT INTO `sandpit-338210.education.enrolment` VALUES
(1, 2, 'SG01', '1999-03-01', '1998-07-30'),
(2, 2, 'SG02', '2000-02-01', '2000-04-10'),
(3, 2, 'SB01', '1999-08-01', '1999-08-02'),
(4, 2, 'SG01', '2001-03-01', '2001-07-30'),
(5, 2, 'SG01', '2005-03-01', '2005-07-30'),
(6, 2, 'SG01', '2010-03-01', '2010-07-30'),
(7, 1, 'SG02', '2000-02-01', '2000-04-10'),
(8, 1, 'GG01', '2021-09-02', '2021-09-03'),
(9, 3, 'SB01', '2008-08-01', '2008-08-02'),
(10, 4, 'SG01', '2008-03-01', '2008-03-03'),
(11, 4, 'MORDOR666', '2022-07-13', NULL);