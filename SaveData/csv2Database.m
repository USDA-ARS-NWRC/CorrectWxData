% 20150324 Scott Havens
%
% Use this code as a template to use the outputed CSV file and enter it
% into a database
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

%%% Connect to the database %%%
user = 'scott';
c = database('weather',user,'avalanche',...
    'Vendor','MySQL',...
    'Server','10.200.28.203');
setdbprefs('DataReturnFormat','structure');

%%% Load the file %%%
A = importdata('/Volumes/Drobo1/SCOTT/BRB/wy-15/spatial/data/airtemp/station_data/CorrectedData.1001-1231.air_temp.csv');
noData = -9999;

% get the station_id and date_time
stations = A.textdata(1,2:end);
dates = A.textdata(2:end,1);
dates = cellstr(datestr(dates,'yyyy-mm-dd HH:MM:SS'));

%%% Variables to insert %%%
vars = {'air_temp'};

%%% Prepare and execute the statement %%%
v = strjoin(vars,',');
parfor_progress(length(stations));
for s = 1:length(stations)
    station_id = stations{s};
    
    for d = 1:length(dates)
        
        % change what values to enter into the database
        values = A.data(d,s);
        date_time = dates{d};
                
        % create the duplicate update elements and values to insert
        [dk,vi] = deal(cell(1,length(vars)));
        for k = 1:length(vars)
            if values(k) == noData
                dk{k} = sprintf('%s=NULL',vars{k});
                vi{k} = 'NULL';
            else
                dk{k} = sprintf('%s=''%f''',vars{k},values(k));
                vi{k} = sprintf('''%f''',values(k));
            end
        end
        dk = strjoin(dk,',');
        vi = strjoin(vi,',');
        
        % create the statement
        qry = sprintf(['INSERT INTO corrected (station_id,date_time,%s) '...
            'VALUES (''%s'',''%s'',%s) '...
            'ON DUPLICATE KEY UPDATE %s'],...
            v,station_id,date_time,vi,dk);
        
        curs = exec(c,qry);
        
    end
    parfor_progress;
end

close(curs); 
close(c);

parfor_progress(0);
