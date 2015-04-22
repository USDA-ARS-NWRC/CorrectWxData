% 20150311 Scott Havens
%
% Use this code as a template to grab data from the database for
% CorrectWxData GUI.  There cannot be one solution for everyone so you will
% have to create the SQL syntax and load the data into a structure.
%
% Things that will help the process:
% 1. Ensure that the dates are rounded to some common format so a matrix of
%    values can be created.
% 2. Return the data in a structure format into the variable "data"
% 3. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Load the st ation metadata %%%
c = database('weather','scott','avalanche',...
    'Vendor','MySQL',...
    'Server','10.200.28.203');
setdbprefs('DataReturnFormat','structure');


% Query parameters
vars = {'air_temp'};
sta = {'BNRI1','TR216','SVT'};
dateFrom = '2007-10-01 00:00:00';
dateTo = '2007-12-31 00:00:00';
location = 'BRB';

% prepare the statement DO NOT CHANGE
v = strcat('fixed.',vars);
qry = sprintf(['SELECT fixed.station_id,fixed.date_time,%s FROM fixed '...
    'INNER JOIN stations on fixed.station_id=stations.station_id '...
    'WHERE date_time BETWEEN ''%s'' AND ''%s'' AND '...
    'stations.client=''%s'''],...
    strjoin(vars,','), dateFrom, dateTo, location);

% 'fixed.station_id IN (''%s'')'

curs = exec(c,qry);
curs = fetch(curs);
data = curs.Data;

% here you can perform some prior calculations to the data before loading
% into the program.  For example, break wind dir down into components
% wd = data.wind_direction;
% ws = data.wind_speed;
% ws_u = ws.*sind(wd);
% ws_v = ws.*cosd(wd);
% 
% data.wind_u = ws_u;
% data.wind_v = ws_v;

% add to the variable
% vars = [vars 'wind_u' 'wind_v'];

close(curs); close(c);
