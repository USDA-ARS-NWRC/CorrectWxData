function results = CallDatabase(handles)

% 20151209 Scott Havens
%
% Get data from the database based on the users specified parameters in the
% config file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

results = 0;

%%% connect to the database %%%
config = handles.config;
c = database(config.database.dbName, config.database.user, config.database.password,...
    'Vendor',config.database.Vendor,...
    'Server',config.database.Server);

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
    
    qry = sprintf(['SELECT tbl_metadata.* FROM tbl_metadata INNER JOIN tbl_stations ON',...
        ' tbl_metadata.primary_id=tbl_stations.station_id WHERE tbl_stations.client=''%s'' ORDER BY tbl_metadata.primary_id'],...
        client);
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

qry = sprintf(['SELECT station_id,date_time,%s FROM %s '...
    'WHERE date_time BETWEEN ''%s'' AND ''%s'' AND '...
    'station_id IN (''%s'') GROUP BY date_time,station_id ORDER BY date_time ASC'],...
    vars, config.database.tbl_data_from, dateFrom, dateTo, strjoin(sta,''','''));

curs = exec(c,qry);
curs = fetch(curs);
data = curs.Data;

if ~isstruct(data)
    errordlg(data{1})
    return;
end

%%% parse the returned data from the database %%%
waitbar(2/3, h, 'Organizing data ...');

date_time = datenum(data.date_time);
vd = ['date_time', v]';

staind = zeros(size(sta));
for n = 1:length(sta)
    
    d = cell2struct(cell(size(vd)), vd, 1);
    
    % get the station
    ind = strcmp(sta{n}, data.station_id);
    
    if sum(ind) > 0
        
        % parse out the data to metadata structure
        dt = date_time(ind);
        timeIdx = ismember(times,dt);
        d.date_time = times;
        for k = 1:length(v)
            d.(v{k}) = NaN(length(times),1);
            d.(v{k})(timeIdx) = data.(v{k})(ind);
        end
        
        metadata(n).data = d;
    else
        staind(n) = 1;
    end
    
    waitbar(n/length(sta), h);
end
metadata(logical(staind)) = [];

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



function metadata = organizeMetadata(data)
% 20151209 Scott Havens
%
% The structure returned by the db is one sturcture with a cell array of
% all the values.  I want this to be the other way around

f = fieldnames(data);
N = length(data.primary_id);

metadata = cell2struct(cell(size(f)), f, 1);

for n = 1:N
    for k = 1:length(f)
        if iscell(data.(f{k}))
            metadata(n).(f{k}) = data.(f{k}){n};
        else
            metadata(n).(f{k}) = data.(f{k})(n);
        end
    end
    [x,y] = deg2utm(metadata(n).latitude, metadata(n).longitude);
    metadata(n).X = x;
    metadata(n).Y = y;
end


