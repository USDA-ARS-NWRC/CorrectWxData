% 20150324 Scott Havens
%
% Use this code as a template to use the outputed CSV file and enter it
% into a database
%
% This should be used as a utiltity that will do a bulk insert of a CSV
% into the database
%
% Expecting one variable per file, with column headers as
% primary_id/station_id
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

%%% INPUTS %%%
configFile = 'example.ini';
csvFile = '/Volumes/Drobo1/BRB/BRB-wy09/stationData/csv/final_precip.csv';
variable = 'precip_accum';
noData = 'NaN';     % no data value in CSV
tbl_to = 'tbl_level2';

%%% Parse config file %%%
ini = IniConfig();
ini.ReadFile(configFile);
sections = ini.GetSections();
config = struct('dem',[],'database',[],'date_range',[],'variables',[],'stations',[]);

for n = 1:length(sections)
    
    [keys, count_keys] = ini.GetKeys(sections{n});
    values = ini.GetValues(sections{n}, keys);
    
    for k = 1:count_keys
        if ~isempty(values{k})
            config.(sections{n}(2:end-1)).(keys{k}) = strtrim(values{k});
        end
    end
end


%%% Connect to the database %%%
c = database(config.database.dbName, config.database.user, config.database.password,...
    'Vendor',config.database.Vendor,...
    'Server',config.database.Server);
setdbprefs('DataReturnFormat','structure');

%%% Load the file %%%
A = importdata(csvFile);

% get the station_id and date_time
stations = A.textdata(1,2:end);
dates = A.textdata(2:end,1);
dates = cellstr(datestr(dates,'yyyy-mm-dd HH:MM:SS'));

%%% Prepare and execute the statement %%%
% v = strjoin(vars,',');
parfor_progress(length(stations));
for s = 1:length(stations)
    station_id = stations{s};
    
    for d = 1:length(dates)
        
        % change what values to enter into the database
        values = A.data(d,s);
        date_time = dates{d};
        
        % create the duplicate update elements and values to insert
        %         [dk,vi] = deal(cell(1,length(vars)));
        %         for k = 1:length(vars)
        if values == noData
            dk = sprintf('%s=NULL',vars{k});
            vi = 'NULL';
        else
            dk = sprintf('%s=''%f''',variable,values);
            vi = sprintf('''%f''',values);
        end
        %         end
        %         dk = strjoin(dk,',');
        %         vi = strjoin(vi,',');
        
        % create the statement
        qry = sprintf(['INSERT INTO %s (station_id,date_time,%s) '...
            'VALUES (''%s'',''%s'',%s) '...
            'ON DUPLICATE KEY UPDATE %s'],...
            tbl_to,variable,station_id,date_time,vi,dk);
        
        curs = exec(c,qry);
        
    end
    parfor_progress;
end

close(curs);
close(c);

parfor_progress(0);
