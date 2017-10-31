CREATE PROCEDURE legal_entity_fiscal_period_rebuild
  @start_year int = 2010
, @end_year int = 2020
AS
BEGIN

  SET NOCOUNT ON

  declare
    @source_key int
  , @current_dt date
  , @last_dt date
  , @date_uid char(8)
  , @first_of_month_weekday int
  , @current_weekday int
  , @week_of_month int
 
  declare 
	@unknown_key int = 0
  , @unknown_text varchar(20) = 'Unknown'
  , @extreme_key int = 99999999
  , @extreme_text varchar(20) = 'Indefinite'
  , @process_batch_key int = 0;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- completely clear out the calendar table
  
  TRUNCATE TABLE legal_entity_fiscal_period;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- insert zero key

	INSERT INTO legal_entity_fiscal_period (
	  [legal_entity_key]
    , [fiscal_period_of_year]
	, [fiscal_year]
	, [display_month_of_year]
	, [start_date]
	, [end_date]
	) VALUES (
	  @unknown_key -- legal_entity_key
	, @unknown_key -- fiscal_period_of_year
	, @unknown_key -- fiscal_year
	, @unknown_key -- display_month_of_year	
	, @unknown_key -- start_date	
	, @unknown_key -- end_date
	)

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- determine the start date, end date and source key
  -- NOTE: expanding range by one year from start and end...should be cleaned up at end

  set @current_dt = CONVERT(date,CAST(@start_year-1 as CHAR(4)) + '-01-01')
  set @last_dt = CONVERT(date,CAST(@end_year+1 as CHAR(4)) + '-12-31')
  
  select @source_key = 1 -- x.source_key from source x where x.source_uid = 'STD'
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- insert the extreme date record

  INSERT INTO legal_entity_fiscal_period (
	  [legal_entity_key]
    , [fiscal_period_of_year]
	, [fiscal_year]
	, [display_month_of_year]
	, [start_date]
	, [end_date]
	) VALUES (
	  @extreme_key -- legal_entity_key
	, @extreme_key -- fiscal_period_of_year
	, @extreme_key -- fiscal_year
	, @extreme_key -- display_month_of_year
	, @extreme_key -- start_date
	, @extreme_key -- end_date
	)
       
END
