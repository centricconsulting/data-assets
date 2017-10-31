CREATE PROCEDURE legal_entity_holiday_rebuild
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
  
  TRUNCATE TABLE legal_entity_holiday;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- insert zero key

	INSERT INTO legal_entity_holiday (
	  [legal_entity_key]
    , [holiday_date]
	, [holiday_desc]
	) VALUES (
	  @unknown_key -- legal_entity_key
	, @unknown_key -- holiday_date
	, @unknown_text -- holiday_desc
	)

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- determine the start date, end date and source key
  -- NOTE: expanding range by one year from start and end...should be cleaned up at end

  set @current_dt = CONVERT(date,CAST(@start_year-1 as CHAR(4)) + '-01-01')
  set @last_dt = CONVERT(date,CAST(@end_year+1 as CHAR(4)) + '-12-31')
  
  select @source_key = 1 -- x.source_key from source x where x.source_uid = 'STD'

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- insert the extreme date record

  INSERT INTO legal_entity_holiday (
	 [legal_entity_key]
    , [holiday_date]
	, [holiday_desc]
	) VALUES (
	  @extreme_key -- legal_entity_key
	, @extreme_key -- holiday_date
	, @extreme_text -- holiday_desc
	)
       
END
