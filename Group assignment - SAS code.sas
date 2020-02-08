libname Air "C:\Users\jmotyl\Documents\GitHub\BRT\Group assignment";
/* Delay per flight Company */

proc SQL;
create table Delay_per_Airline as
SELECT A.name, case when F.air_time <90 then "Short Flight"
	when F.air_time <=210 then "Medium Flight"
	when F.air_time >210 then "Long Flight"
	else "unknown" end as Length_of_Flight,
	sum(F.dep_delay) as Total_DepDelay, sum(F.arr_delay) as Total_ArrDelay, sum(F.air_time) as Total_Time_Spend_in_Air, 
	sum(F.dep_delay)/sum(F.air_time) as Ratio_DepDelay_Airtime, sum(F.arr_delay)/sum(F.air_time) as Ratio_ArrDelay_Airtime,
	count(F.time_hour) as Number_of_Flight
FROM Air.Flights F, Air.Airlines A
WHERE F.carrier = A.carrier
Group by 1,2;

quit;
run;

/* Departure delay per Airport */
proc SQL;

create table Dep_Delay_per_Airport as
SELECT A.name, sum(F.dep_delay) as Total_DepDelay, count(F.tailnum) as Number_of_Planes, 
	sum(F.dep_delay)/count(F.tailnum) as Mean_DepDelay_perFlight
FROM Air.Flights F, Air.Airports A
WHERE F.origin = A.faa
Group by 1
ORDER BY 4 desc;

quit;
run;

proc SQL;
/*Type of aircraft per Airline */

create table Plane_Type_Delays_Per_Airline as
SELECT  A.name, P.manufacturer,P.type, count(UNIQUE(P.tailnum)) as NumberOfAircraft, sum(F.air_time) as CumumatedTimeOnAir,
	sum(F.dep_delay) as DepartureDelay,sum(F.arr_delay) as ArrivalDelay
FROM Air.Flights F, Air.Airlines A, Air.Planes P
WHERE A.carrier = F.carrier
AND F.tailnum = P.tailnum
Group by 1,2,3;

quit;
run;


/* Arrival delay per Airport */
proc SQL;

create table Arr_Delay_per_Airport as
SELECT A.name, F.carrier as Company, sum(F.arr_delay) as Total_ArrDelay, count(F.tailnum) as Number_of_Planes, 
	sum(F.arr_delay)/count(F.tailnum) as Mean_ArrDelay_perFlight
FROM Air.Flights F, Air.Airports A
WHERE F.dest = A.faa
Group by 1, 2
ORDER BY 5 desc, 1;

quit;
run;

/* Influence of PRECISE temperature on delay */
proc SQL outobs=1000;

create table Delay_Per_TemperaturePRECISE as
SELECT round(W.temp) as Temperature,
	sum(F.arr_delay) as Arrival_Delay,
	sum(F.dep_delay) as Departure_Delay,
	sum(F.air_time) as CumulatedAirTime,
	sum(F.arr_delay)/sum(F.air_time) as RatioArrDelay_AirTime,
	sum(F.dep_delay)/sum(F.air_time) as RatioDepDelay_AirTime,
	count(F.tailnum) as Number_of_Planes
FROM Air.Flights F, Air.Weather W
WHERE W.year = F.year
AND W.month = F.month
AND W.day = F.day
GROUP BY 1
ORDER BY 1 desc;

quit;
run;

/* Influence of PRECISE temperature and AIRPORT origin on departure delay  */
proc SQL outobs=1000;

create table DepDelay_per_Temp_and_Airport as
SELECT round(W.temp) as Temperature, A.name as Departure_Airport,
	sum(F.dep_delay) as Departure_Delay,
	sum(F.air_time) as CumulatedAirTime,
	sum(F.dep_delay)/count(F.time_hour) as Average_Delay_per_Flight
FROM Air.Flights F, Air.Weather W, Air.Airports A
WHERE W.year = F.year
AND W.month = F.month
AND W.day = F.day
AND F.origin = A.faa 
GROUP BY 1,2
ORDER BY 1 desc;

quit;
run;

/* Influence of PRECISE temperature and AIRPORT origin on departure delay  */
proc SQL outobs=1000;

SELECT round(avg(W.temp)) as Temperature, A.name as Departure_Airport,
	sum(F.dep_delay) as Departure_Delay,
	sum(F.air_time) as CumulatedAirTime,
	sum(F.dep_delay)/count(F.time_hour) as Average_Delay_per_Flight
FROM Air.Flights F, Air.Weather W, Air.Airports A
WHERE W.month = F.month
AND W.day = F.day
AND F.origin = A.faa 
GROUP BY W.month,W.day,1,2
ORDER BY 1 desc;

quit;
run;
/* Influence of temperature on Arrival delay */
proc SQL outobs=1000;

create table Delay_Per_TemperatureRange as 
SELECT case when W.temp < 32 then "Icy cold"
	when W.temp <50 then "Cold"
	when W.temp <80 then "Moderate"
	when W.temp <100 then "Hot"
	else "Extremely hot" end as Temperature,
	sum(F.arr_delay) as Arrival_Delay,
	sum(F.dep_delay) as Departure_Delay,
	sum(F.air_time) as CumulatedAirTime,
	sum(F.arr_delay)/sum(F.air_time) as RatioArrDelay_AirTime,
	sum(F.dep_delay)/sum(F.air_time) as RatioDepDelay_AirTime
FROM Air.Flights F, Air.Weather W
WHERE W.year = F.year
AND W.month = F.month
AND W.day = F.day
GROUP BY 1
ORDER BY 5 desc;

quit;
run;

proc SQL;

Select case when W.temp < 32 then "Icy cold"
	when W.temp <50 then "Cold"
	when W.temp <80 then "Moderate"
	when W.temp <100 then "Hot"
	else "Extremely hot" end as Temperature,
	avg(air_time), max(air_time),min(air_time)
FROM Air.Flights;

quit;
run;




/* exporting the tables created */
PROC EXPORT DATA = Delay_per_Airline
         OUTFILE = "C:\Users\jmotyl\Documents\GitHub\group assignment\DelayPerAirlines.csv"
            DBMS = DLM REPLACE ;
   DELIMITER = "," ; /* séparator */
run;
PROC EXPORT DATA = Dep_Delay_per_Airport
         OUTFILE = "C:\Users\jmotyl\Documents\GitHub\group assignment\DepDelayPerAirport.CSV"
            DBMS = DLM REPLACE ;
   DELIMITER = "," ; /* séparator */
run;
PROC EXPORT DATA = Arr_Delay_per_Airport
         OUTFILE = "C:\Users\jmotyl\Documents\GitHub\group assignment\ArrDelayPerAirport.CSV"
            DBMS = DLM REPLACE ; ;
   DELIMITER = "," ; /* séparateur tabulation */
run;

PROC EXPORT DATA = Plane_Type_Delays_Per_Airline
         OUTFILE = "C:\Users\jmotyl\Documents\GitHub\group assignment\DelaysPerPlaneTypePerAirlines.CSV"
            DBMS = DLM REPLACE ; ;
   DELIMITER = "," ; /* séparator */
run;

PROC EXPORT DATA = Delay_Per_TemperaturePRECISE
         OUTFILE = "C:\Users\jmotyl\Documents\GitHub\group assignment\DelaysPerPreciseTemperature.CSV"
            DBMS = DLM REPLACE ; ;
   DELIMITER = "," ; /* séparator */
run;

PROC EXPORT DATA = DepDelay_per_Temp_and_Airport
         OUTFILE = "C:\Users\jmotyl\Documents\GitHub\group assignment\DelaysPerTemperature&Airport.CSV"
            DBMS = DLM REPLACE ;
   DELIMITER = "," ; /* séparator */
run;

/* */
libname NYC 'C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data';run;
/* Point1 Which date has the largest average departure delay?*/
Proc SQL;
create table Nyc.Largestdelay as 
select month,day , avg(dep_delay) as AvgDepDelay
from Nyc.Flights
group by 1,2
order by 3 desc
;
quit;
run;
/* Point 3.1 export your table to tableau */
proc export data = Nyc.Largestdelay
OUTFILE = "C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data\Largestdelay.csv"
DBMS = DLM REPLACE;
DELIMITER = "," ;
run;
/* Point 4 Link temperature per day to understand why 8th of march was the most delay*/
Proc SQL;
create table Nyc.Highestemp as 
select day,month,avg(temp) as AvgTemperature 
from Nyc.Weather
group by 2 , 1
order by 2 asc, 1 asc
;
quit;
run;
/* Point 4.1 export your table to tableau */
proc export data = Nyc.Highestemp
OUTFILE = "C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data\Highestemp.csv"
DBMS = DLM REPLACE;
DELIMITER = "," ;
run;
/* Point 5 Which date has the largest average arrival delay?*/
Proc SQL;
select month,day , avg(arr_delay) as AvgArrDelay
from Nyc.Flights
group by 1,2
order by 3 desc
;
quit;
run;             /*The largest average departure(83.5369 min) and arrival delay(85.8622) was on 8th of March 2013*/
/*Point 6 What is the day with maximum number of delayed flights */
Proc SQL;
create table Nyc.MaxDelayedFlights as
select month,day,count(*) as NumberOfDelayedFlights
from Nyc.Flights
where dep_delay > 0
group by 1,2
order by 3 desc
;
quit;
run;  /*Worst day to fly out of NYC in 2013 was 23rd of December with 674 flights having a delayed departure*/
/* Point 6.1 export your table to tableau */
proc export data = Nyc.MaxDelayedFlights
OUTFILE = "C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data\MaxDelayedFlights.csv"
DBMS = DLM REPLACE;
DELIMITER = "," ;
run;
/* Point 7 Average Monthly Departure Delay for Carrier*/
Proc SQL outobs =100;
select A.carrier , B.month, avg(B.dep_delay)as Totaldelay
from Nyc.Airlines as A, Nyc.Flights as B
where A.carrier = B.carrier
group by 1,2
;
quit;
run;
/* Point 8 Average arr_delay by Carrier in 2013*/
Proc SQL;
select A.carrier , A.name, B.year, avg(B.arr_delay)as Totaldelay
from Nyc.Airlines as A, Nyc.Flights as B
where A.carrier = B.carrier
group by 1,2,3
order by 4 desc
;
quit;
run;

/* Point 9 Average dep_delay by carrier in 2013*/
Proc SQL;
create table Nyc.DelayPerCarrier as
select A.carrier ,A.name, B.year, avg(B.dep_delay)as Totaldelay
from Nyc.Airlines as A, Nyc.Flights as B
where A.carrier = B.carrier
group by 1,2,3
order by 4 desc
;
quit;
run;
/* Point 9.1 export your table to tableau */
proc export data = Nyc.DelayPerCarrier
OUTFILE = "C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data\DelayPerCarrier.csv"
DBMS = DLM REPLACE;
DELIMITER = "," ;
run;
/* Point 10 Number of scheduled flights per airline */
Proc SQL;
create table Nyc.NumberOfFlightsperAirline as
select a.name, b.carrier, count(b.sched_dep_time)
from Nyc.Airlines as a , Nyc.Flights as b
where a.carrier = b.carrier
group by 1,2
order by 3 desc
;
quit;
run;
/* Point 10.1 export your table to tableau */
proc export data = Nyc.NumberOfFlightsperAirline
OUTFILE = "C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data\NumberOfFlightsperAirline.csv"
DBMS = DLM REPLACE;
DELIMITER = "," ;
run;
/* Point 11 Number of scheduled departure from different origin */
Proc SQL;

select origin,count(sched_dep_time)
from Nyc.Flights
group by 1
order by 2 desc
;
quit;
run;
/*Point 12 Average Monthly departure delay per carrier from NYC */
Proc SQL;
create table Nyc.SeasonalPerCarrier as 
select a.carrier, avg(a.dep_delay) as AvgDepDelay, b.name,
CASE month 
when 12 then "winter"
when 1 then "winter"
when 2 then "winter"
when 3 then "spring"
when 4 then "spring"
when 5 then "spring"
when 6 then "summer"
when 7 then "summer"
when 8 then "summer"
ELSE "fall"
END as season
from Nyc.Flights as a, Nyc.Airlines as b
where a.carrier = b.carrier
group by 1,3,4
order by 1,3,4 asc
;
quit;
run;
/* Point 12.1 export your table to tableau */
proc export data = Nyc.SeasonalPerCarrier
OUTFILE = "C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data\SeasonalPerCarrier.csv"
DBMS = DLM REPLACE;
DELIMITER = "," ;
run;
/*Point 13  Plot the worst 40 routes (routes with highest delays) */
proc sql outobs=40;
create table Nyc.BadRoutes as
select f.dest || f.origin as route,
		ap.lat as Latitude,
		ap.lon as Longtitude,
		"origin" as type,
		case when f.dest || f.origin like "%EWR%" then "EWR"
		when f.dest || f.origin like "%LGA%" then "LGA"
		when f.dest || f.origin like "%JFK%" then "JFK"
		end as NYC_Airport,
		count(f.flight) as nr_flights,
		avg(f.dep_delay) as avg_delay_min format=comma8.1,
		avg(f.air_time) as avg_air_time,
		avg(f.dep_delay) / avg(f.air_time) as delay_per_airtime
from Nyc.flights as f
	inner join Nyc.airports as ap on f.origin = ap.faa
group by route
union
select f.dest || f.origin as route,
		ap.lat as Latitude,
		ap.lon as Longitude,
		"dest" as type,
		case when f.dest || f.origin like "%EWR%" then "EWR"
		when f.dest || f.origin like "%LGA%" then "LGA"
		when f.dest || f.origin like "%JFK%" then "JFK"
		end as NYC_Airport,
		count(f.flight) as nr_flights,
		avg(f.dep_delay) as avg_delay_min format=comma8.1,
		avg(f.air_time) as avg_air_time,
		avg(f.dep_delay) / avg(f.air_time) as delay_per_airtime
from Nyc.flights as f
	inner join Nyc.airports as ap on f.dest = ap.faa
group by route
order by avg_delay_min desc
;
quit;
run;

 /* Point 13.1 export your table to tableau */
proc export data = Nyc.BadRoutes
OUTFILE = "C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data\BadRoutes.csv"
DBMS = DLM REPLACE;
DELIMITER = "," ;
run;
/* Point 14 dep delay analysis based on seat numbers */
Proc SQL;
create table Nyc.NumberofSeats as
select a.seats, avg(b.dep_delay) as DepDelay
from Nyc.Planes as a , Nyc.Flights as b
where a.tailnum = b.tailnum
group by 1
order by 2 desc
;
quit;
run;

 /* Point 14.1 export your table to tableau */
proc export data = Nyc.NumberofSeats
OUTFILE = "C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data\NumberofSeats.csv"
DBMS = DLM REPLACE;
DELIMITER = "," ;
run;


/* Point 15 dep delay analysis based on engine */
Proc SQL;
create table Nyc.engines as
select a.engines, a.engine, avg(b.dep_delay) as DepDelay
from Nyc.Planes as a , Nyc.Flights as b
where a.tailnum = b.tailnum
group by 1,2
order by 3 desc
;
quit;
run;

/* Point 15.1 export your table to tableau */
proc export data = Nyc.engines
OUTFILE = "C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data\engines.csv"
DBMS = DLM REPLACE;
DELIMITER = "," ;
run;
/* Point 16 planes using bad engines */
Proc SQL;
create table Nyc.badengineplanes as
select a.engines, a.engine,b.carrier, avg(b.dep_delay) as DepDelay
from Nyc.Planes as a , Nyc.Flights as b
where a.tailnum = b.tailnum
group by 1,2,3
order by 4 desc
;
quit;
run;
/* Point 16.1 export your table to tableau */
proc export data = Nyc.badengineplanes
OUTFILE = "C:\Users\oabdelgelil\Desktop\SAS SQL GROUP PROJECT\data\badengineplanes.csv"
DBMS = DLM REPLACE;
DELIMITER = "," ;
run;

/* */

libname groups "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\BRT-master\Group assignment";
/*Ranges of Humidities and Delay*/

proc sql;
create table HumidityEffects as
select count(f.time_hour) as NumberOfFlights,sum(f.dep_delay)/count(f.time_hour) as AverageDepDelay, Humidity from (
select origin, time_hour, 
case when humid > 0 & humid < 10 then "0-10" 
when humid >= 10 & humid < 20 then "10-20"
when humid >= 20 & humid < 30 then "20-30" 
when humid >= 30 & humid < 40 then "30-40"
when humid >= 40 & humid < 50 then "40-50"
when humid >= 50 & humid < 60 then "50-60"
when humid >= 60 & humid < 70 then "60-70"
when humid >= 70 & humid < 80 then "70-80"
when humid >= 80 & humid < 90 then "80-90"else
"90+" end as Humidity from groups.weather) a, 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour
and w.origin = a.origin 
and w.time_hour = a.time_hour
group by Humidity;
quit; 

PROC EXPORT DATA = HumidityEffects
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\HumidityEffects"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run;

/*Ranges of Wind Speeds and Delay*/
proc sql;
create table WindSpeedEffects as
select count(f.time_hour)as NumberOfFlights,sum(f.dep_delay)/count(f.time_hour) as AverageDepDelay, WindSpeed from (
select origin, time_hour, 
case 
when wind_speed > 0 & wind_speed < 4 then "00-04" 
when wind_speed >= 4 & wind_speed < 6 then "04-06" 
when wind_speed >= 6 & wind_speed < 8 then "06-08"
when wind_speed >= 8 & wind_speed < 10 then "08-10"
when wind_speed >= 10 & wind_speed < 12 then "10-12"
when wind_speed >= 12 & wind_speed < 14 then "12-14"
when wind_speed >= 14 & wind_speed < 16 then "14-16"
when wind_speed >= 16 & wind_speed < 18 then "16-18"
when wind_speed >= 18 & wind_speed < 20 then "18-20"
else
"20+" end as WindSpeed from groups.weather) a, 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour
and w.origin = a.origin 
and w.time_hour = a.time_hour
group by WindSpeed;
quit; 

PROC EXPORT DATA = WindSpeedEffects
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\WindSpeedEffects"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run;

/*Ranges of Pressure and Delay*/
proc sql;
create table PressureEffects as
select count(f.time_hour)as NumberOfFlights,sum(f.dep_delay)/count(f.time_hour)as AverageDepDelay, SeaPressure from (
select origin, time_hour, 
case 
when pressure > 0 & pressure < 1000 then "0000-1000" 
when pressure >= 1003 & pressure < 1006 then "1000-1003"
when pressure >= 1003 & pressure < 1006 then "1003-1006" 
when pressure >= 1006 & pressure < 1009 then "1006-1009"
when pressure >= 1009 & pressure < 1012 then "1009-1012" 
when pressure >= 1012 & pressure < 1015 then "1012-1015"
when pressure >= 1015 & pressure < 1018 then "1015-1018" 
when pressure >= 1018 & pressure < 1021 then "1018-1021"
when pressure >= 1021 & pressure < 1024 then "1021-1024" 
when pressure >= 1024 & pressure < 1027 then "1024-1027" else
"1027+" end as SeaPressure from groups.weather) a, 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour
and w.origin = a.origin 
and w.time_hour = a.time_hour
group by SeaPressure;
quit; 

PROC EXPORT DATA = PressureEffects
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\PressureEffects"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run;


/*Ranges of Visibility and Delay*/
proc sql;
create table VisibilityEffects as 
select count(f.time_hour) as NumberOfFlights,sum(f.dep_delay)/count(f.time_hour)as AverageDepDelay, Visibility from (
select origin, time_hour, 
case 
when visib > 0 & visib < 1 then "00-01" 
when visib >= 1 & visib < 2 then "01-02"
when visib >= 2 & visib < 3 then "02-03" 
when visib >= 3 & visib < 4 then "03-04"
when visib >= 4 & visib < 5 then "04-05" 
when visib >= 5 & visib < 6 then "05-06"
when visib >= 6 & visib < 7 then "06-07" 
when visib >= 7 & visib < 8 then "07-08"
when visib >= 8 & visib < 9 then "08-09" 
else "09-10" 
end as Visibility from groups.weather) a, 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour
and w.origin = a.origin 
and w.time_hour = a.time_hour
group by Visibility;
quit; 

PROC EXPORT DATA = VisibilityEffects
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\VisibilityEffects"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run;



/*Ranges of Dewpoints and Delay*/
proc sql;
create table DewpointEffects as 
select count(f.time_hour) as NumberOfFlights,sum(f.dep_delay)/count(f.time_hour)as AverageDepDelay, Dewpoint from (
select origin, time_hour, 
case 
when dewp > 0 & dewp < 10 then "00-10" 
when dewp >= 10 & dewp < 20 then "10-20"
when dewp >= 20 & dewp < 30 then "20-30" 
when dewp >= 30 & dewp < 40 then "30-40"
when dewp >= 40 & dewp < 50 then "40-50" 
when dewp >= 50 & dewp < 60 then "50-60"
when dewp >= 60 & dewp < 70 then "60-70" 
when dewp >= 70 & dewp < 80 then "70-80"
when dewp >= 80 & dewp < 90 then "80-90" else
"90+" end as Dewpoint from groups.weather) a, 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour
and w.origin = a.origin 
and w.time_hour = a.time_hour
group by Dewpoint;
quit; 


PROC EXPORT DATA = DewpointEffects
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\DewpointEffects"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run;

/*Ranges of WindDirection and Delay*/

proc sql;
create table WindDirectionEffects as
select count(f.time_hour) as NumberOfFlights,sum(dep_delay)/count(f.time_hour)as 
AverageDepDelay, WindDirection from (
select origin, time_hour, 
case 
when wind_dir > 0 & wind_dir < 36 then "000-036" 
when wind_dir >= 36 & wind_dir < 72 then "036-072"
when wind_dir >= 72 & wind_dir < 108 then "072-108" 
when wind_dir >= 108 & wind_dir < 144 then "108-144" 
when wind_dir >= 144 & wind_dir < 180 then "144-180" 
when wind_dir >= 180 & wind_dir < 216 then "180-216" 
when wind_dir >= 216 & wind_dir < 252 then "216-252" 
when wind_dir >= 252 & wind_dir < 288 then "252-288" 
when wind_dir >= 288 & wind_dir < 324 then "288-324"  
else
"324-360" end as WindDirection from groups.weather) a, 
groups.flights f 
where f.origin = a.origin 
and f.time_hour = a.time_hour
group by WindDirection;
quit;

PROC EXPORT DATA = WindDirectionEffects
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\WindDirectionEffects"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 



/*Ranges of WindGusts and Delay*/

proc sql;
create table WindGustEffects as 
select count(f.time_hour) as NumberOfFlights,sum(dep_delay)/count(f.time_hour)as 
AverageDepDelay, WindGust from (
select origin, time_hour, 
case 
when wind_gust > 0 & wind_gust < 20 then "00-20" 
when wind_gust >= 20 & wind_gust < 25 then "20-25" 
when wind_gust >= 25 & wind_gust < 30 then "25-30" 
when wind_gust >= 30 & wind_gust < 35 then "30-35" 
when wind_gust >= 35 & wind_gust < 40 then "35-40" 
when wind_gust >= 40 & wind_gust < 45 then "40-45" 
when wind_gust >= 45 & wind_gust < 50 then "45-50" 
when wind_gust >= 50 & wind_gust < 55 then "50-55" 
when wind_gust >= 55 & wind_gust < 60 then "55-60" 
when wind_gust >= 60 & wind_gust < 65 then "60-65"
else
"65+" end as WindGust from groups.weather) a, 
groups.flights f 
where f.origin = a.origin 
and f.time_hour = a.time_hour
group by WindGust;
quit;

PROC EXPORT DATA = WindGustEffects
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\WindGustEffects"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 


/*Ranges of Precipitation and Delay*/
proc sql;
create table PrecipitationEffects as 
select count(f.time_hour) as NumberOfFlights,sum(dep_delay)/count(f.time_hour)as 
AverageDepDelay, Precipitation from (
select origin, time_hour, 
case 
when precip >= 0 & precip < 0.01 then "0-0.01" 
when precip >= 0.01 & precip < 0.02 then "0.01-0.02"
when precip >= 0.02 & precip < 0.03 then "0.02-0.03" 
when precip >= 0.03 & precip < 0.04 then "0.03-0.04" 
when precip >= 0.04 & precip < 0.05 then "0.04-0.05"
else
"0.05+" end as Precipitation from groups.weather) a, 
groups.flights f 
where f.origin = a.origin 
and f.time_hour = a.time_hour
group by Precipitation;
quit;

PROC EXPORT DATA = PrecipitationEffects
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\PrecipitationEffects"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 

/*Rounded Humidities and Delay*/

proc sql;
create table DifferentHumid as 
select round(humid) as Humidities, sum(f.dep_delay)/count(f.time_hour) as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour
group by Humidities
order by Humidities;
quit; 

PROC EXPORT DATA = DifferentHumid
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\DifferentHumid"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 
/*Rounded Pressure and Delay*/

proc sql;
create table Differentpressure as 
select round(pressure) as pressure, sum(f.dep_delay)/count(f.time_hour) as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour
group by pressure
order by pressure;
quit; 

PROC EXPORT DATA = DifferentPressure
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\DifferentPressure"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 

/*Rounded Wind Speeds and Delay*/

proc sql;
create table DifferentWindSpeed as 
select round(wind_speed) as wind_speed, sum(f.dep_delay)/count(f.time_hour) as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour
group by wind_speed
order by wind_speed;
quit; 

PROC EXPORT DATA = DifferentWindSpeed
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\DifferentWindSpeed"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 


/*Select All of the Wind Speeds and Departure Delay*/
proc sql;
create table ZZZ as
select w.origin, w.time_hour, wind_speed as wind_speed, f.dep_delay as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour;
quit; 

PROC EXPORT DATA = ZZZ
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\ZZZ"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 



/*Select All of the Dewp and Departure Delay*/
proc sql;
create table ZZZ1 as
select w.origin, w.time_hour, dewp as dewpoints, f.dep_delay as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour;
quit; 

PROC EXPORT DATA = ZZZ1
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\ZZZ1"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 


/*Select All of the humidities and Departure Delay*/
proc sql;
create table zzz2 as
select w.origin, w.time_hour, humid as humidities, f.dep_delay as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour
and RANUNI(4321) between .45 and .55 ;
quit; 

PROC EXPORT DATA = ZZZ2
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\ZZZ2"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 




/*Select All of the wind_dir and Departure Delay*/
proc sql;
create table zzz3 as 
select w.origin, w.time_hour, wind_dir as WindDirection, f.dep_delay as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour;
quit; 


PROC EXPORT DATA = ZZZ3
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\ZZZ3"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 


/*Select All of the WindGust and Departure Delay*/
proc sql;
create table zzz4 as 
select w.origin, w.time_hour, wind_gust as WindGust, f.dep_delay as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour;
quit; 


PROC EXPORT DATA = ZZZ4
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\ZZZ4"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 


/*Select All of the WindPrecip and Departure Delay*/
proc sql;
create table zzz5 as 
select w.origin, w.time_hour, precip as Precipation, f.dep_delay as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour;
quit; 


PROC EXPORT DATA = ZZZ5
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\ZZZ5"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 

/*Select All of the Pressure and Departure Delay*/
proc sql;
create table zzz6 as 
select w.origin, w.time_hour, pressure as Pressure, f.dep_delay as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour;
quit; 


PROC EXPORT DATA = ZZZ6
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\ZZZ6"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 

/*Select All of the Pressure and Departure Delay*/
proc sql;
create table zzz7 as 
select w.origin, w.time_hour, visib as Visibility, f.dep_delay as DepDelay
from 
groups.flights f, 
groups.weather w
where f.origin = w.origin 
and f.time_hour = w.time_hour;
quit; 


PROC EXPORT DATA = ZZZ7
         OUTFILE = "C:\Users\xzong\Desktop\MBD\BusinessReportingTools\Assignment\ZZZ7"
            DBMS = CSV REPLACE ;
   DELIMITER = "09"x ; /* séparateur tabulation */
run; 

