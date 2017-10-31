/* ############################################################ */

CREATE SCHEMA report
GO

create function [report].[build_varchar_list] (
  @parameter_list varchar(2000)
)
RETURNS @ret TABLE (value varchar(200))
AS
BEGIN

  WITH cte as (
    select 0 a, 1 b
    union all select b, charindex(',', @parameter_list, b) + len(',')
    from cte where b > a
  )
  INSERT INTO @ret (value)
  SELECT
  CONVERT(varchar(200),substring(@parameter_list,a, case 
    when b > len(',') then b-a-len(',')
    else len(@parameter_list) - a + 1 end)) value
  from cte where a >0;

RETURN 

END
GO

/* ############################################################ */

create function [report].[build_integer_list] (
  @parameter_list varchar(2000)
)
RETURNS @ret TABLE (value int)
AS
BEGIN

  WITH cte as (
    select 0 a, 1 b
    union all select b, charindex(',', @parameter_list, b) + len(',')
    from cte where b > a
  )
  INSERT INTO @ret (value)
  SELECT
  CONVERT(int,substring(@parameter_list,a, case 
    when b > len(',') then b-a-len(',')
    else len(@parameter_list) - a + 1 end)) value
  from cte where a >0;

RETURN

END
GO

/* ############################################################ */
-- example
-- note: @XXXX_list variables are multi-select lists from SSRS

create procedure [report].[R0005_wc_cause_of_injury]
  @year int
, @company_key_list varchar(2000) = NULL
, @wc_claim_type_list varchar(2000) = NULL
, @wc_claim_element_type_list varchar(2000) = NULL
, @rate_state_key_list varchar(2000) = NULL
, @current_claim_status_type_list varchar(2000) = NULL
AS

declare @min_year int = @year - 4

SELECT
  dat.claim_key
, yr.year
, yr.payment_category_desc
, dat.injured_body_part_key
, dat.sic_key
, ISNULL(sic.sic_level_01_desc,'Unknown') as sic_division
, ISNULL(ibp.area_of_body_desc,'Unknown') as area_of_body_desc
, ISNULL(ibp.injured_body_part_desc,'Unknown') as injured_body_part_desc
, ISNULL(coi.cause_of_injury_desc,'Unknown') as cause_of_injury_desc
, ISNULL(coi.cause_of_injury_category_desc,'Unknown') as cause_of_injury_category_desc
, ISNULL(dat.payment_amount,0) AS payment_amount
FROM
(

  SELECT
    cx.year
  , pt.payment_category_desc
  FROM
  calendar cx
  CROSS JOIN (
    SELECT CAST('Loss' AS varchar(20)) AS payment_category_desc
    UNION ALL SELECT CAST('Expense' AS varchar(20))
  ) pt
  WHERE
  cx.day_of_year = 1
  AND cx.year BETWEEN @min_year and @year

) yr
LEFT JOIN (

  SELECT
    c.year
  , cm.claim_key
  , pst.payment_category_desc
  , pch.current_sic_key as sic_key
  , cm.cause_of_injury_key
  , cm.injured_body_part_key
  , SUM(p.payment_amount) AS payment_amount
  FROM
  dbo.payment p
  inner join dbo.payment_subtype pst on
    pst.payment_subtype_key = p.payment_subtype_key
  inner join dbo.check_payment_status cps on
    cps.check_payment_status_key = p.check_payment_status_key    
  inner join claim_element ce on
    ce.claim_element_key = p.claim_element_key
  inner join claim cm on
    cm.claim_key = ce.claim_key
  inner join claim_element_loss_type lt on
    lt.claim_element_loss_type_key = ce.claim_element_loss_type_key    
  inner join policy po on
    po.policy_key = p.policy_key
  inner join policyholder pch on
    pch.policyholder_key = po.policyholder_key
  inner join claim_status cst on
    cst.claim_status_key = cm.current_claim_status_key    
  inner join dbo.calendar c ON
    c.date_key = p.payment_date_key
  WHERE
  c.year BETWEEN @min_year and @year
  -- exclude voided checks
  AND cps.check_void_ind = 0
  -- only include wc applicable claims and elements
  AND cm.claim_class = 'Workers Compensation'
  AND lt.wc_applicable_ind = 1
  -- apply filters
  AND (@rate_state_key_list IS NULL
    OR po.current_primary_rate_state_key IN (
    SELECT value FROM report.build_integer_list(@rate_state_key_list)))
  AND (@company_key_list IS NULL
    OR po.company_key IN (
    SELECT value from report.build_integer_list(@company_key_list)))
  AND (@wc_claim_type_list IS NULL
    OR cm.wc_claim_type IN (
    SELECT value from report.build_varchar_list(@wc_claim_type_list)))
  AND (@wc_claim_element_type_list IS NULL
    OR ce.wc_claim_element_type IN (
    SELECT value from report.build_varchar_list(@wc_claim_element_type_list))) 
  AND (@current_claim_status_type_list IS NULL
    OR cst.claim_status_type_cd IN (
    SELECT value from report.build_varchar_list(@current_claim_status_type_list)))
  GROUP BY
    c.year
  , cm.claim_key
  , pst.payment_category_desc
  , pch.current_sic_key
  , cm.cause_of_injury_key
  , cm.injured_body_part_key
  
) dat ON
  dat.year = yr.year 
  AND dat.payment_category_desc = yr.payment_category_desc
  
left join sic sic on
  sic.sic_key = dat.sic_key    
left join cause_of_injury coi on
  coi.cause_of_injury_key = dat.cause_of_injury_key
left join injured_body_part ibp on
  ibp.injured_body_part_key = dat.injured_body_part_key
;
GO