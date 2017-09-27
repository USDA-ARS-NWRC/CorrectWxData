function results = CallDatabase(handles)

% 20151209 Scott Havens
%
% Get data from the database based on the users specified parameters in the
% config file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

results = 0;
nround = 6; % ensure that the times are similar to the second, don't care after that

%%% connect to the database %%%
config = handles.config;

% Added if/else to use 'Port' from the config file...wasn't able to
% successfully parse the subsequent Port string in a way that database()
% could use, so it's just hard coded here. Yeah.
if isfield(config.database,'Port')
    c = database(config.database.dbName, config.database.user, config.database.password,...
        'Vendor',config.database.Vendor,...
        'PortNumber',32768,...
        'Server',config.database.Server);
    
    % Uhhhh...yeah....
    % config.database.Port(1) = [];
    % config.database.Port(end) = [];
    % config.database.Port
else
    c = database(config.database.dbName, config.database.user, config.database.password,...
        'Vendor',config.database.Vendor,...
        'Server',config.database.Server);
end
%config.database

setdbprefs('DataReturnFormat','structure');
if ~isempty(c.Message)
    errordlg(c.Message);
    return;
end

%%% determine if it's stations or client %%%
flag = 0;
if isfield(handles.config.stations, 'stations')
    flag = 0;
elseif isfield(handles.config.stations, 'client')
    flag = 1;
else
    errordlg('Error in configuration file for [stations], must specify either "stations" or "client"');
    return;
end

%%% Get the start and end date %%%
dateFrom = datenum(handles.config.date_range.start);   % parse the users date
dateTo = datenum(handles.config.date_range.end);
times = [dateFrom:1/24:dateTo]';
timeStr = cellstr(datestr(times, 'yyyy-mm-dd HH:MM:SS'));


dateFrom = datestr(dateFrom,'yyyy-mm-dd HH:MM:SS');   % format to ISO
dateTo = datestr(dateTo,'yyyy-mm-dd HH:MM:SS');


%%% get the variables %%%
if isfield(handles.config.variables, 'var')
    vars = handles.config.variables.var;
    v = strtrim(regexp(vars, ',', 'split'));
else
    errordlg ('Error in configuration file for [variables], "var" not specified');
    return;
end

%%% check the tbl_data_from %%%
if ~isfield(config.database, 'tbl_data_from')
    errordlg ('Error in configuration file for [database], "tbl_data_from" not specified');
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load the station metadata %%%
h = waitbar(0, 'Loading station metadata ...');

if flag == 0
    % get metadata for the desired stations
    
    sta = regexp(handles.config.stations.stations,',','split');
    
    qry = sprintf('SELECT * FROM tbl_metadata WHERE primary_id IN (''%s'') ORDER BY primary_id',...
        strjoin(sta,''','''));
    curs = exec(c,qry);
    curs = fetch(curs);
    metadata = organizeMetadata(curs.Data);
    
else
    % get metadata for the desired area
    
    client = handles.config.stations.client;

    % Use new query if we are specifying 'Port'...
    if isfield(config.database,'Port')
        % 9/25/2017 - email from Scott - for new database
        qry = sprintf(['SELECT tbl_metadata.* FROM tbl_metadata INNER JOIN tbl_stations_view '...
            'ON tbl_metadata.primary_id = tbl_stations_view.primary_id WHERE tbl_stations_view.client = ''%s'' ORDER BY tbl_metadata.primary_id'],...
            client); 
    else
        qry = sprintf(['SELECT tbl_metadata.* FROM tbl_metadata INNER JOIN tbl_stations ON',...
            ' tbl_metadata.primary_id=tbl_stations.station_id WHERE tbl_stations.client=''%s'' ORDER BY tbl_metadata.primary_id'],...
            client);
    end
    
    curs = exec(c,qry);
    curs = fetch(curs);
    metadata = organizeMetadata(curs.Data);
    
end

sta = {metadata.primary_id};

%%% now get the data %%%
waitbar(1/3, h, 'Getting data from database...');

% qry = sprintf(['SELECT station_id,date_time,%s FROM %s '...
%     'WHERE date_time BETWEEN ''%s'' AND ''%s'' AND '...
%     'station_id IN (''%s'') GROUP BY date_time,station_id ORDER BY date_time ASC'],...
%     vars, config.database.tbl_data_from, dateFrom, dateTo, strjoin(sta,''','''));

qry = sprintf(['SELECT station_id,date_format(date_time,''%s'') as date_time_str,date_time,%s FROM %s '...
    'WHERE date_time BETWEEN ''%s'' AND ''%s'' AND '...
    'station_id IN (''%s'') GROUP BY date_time,station_id ORDER BY date_time ASC'],...
    '%Y-%m-%d %H:%i:%s', vars, config.database.tbl_data_from, dateFrom, dateTo, strjoin(sta,''','''));

curs = exec(c,qry);
curs = fetch(curs);
data = curs.Data;

if ~isstruct(data)
    errordlg(curs.Message)
    return;
end

%%% parse the returned data from the database %%%
waitbar(2/3, h, 'Organizing data ...');

metadata = organizeData(data, times, metadata);


%%% split data into componenents if necessary



results = metadata;

delete(h);

close(curs); close(c);
% 
% % Query parameters
% % vars = {'precip_accum'};
% % vars = {'air_temp'};
% vars = {'snow_water_equiv'};
% % vars = {'solar_radiation'};
% % vars = {'relative_humidity'};
% % vars = {'wind_speed'};
% % vars = {'wind_direction'};
% dateFrom = '2008-10-01 00:00:00';
% dateTo = '2009-10-01 00:00:00';
% location = 'BRB';
% 
% % prepare the statement DO NOT CHANGE
% qry = sprintf(['SELECT fixed.station_id,fixed.date_time,%s FROM fixed '...
%     'INNER JOIN stations on fixed.station_id=stations.station_id '...
%     'WHERE date_time BETWEEN ''%s'' AND ''%s'' '...
%     'AND stations.client=''%s'''],...
%     strjoin(vars,','), dateFrom, dateTo, location);
% 
% % 'fixed.station_id IN (''%s'')'
% 
% curs = exec(c,qry);
% v = strcat('fixed.',vars);
% curs = fetch(curs);
% data = curs.Data;
% 
% % % here you can perform some prior calculations to the data before loading
% % % into the program.  For example, break wind dir down into components
% % wd = data.wind_direction;
% % % ws = data.wind_speed;
% % ws_v = sind(wd);
% % ws_u = cosd(wd);
% %
% % data.wind_u = ws_u;
% % data.wind_v = ws_v;
% %
% % % add to the variable
% % vars = [vars 'wind_u' 'wind_v'];
% 
% close(curs); close(c);






