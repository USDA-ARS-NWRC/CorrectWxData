function results = SaveDatabase(handles)

% 20151211 Scott Havens
%
% Save the data to the database
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
% flag = 0;
% if isfield(handles.config.stations, 'stations')
%     flag = 0;
% elseif isfield(handles.config.stations, 'client')
%     flag = 1;
% else
%     errordlg('Error in configuration file for [stations], must specify either "stations" or "client"');
%     return;
% end

%%% Get the start and end date %%%
% dateFrom = datenum(handles.config.date_range.start);   % parse the users date
% dateTo = datenum(handles.config.date_range.end);
% times = [dateFrom:1/24:dateTo]';
%
% dateFrom = datestr(dateFrom,'yyyy-mm-dd HH:MM:SS');   % format to ISO
% dateTo = datestr(dateTo,'yyyy-mm-dd HH:MM:SS');

%%% check the tbl_data_from %%%
if ~isfield(config.database, 'tbl_data_to')
    errordlg ('Error in configuration file for [database], "tbl_data_to" not specified');
    return;
end

tbl_to = config.database.tbl_data_to;

%%% The saved data %%%
data = handles.savedData;
for n = 1:length(data)
    ind(n) = isfield(data(n).data, 'date_time');
end
data = data(ind);

%%% remove any split variables that may have been saved %%%
for n = 1:length(data)
    for v = 1:length(handles.splitVariables)
        if isfield(data(n).data, handles.splitVariables(v).u)
            data(n).data = rmfield(data(n).data, handles.splitVariables(v).u);
        end
        if isfield(data(n).data, handles.splitVariables(v).v)
            data(n).data = rmfield(data(n).data, handles.splitVariables(v).v);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load the station metadata %%%

% if flag == 0
%     % get metadata for the desired stations
%
%     sta = regexp(handles.config.stations.stations,',','split');
%
%     qry = sprintf('SELECT * FROM tbl_metadata WHERE primary_id IN (''%s'')',...
%         strjoin(sta,''','''));
%     curs = exec(c,qry);
%     curs = fetch(curs);
%     metadata = organizeMetadata(curs.Data);
%
% else
%     % get metadata for the desired area
%
%     client = handles.config.stations.client;
%
%     qry = sprintf(['SELECT tbl_metadata.* FROM tbl_metadata INNER JOIN stations ON',...
%         ' metadata.primary_id=stations.station_id WHERE stations.client=''%s'''],...
%         client);
%     curs = exec(c,qry);
%     curs = fetch(curs);
%     metadata = organizeMetadata(curs.Data);
%
% end

% sta = {metadata.primary_id};
%
% %%% now get the data %%%
% qry = sprintf(['SELECT station_id,date_time,%s FROM %s '...
%     'WHERE date_time BETWEEN ''%s'' AND ''%s'' AND '...
%     'station_id IN (''%s'') ORDER BY date_time ASC'],...
%     vars, config.database.tbl_data_from, dateFrom, dateTo, strjoin(sta,''','''));
% curs = exec(c,qry);
% curs = fetch(curs);
% data = curs.Data;
%
% if ~isstruct(data)
%     errordlg(data{1})
%     return;
% end

%%% parse the returned data from the database %%%
h = waitbar(0,'Saving data',...
    'CreateCancelBtn',...
    'setappdata(gcbf,''canceling'',1)');
setappdata(h,'canceling',0)




for n = 1:length(data)
    
    % get the station_id and dates
    station_id = data(n).primary_id;
    dates = data(n).data.date_time;
    N = length(dates);
    
    waitbar(n/length(data), h, sprintf('%s -- %i of %i', station_id, n, length(data)));
    if getappdata(h,'canceling')
        break
    end
    
    vars = fieldnames(data(n).data);   % saved variables
    vars(strcmp('date_time',vars)) = [];
    
    VALUES = cell(N,1);
    
    for d = 1:N
        
        % create the duplicate update elements and values to insert
        [dk,vi] = deal(cell(1,length(vars)));
        for k = 1:length(vars)
            values = data(n).data.(vars{k})(d);
            if isnan(values)
                dk{k} = sprintf('%s=NULL',vars{k});
                vi{k} = 'NULL';
            else
                dk{k} = sprintf('%s=''%f''',vars{k},values);
                vi{k} = sprintf('''%f''',values);
            end
        end
        dk = strjoin(dk,',');
        vi = strjoin(vi,',');
        
        % the VALUES part of the insert for each row
        VALUES{d} = sprintf('(''%s'',''%s'',%s)', station_id, ...
            datestr(dates(d), 'yyyy-mm-dd HH:MM:SS'), vi);
        
    end
    
    VALUES = strjoin(VALUES, ',\n');
    
    UPDATE = cell(length(vars),1);
    for v = 1:length(vars)
        UPDATE{v} = sprintf('%s=VALUES(%s)', vars{v}, vars{v});
    end
    UPDATE = strjoin(UPDATE, ',\n');
    
    % create the statement
    qry = sprintf(['INSERT INTO %s (station_id,date_time,%s) '...
        'VALUES %s '...
        'ON DUPLICATE KEY UPDATE %s'],...
        tbl_to, strjoin(vars,','), VALUES, UPDATE);
    
    curs = exec(c,qry);
    
    if ~isempty(curs.Message)
        error('Could not add data to database for %s', station_id);
    end
    
    
end

delete(h)       % DELETE the waitbar; don't try to CLOSE it.

results = 1;
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


