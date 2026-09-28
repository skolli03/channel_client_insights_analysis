-- Most used channels per bank
SELECT
	c.company_name,
	ch.submitted_via AS channel,
    COUNT(*) AS complaint_count
FROM complaints_fact f
JOIN dim_company c
	ON f.company_id = c.company_id
JOIN dim_channel ch
	ON f.channel_id = ch.channel_id
GROUP BY c.company_id, ch.submitted_via;


-- Top issues per bank
SELECT 
	c.company_name,
    i.issue,
    COUNT(*) AS issue_count
FROM complaints_fact f
JOIN dim_issue i
	ON f.issue_id = i.issue_id
JOIN dim_company c
	ON f.company_id = c.company_id
GROUP BY c.company_id, i.issue;


-- Timeliness by channel
SELECT
    ch.submitted_via,
    COUNT(*) AS total_complaints,
    SUM(CASE 
		WHEN f.timely_response = 'Yes' THEN 1 
        ELSE 0 END) AS timely_count,
    ROUND(SUM(CASE WHEN f.timely_response = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS timely_pct
FROM complaints_fact f
JOIN dim_channel ch ON f.channel_id = ch.channel_id
GROUP BY ch.submitted_via
ORDER BY timely_pct DESC;


-- Monthly Complaints per bank
SELECT
	DATE_FORMAT(date_received, '%Y-%M') AS date_received,
    c.company_name,
    COUNT(*) AS complaints_count
FROM complaints_fact f
JOIN dim_company c
	ON f.company_id = c.company_id
GROUP BY DATE_FORMAT(date_received, '%Y-%M'), c.company_name
ORDER BY date_received;


-- Company response outcomes per bank
SELECT 
	c.company_name,
    f.company_response,
    COUNT(*) AS response_count
FROM complaints_fact f
JOIN dim_company c
	ON f.company_id = c.company_id
GROUP BY c.company_name, f.company_response;


-- Top 3 issues per bank
SELECT *
FROM (	
    SELECT 
		RANK () OVER(PARTITION BY c.company_name ORDER BY COUNT(*) DESC) AS issue_rank,
		c.company_name, 
		i.issue, 
		COUNT(*) AS complaint_count
	FROM complaints_fact f
	JOIN dim_company c
		ON f.company_id = c.company_id
	JOIN dim_issue i
		ON f.issue_id = i.issue_id
	GROUP BY c.company_name, i.issue
) ranked
WHERE issue_rank <= 3;


-- State complaint distribution
SELECT 
	c.company_name,
    f.state,
    COUNT(*) AS complaint_count
FROM complaints_fact f
JOIN dim_company c
	ON f.company_id = c.company_id
GROUP BY c.company_name, f.state;
    