SELECT 
    a.student_track_id,
    a.student_id,
    a.track_name,
    a.track_completed,
    a.days_for_completion,
    CASE
        WHEN a.days_for_completion = 0 THEN 'Same day'
        WHEN a.days_for_completion BETWEEN 1 AND 7 THEN '1 to 7 days'
        WHEN a.days_for_completion BETWEEN 8 AND 30 THEN '8 to 30 days'
        WHEN a.days_for_completion BETWEEN 31 AND 60 THEN '31 to 60 days'
        WHEN a.days_for_completion BETWEEN 61 AND 90 THEN '61 to 90 days'
        WHEN a.days_for_completion BETWEEN 91 AND 365 THEN '91 to 365 days'
        WHEN a.days_for_completion > 365 THEN '366+ days'
        ELSE NULL -- Handles cases where days_for_completion is NULL
    END AS completion_bucket
FROM 
    (
        SELECT
            ROW_NUMBER() OVER () AS student_track_id, -- Assign unique ID to each row
            e.student_id,
            i.track_name,
            IF(e.date_completed IS NULL, 0, 1) AS track_completed, -- 0 if not completed, 1 if completed
            DATEDIFF(e.date_completed, e.date_enrolled) AS days_for_completion -- Days between enrollment and completion
        FROM
            career_track_student_enrollments e
        JOIN
            career_track_info i
        ON
            e.track_id = i.track_id
    ) AS a; -- Subquery alias


SELECT 
    MAX(days_for_completion) AS max_days_for_completion
FROM 
    (
        SELECT
            ROW_NUMBER() OVER () AS student_track_id,
            e.student_id,
            i.track_name,
            IF(e.date_completed IS NULL, 0, 1) AS track_completed,
            DATEDIFF(e.date_completed, e.date_enrolled) AS days_for_completion
        FROM
            career_track_student_enrollments e
        JOIN
            career_track_info i
        ON
            e.track_id = i.track_id
    ) AS a
WHERE
    days_for_completion IS NOT NULL;
    
    -- --------------
    SELECT 
    a.student_id,
    a.track_name,
    a.days_for_completion
FROM 
    (
        SELECT
            ROW_NUMBER() OVER () AS student_track_id,
            e.student_id,
            i.track_name,
            IF(e.date_completed IS NULL, 0, 1) AS track_completed,
            DATEDIFF(e.date_completed, e.date_enrolled) AS days_for_completion
        FROM
            career_track_student_enrollments e
        JOIN
            career_track_info i
        ON
            e.track_id = i.track_id
    ) AS a
WHERE 
    a.days_for_completion = (
        SELECT 
            MAX(days_for_completion)
        FROM 
            (
                SELECT
                    DATEDIFF(e.date_completed, e.date_enrolled) AS days_for_completion
                FROM
                    career_track_student_enrollments e
                WHERE 
                    e.date_completed IS NOT NULL
            ) AS max_days
    );
    
-- ----------------

SELECT 
    COUNT(*) AS total_completions
FROM 
    career_track_student_enrollments
WHERE 
    date_completed IS NOT NULL;


