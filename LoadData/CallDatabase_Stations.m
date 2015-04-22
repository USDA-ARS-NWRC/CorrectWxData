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
vars = {'snow_water_equiv'};
sta = {'MRKLI','TR216','SVT'};
dateFrom = '2013-10-01 00:00:00';
dateTo = '2014-09-30 23:00:00';
location = 'BRB';

% prepare the statement DO NOT CHANGE
v = strcat('fixed.',vars);
qry = sprintf(['SELECT station_id,date_time,%s FROM fixed '...
    'WHERE date_time BETWEEN ''%s'' AND ''%s'' AND '...
    'station_id IN (''%s'')'],...
    strjoin(vars,','), dateFrom, dateTo, strjoin(sta,''','''));

curs = exec(c,qry);
curs = fetch(curs);
data = curs.Data;


close(curs); close(c);
