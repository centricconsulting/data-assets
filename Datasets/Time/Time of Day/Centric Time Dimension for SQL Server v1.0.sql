USE sample_warehouse
GO

/*

-- key generation examples

declare @current_dtm datetime
set @current_dtm = GETDATE()

SELECT
  CONVERT(int,CONVERT(char(8),@current_dtm,112)) as date_key
, CONVERT(char(8),DATEADD(d,1-DATEPART(weekday,@current_dtm),@current_dtm),112) as week_key
, YEAR(@current_dtm)*100 + MONTH(@current_dtm) as month_key
, YEAR(@current_dtm)*100 + CONVERT(int,(MONTH(@current_dtm)-1)/3) as quarter_key
, YEAR(@current_dtm) as year_key
, DATEPART(hour,@current_dtm)*60 + DATEPART(minute,@current_dtm) + 1 AS minute_key

*/

IF OBJECT_ID('time') is not null
  drop table time
GO

CREATE TABLE [time] (
  minute_key int not null
, minute_uid varchar(20) not null
, source_key int not null
, minute_tm time
, minute_of_day int
, minute_of_hour int
, minute_desc_01 varchar(20)
, minute_desc_02 varchar(20)
, minute_desc_03 varchar(20)
, hour_key int
, hour_of_day int
, hour_desc_01  varchar(20)
, hour_desc_02 varchar(20)
, hour_desc_03 varchar(20)
, ampm_desc_01 varchar(20)
)

create unique clustered index time_uxc on time (minute_key)
create unique index time_ux1 on time (minute_uid, source_key)
go


insert into [time]
select
  0 -- minute_key
, '?' -- minute_uid
, 0 -- source_key
, null -- minute_tm
, null as minute_of_day
, null as minute_of_hour
, '(Unknown)' as minute_desc_01
, '(Unknown)' as minute_desc_02
, '(Unknown)' as minute_desc_03
, 0 as hour_key
, null as hour_of_day
, '(Unknown)' as hour_desc_01
, '(Unknown)' as hour_desc_02
, '(Unknown)' as hour_desc_03
, '(Unknown)' as ampm_desc_01

declare
  @first_tm time
, @minute int
, @current_tm time  

set @first_tm = '12:00:00am'
set @minute = 1

while @minute <= 24*60
BEGIN

set @current_tm = DATEADD(minute, @minute-1,@first_tm)

insert into [time]
select
  @minute -- minute_key
, SUBSTRING(CONVERT(char(8),@current_tm,114),1,5) -- minute_uid
, (select source_key from source where source_uid = 'STD') -- source_key
, @current_tm
, @minute -- minute_of_day
, case @minute % 60 when 0 then 60 else @minute % 60 end -- minute_of_hour
, CONVERT(char(5),@current_tm,114)-- minute_desc_01
, CONVERT(varchar(8),@current_tm,100) -- minute_desc_02
, '00:' + SUBSTRING(CONVERT(varchar(8),@current_tm,114),4,2) -- minute_desc_03
, convert(int,(@minute-1) / 60) + 1 -- hour_key
, convert(int,(@minute-1) / 60) + 1  -- hour of day
, CONVERT(char(2),@current_tm,114) + ':00' -- hour_desc_01
, STUFF(CONVERT(varchar(8),@current_tm,100),LEN(CONVERT(varchar(8),@current_tm,100))-3,2,'00') -- hour_desc_02
, STUFF(CONVERT(varchar(8),@current_tm,100),LEN(CONVERT(varchar(8),@current_tm,100))-4,3,'') -- hour_desc_03
, case when @minute <= 720 then 'AM' else 'PM' end -- ampm_desc_01

set @minute = @minute + 1

END
go


/* ################################################## */

CREATE FUNCTION minute_key_lookup (
  @reference_dtm datetime
)
RETURNS int AS
BEGIN
  RETURN DATEPART(hour,@reference_dtm)*60 + DATEPART(minute,@reference_dtm) + 1
END
go

/* ################################################## */


CREATE FUNCTION hour_key_lookup (
  @reference_dtm datetime
)
RETURNS int AS
BEGIN
  RETURN DATEPART(hour,@reference_dtm) + 1
END
go

/* ################################################## */
