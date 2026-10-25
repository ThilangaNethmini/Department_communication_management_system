-- =====================================================================
-- Department Communication Management System (DCMS) - Team Code & Query
-- MySQL 8.x script: schema (3NF/BCNF), sample data, queries, view,
-- trigger, stored procedure
-- =====================================================================

DROP DATABASE IF EXISTS dcms;
CREATE DATABASE dcms CHARACTER SET utf8mb4;
USE dcms;

-- ---------------------------------------------------------------------
-- 1. DDL
-- ---------------------------------------------------------------------

CREATE TABLE staff (
    staff_id       INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    email          VARCHAR(120) NOT NULL UNIQUE,
    role           VARCHAR(30)  NOT NULL,            -- e.g. HOD, LECTURER, ADMIN
    password_hash  VARCHAR(255) NOT NULL
);

CREATE TABLE availability_slot (
    slot_id      INT AUTO_INCREMENT PRIMARY KEY,
    staff_id     INT NOT NULL,                       -- OWNS
    day_of_week  ENUM('Monday','Tuesday','Wednesday','Thursday',
                      'Friday','Saturday','Sunday') NOT NULL,
    start_time   TIME NOT NULL,
    end_time     TIME NOT NULL,
    is_free      BOOLEAN NOT NULL DEFAULT TRUE,      -- FALSE = busy (lecture etc.)
    CONSTRAINT fk_slot_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
        ON DELETE CASCADE,
    CONSTRAINT ck_slot_time CHECK (start_time < end_time)
);

CREATE TABLE schedule_plan (
    schedule_id    INT AUTO_INCREMENT PRIMARY KEY,
    academic_year  VARCHAR(9) NOT NULL,              -- e.g. 2026/2027
    semester       TINYINT NOT NULL,
    created_by     INT NOT NULL,                     -- CREATES
    CONSTRAINT fk_plan_staff FOREIGN KEY (created_by) REFERENCES staff(staff_id),
    CONSTRAINT uq_plan UNIQUE (academic_year, semester),
    CONSTRAINT ck_semester CHECK (semester BETWEEN 1 AND 8)
);

CREATE TABLE meeting_type (
    type_code       VARCHAR(10) PRIMARY KEY,
    type_name       VARCHAR(80) NOT NULL,
    frequency_rule  VARCHAR(100) NOT NULL            -- e.g. 'MONTHLY', 'ONCE_PER_SEMESTER'
);

-- multivalued attribute BLOCKED_MONTHS resolved into its own table (1NF)
CREATE TABLE meeting_type_blocked_month (
    type_code      VARCHAR(10) NOT NULL,
    blocked_month  TINYINT NOT NULL,
    PRIMARY KEY (type_code, blocked_month),
    CONSTRAINT fk_bm_type FOREIGN KEY (type_code) REFERENCES meeting_type(type_code)
        ON DELETE CASCADE,
    CONSTRAINT ck_month CHECK (blocked_month BETWEEN 1 AND 12)
);

CREATE TABLE meeting (
    meeting_id    INT AUTO_INCREMENT PRIMARY KEY,
    meeting_name  VARCHAR(150) NOT NULL,
    meeting_date  DATETIME NOT NULL,
    venue         VARCHAR(100) NOT NULL,
    status        ENUM('PENDING_APPROVAL','APPROVED','REJECTED',
                       'SCHEDULED','COMPLETED','CANCELLED')
                  NOT NULL DEFAULT 'PENDING_APPROVAL',   -- Approval_leader_state
    schedule_id   INT NOT NULL,                      -- CONTAINS
    type_code     VARCHAR(10) NOT NULL,              -- CLASSIFIES
    created_by    INT NOT NULL,                      -- CREATES
    leader_id     INT NOT NULL,                      -- LEADS
    delegated_to  INT NULL,                          -- DELEGATED_TO
    CONSTRAINT fk_m_plan   FOREIGN KEY (schedule_id)  REFERENCES schedule_plan(schedule_id),
    CONSTRAINT fk_m_type   FOREIGN KEY (type_code)    REFERENCES meeting_type(type_code),
    CONSTRAINT fk_m_creator FOREIGN KEY (created_by)  REFERENCES staff(staff_id),
    CONSTRAINT fk_m_leader FOREIGN KEY (leader_id)    REFERENCES staff(staff_id),
    CONSTRAINT fk_m_deleg  FOREIGN KEY (delegated_to) REFERENCES staff(staff_id)
);
-- NOTE: ATTENDANCE_PERCENTAGE is derived, so it is NOT stored (3NF); see view v_meeting_attendance.

-- Weak entities: key = (meeting_id, running number)
CREATE TABLE agenda (
    meeting_id     INT NOT NULL,
    agenda_number  INT NOT NULL,
    file_path      VARCHAR(255) NOT NULL,
    upload_date    DATE NOT NULL,
    PRIMARY KEY (meeting_id, agenda_number),
    CONSTRAINT fk_ag_m FOREIGN KEY (meeting_id) REFERENCES meeting(meeting_id)
        ON DELETE CASCADE
);

CREATE TABLE decision (
    meeting_id       INT NOT NULL,
    decision_number  INT NOT NULL,
    decision_text    TEXT NOT NULL,
    recorded_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (meeting_id, decision_number),
    CONSTRAINT fk_dec_m FOREIGN KEY (meeting_id) REFERENCES meeting(meeting_id)
        ON DELETE CASCADE
);

CREATE TABLE meeting_recording (
    meeting_id        INT NOT NULL,
    recording_number  INT NOT NULL,
    media_file_path   VARCHAR(255) NOT NULL,
    upload_timestamp  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (meeting_id, recording_number),
    CONSTRAINT fk_rec_m FOREIGN KEY (meeting_id) REFERENCES meeting(meeting_id)
        ON DELETE CASCADE
);

-- ATTENDS (M:N STAFF-MEETING) resolved into ATTENDANCE_LOG
CREATE TABLE attendance_log (
    log_number         INT AUTO_INCREMENT PRIMARY KEY,
    meeting_id         INT NOT NULL,
    staff_id           INT NOT NULL,
    rsvp_status        ENUM('PENDING','ACCEPTED','DECLINED') NOT NULL DEFAULT 'PENDING',
    marked_at          DATETIME NULL,
    attendance_status  ENUM('PRESENT','ABSENT','LATE','EXCUSED') NULL,
    CONSTRAINT uq_att UNIQUE (meeting_id, staff_id),
    CONSTRAINT fk_att_m FOREIGN KEY (meeting_id) REFERENCES meeting(meeting_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_att_s FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE notification (
    notification_id      INT AUTO_INCREMENT PRIMARY KEY,
    meeting_id           INT NOT NULL,               -- GENERATES
    staff_id             INT NOT NULL,               -- RECEIVES
    delivery_status      ENUM('PENDING','SENT','FAILED','READ') NOT NULL DEFAULT 'PENDING',
    scheduled_send_date  DATETIME NOT NULL,
    CONSTRAINT fk_n_m FOREIGN KEY (meeting_id) REFERENCES meeting(meeting_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_n_s FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE INDEX idx_meeting_date   ON meeting(meeting_date);
CREATE INDEX idx_slot_staff_day ON availability_slot(staff_id, day_of_week);
CREATE INDEX idx_notif_status   ON notification(delivery_status, scheduled_send_date);

-- ---------------------------------------------------------------------
-- 2. Sample data
-- ---------------------------------------------------------------------

INSERT INTO staff (name, email, role, password_hash) VALUES
 ('Dr. Perera',   'perera@dept.lk',   'HOD',      SHA2('pw1',256)),
 ('Ms. Silva',    'silva@dept.lk',    'LECTURER', SHA2('pw2',256)),
 ('Mr. Fernando', 'fernando@dept.lk', 'LECTURER', SHA2('pw3',256)),
 ('Ms. Jayasena', 'jayasena@dept.lk', 'ADMIN',    SHA2('pw4',256));

INSERT INTO availability_slot (staff_id, day_of_week, start_time, end_time, is_free) VALUES
 (2,'Monday','08:00','10:00',FALSE),
 (2,'Monday','10:00','12:00',TRUE),
 (3,'Monday','09:00','11:00',FALSE),
 (3,'Monday','11:00','13:00',TRUE),
 (1,'Monday','08:00','17:00',TRUE);

INSERT INTO schedule_plan (academic_year, semester, created_by) VALUES ('2026/2027', 1, 4);

INSERT INTO meeting_type VALUES
 ('DEPT','Department Meeting','MONTHLY'),
 ('EXAM','Examination Board','ONCE_PER_SEMESTER');
INSERT INTO meeting_type_blocked_month VALUES ('DEPT',4),('DEPT',12),('EXAM',8);

INSERT INTO meeting (meeting_name, meeting_date, venue, status, schedule_id, type_code, created_by, leader_id, delegated_to) VALUES
 ('November Department Meeting','2026-11-02 10:30:00','Conference Room A','SCHEDULED',1,'DEPT',4,1,NULL),
 ('Semester 1 Exam Board','2026-11-16 14:00:00','Board Room','PENDING_APPROVAL',1,'EXAM',4,1,2),
 ('October Department Meeting','2026-10-05 10:30:00','Conference Room A','COMPLETED',1,'DEPT',4,1,NULL);

INSERT INTO agenda VALUES (1,1,'/files/agenda/nov_dept.pdf','2026-10-25'),
                          (3,1,'/files/agenda/oct_dept.pdf','2026-10-01');
INSERT INTO decision (meeting_id, decision_number, decision_text) VALUES
 (3,1,'Approve the lab upgrade proposal.'),
 (3,2,'Hold the next meeting on the first Monday of November.');
INSERT INTO meeting_recording (meeting_id, recording_number, media_file_path) VALUES
 (3,1,'/files/rec/oct_dept.mp4');

INSERT INTO attendance_log (meeting_id, staff_id, rsvp_status, marked_at, attendance_status) VALUES
 (3,1,'ACCEPTED','2026-10-05 10:35:00','PRESENT'),
 (3,2,'ACCEPTED','2026-10-05 10:40:00','LATE'),
 (3,3,'DECLINED','2026-10-05 10:30:00','ABSENT'),
 (3,4,'ACCEPTED','2026-10-05 10:31:00','PRESENT'),
 (1,1,'ACCEPTED',NULL,NULL),
 (1,2,'PENDING',NULL,NULL),
 (1,3,'PENDING',NULL,NULL);

INSERT INTO notification (meeting_id, staff_id, delivery_status, scheduled_send_date) VALUES
 (1,1,'SENT','2026-10-26 08:00:00'),
 (1,2,'PENDING','2026-10-29 08:00:00'),
 (1,3,'PENDING','2026-10-29 08:00:00'),
 (2,2,'FAILED','2026-11-09 08:00:00');

-- ---------------------------------------------------------------------
-- 3. View, trigger, stored procedure
-- ---------------------------------------------------------------------

-- Derived attribute ATTENDANCE_PERCENTAGE
CREATE VIEW v_meeting_attendance AS
SELECT m.meeting_id,
       m.meeting_name,
       COUNT(a.log_number) AS invited,
       SUM(a.attendance_status IN ('PRESENT','LATE')) AS attended,
       ROUND(100 * SUM(a.attendance_status IN ('PRESENT','LATE'))
                 / NULLIF(COUNT(a.log_number),0), 2) AS attendance_percentage
FROM meeting m
LEFT JOIN attendance_log a ON a.meeting_id = m.meeting_id
GROUP BY m.meeting_id, m.meeting_name;

DELIMITER $$

-- Block meetings in a type's blocked months (uses MEETING_TYPE.BLOCKED_MONTHS rule)
CREATE TRIGGER trg_meeting_blocked_month
BEFORE INSERT ON meeting
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM meeting_type_blocked_month b
               WHERE b.type_code = NEW.type_code
                 AND b.blocked_month = MONTH(NEW.meeting_date)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This meeting type cannot be scheduled in the selected month.';
    END IF;
END$$

-- Create a notification for every invited attendee N days before the meeting
CREATE PROCEDURE sp_generate_notifications(IN p_meeting_id INT, IN p_days_before INT)
BEGIN
    INSERT INTO notification (meeting_id, staff_id, delivery_status, scheduled_send_date)
    SELECT m.meeting_id, a.staff_id, 'PENDING',
           DATE_SUB(m.meeting_date, INTERVAL p_days_before DAY)
    FROM meeting m
    JOIN attendance_log a ON a.meeting_id = m.meeting_id
    WHERE m.meeting_id = p_meeting_id;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- 4. Queries
-- ---------------------------------------------------------------------

-- Q1. Upcoming meetings with type, leader and delegate
SELECT m.meeting_id, m.meeting_name, m.meeting_date, m.venue, m.status,
       t.type_name, l.name AS leader, d.name AS delegated_to
FROM meeting m
JOIN meeting_type t ON t.type_code = m.type_code
JOIN staff l        ON l.staff_id  = m.leader_id
LEFT JOIN staff d   ON d.staff_id  = m.delegated_to
WHERE m.meeting_date >= NOW()
ORDER BY m.meeting_date;

-- Q2. Staff free for a proposed meeting (no busy slot overlapping Monday 10:30-11:30)
SET @day = 'Monday', @from = '10:30:00', @to = '11:30:00';
SELECT s.staff_id, s.name
FROM staff s
WHERE NOT EXISTS (
    SELECT 1 FROM availability_slot a
    WHERE a.staff_id = s.staff_id
      AND a.day_of_week = @day
      AND a.is_free = FALSE
      AND a.start_time < @to AND a.end_time > @from
);

-- Q3. Attendance percentage per meeting (from the view)
SELECT * FROM v_meeting_attendance ORDER BY meeting_id;

-- Q4. Attendance summary per staff member
SELECT s.name,
       SUM(a.attendance_status = 'PRESENT') AS present,
       SUM(a.attendance_status = 'LATE')    AS late,
       SUM(a.attendance_status = 'ABSENT')  AS absent
FROM staff s
LEFT JOIN attendance_log a ON a.staff_id = s.staff_id
GROUP BY s.staff_id, s.name
ORDER BY absent DESC;

-- Q5. Staff who have not responded to the RSVP for a meeting
SELECT s.name, s.email
FROM attendance_log a
JOIN staff s ON s.staff_id = a.staff_id
WHERE a.meeting_id = 1 AND a.rsvp_status = 'PENDING';

-- Q6. Decisions, agenda files and recordings of a meeting
SELECT 'DECISION' AS item, decision_number AS no, decision_text AS detail FROM decision WHERE meeting_id = 3
UNION ALL
SELECT 'AGENDA', agenda_number, file_path FROM agenda WHERE meeting_id = 3
UNION ALL
SELECT 'RECORDING', recording_number, media_file_path FROM meeting_recording WHERE meeting_id = 3;

-- Q7. Notifications due to be sent now
SELECT n.notification_id, s.email, m.meeting_name, n.scheduled_send_date
FROM notification n
JOIN staff s   ON s.staff_id   = n.staff_id
JOIN meeting m ON m.meeting_id = n.meeting_id
WHERE n.delivery_status = 'PENDING' AND n.scheduled_send_date <= NOW();

-- Q8. Failed notifications for retry
SELECT n.notification_id, s.name, m.meeting_name
FROM notification n
JOIN staff s   ON s.staff_id   = n.staff_id
JOIN meeting m ON m.meeting_id = n.meeting_id
WHERE n.delivery_status = 'FAILED';

-- Q9. Number of meetings per type and semester plan
SELECT p.academic_year, p.semester, t.type_name, COUNT(*) AS meetings
FROM meeting m
JOIN schedule_plan p ON p.schedule_id = m.schedule_id
JOIN meeting_type  t ON t.type_code   = m.type_code
GROUP BY p.academic_year, p.semester, t.type_name;

-- Q10. Blocked months for each meeting type
SELECT t.type_name, GROUP_CONCAT(b.blocked_month ORDER BY b.blocked_month) AS blocked_months
FROM meeting_type t
LEFT JOIN meeting_type_blocked_month b ON b.type_code = t.type_code
GROUP BY t.type_code, t.type_name;

-- Q11. Meetings led or delegated to a given staff member
SELECT meeting_name, meeting_date,
       CASE WHEN leader_id = 2 THEN 'LEADER' ELSE 'DELEGATE' END AS my_role
FROM meeting
WHERE leader_id = 2 OR delegated_to = 2;

-- Q12. Meetings with no agenda uploaded yet
SELECT m.meeting_id, m.meeting_name
FROM meeting m
LEFT JOIN agenda a ON a.meeting_id = m.meeting_id
WHERE a.meeting_id IS NULL;

-- Q13. Approve a meeting and generate notifications 3 days before it
UPDATE meeting SET status = 'SCHEDULED' WHERE meeting_id = 2;
CALL sp_generate_notifications(2, 3);

-- Q14. Trigger test (December is blocked for DEPT) - this should raise an error
-- INSERT INTO meeting (meeting_name, meeting_date, venue, schedule_id, type_code, created_by, leader_id)
-- VALUES ('December Meeting','2026-12-07 10:00:00','Room A',1,'DEPT',4,1);
