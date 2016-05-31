--date string + time string
--normal value
set timezone 'Asia/Seoul';
select addtime('2000-1-1','13:00:00');
select to_datetime_tz(addtime('2000-1-1' ,'13:00:00'));
--select to_timestamp_tz(addtime('2000-1-1' ,'13:00:00'));

--non-exist value
set timezone 'America/New_York';
select addtime('2015-3-8' ,'2:30:00');
select to_datetime_tz(addtime('2015-3-8' ,'2:30:00'));
--select to_timestamp_tz(addtime('2015-3-8' ,'2:30:00'));

--exist value
select to_datetime_tz(addtime('2015-3-8' ,'1:30:00')); 
select to_datetime_tz(addtime('2015-3-8' ,'3:30:00')); 