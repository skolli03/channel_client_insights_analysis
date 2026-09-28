CREATE DATABASE channel_insights;
USE channel_insights;

CREATE TABLE raw_complaints (
	date_received TEXT,
    product TEXT,
    sub_product TEXT,
    issue TEXT,
    sub_issue TEXT,
    company_public_response TEXT,
    company TEXT,
    state TEXT,
    zip_code TEXT,
    tags TEXT,
    submitted_via TEXT,
    date_sent TEXT,
    company_response TEXT,
    timely_response TEXT,
    complaint_id TEXT
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/suraj/OneDrive/Desktop/SQL/Credit Card Sales Project/complaints_data.csv'
INTO TABLE raw_complaints
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Company dimension table
CREATE TABLE dim_company (
	company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL
);

INSERT INTO dim_company (company_name)
SELECT DISTINCT company
FROM raw_complaints;


-- Product dimension table
CREATE TABLE dim_product (
	product_id INT AUTO_INCREMENT PRIMARY KEY,
    product VARCHAR(255) NOT NULL,
    sub_product VARCHAR(255) NOT NULL
);

INSERT INTO dim_product (product, sub_product)
SELECT DISTINCT product, sub_product
FROM raw_complaints;


-- Issue dimension table
CREATE TABLE dim_issue (
	issue_id INT AUTO_INCREMENT PRIMARY KEY,
    issue VARCHAR(255) NOT NULL,
    sub_issue VARCHAR(255) NOT NULL
);

INSERT INTO dim_issue (issue, sub_issue)
SELECT DISTINCT issue, sub_issue
FROM raw_complaints;


-- Channel dimension table
CREATE TABLE dim_channel (
	channel_id INT AUTO_INCREMENT PRIMARY KEY,
    submitted_via VARCHAR(255) NOT NULL
);

INSERT INTO dim_channel (submitted_via)
SELECT DISTINCT submitted_via
FROM raw_complaints;

CREATE TABLE complaints_fact (
    complaint_id BIGINT PRIMARY KEY,
    date_received DATE,
    date_sent DATE,
    state VARCHAR(50),
    zip_code VARCHAR(20),
    tags VARCHAR(100),
    company_response VARCHAR(100),
    timely_response VARCHAR(10),
    company_id INT,
    product_id INT,
    issue_id INT,
    channel_id INT,
    FOREIGN KEY (company_id) REFERENCES dim_company(company_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (issue_id) REFERENCES dim_issue(issue_id),
    FOREIGN KEY (channel_id) REFERENCES dim_channel(channel_id)
);

INSERT INTO complaints_fact (
    complaint_id, date_received, date_sent, state, zip_code,
    tags, company_response, timely_response,
    company_id, product_id, issue_id, channel_id
)
SELECT
    r.complaint_id,
    STR_TO_DATE(LEFT(r.date_received, 10), '%Y-%m-%d'),
	STR_TO_DATE(LEFT(r.date_sent, 10), '%Y-%m-%d'),
    r.state,
    r.zip_code,
    r.tags,
    r.company_response,
    r.timely_response,
    c.company_id,
    p.product_id,
    i.issue_id,
    ch.channel_id
FROM raw_complaints r
LEFT JOIN dim_company c ON r.company = c.company_name
LEFT JOIN dim_product p ON r.product = p.product AND (r.sub_product = p.sub_product OR (r.sub_product IS NULL AND p.sub_product IS NULL))
LEFT JOIN dim_issue i ON r.issue = i.issue AND (r.sub_issue = i.sub_issue OR (r.sub_issue IS NULL AND i.sub_issue IS NULL))
LEFT JOIN dim_channel ch ON r.submitted_via = ch.submitted_via;
