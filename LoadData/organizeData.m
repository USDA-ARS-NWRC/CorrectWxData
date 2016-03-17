function metadata = organizeData(data, times, metadata, h)
% origanize the data returned from the database
%
% 20160229 Scott Havens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    h = false;
end

sta = {metadata.primary_id};

% date_time = datenum(data.date_time);
date_time = data.date_time_str;
% date_time = cellstr(date_time(:,1:19));  % remove the stupid .0 that Matlab adds

timeStr = cellstr(datestr(times, 'yyyy-mm-dd HH:MM:SS'));

v = fieldnames(data);
ind = ismember(v, {'station_id', 'date_time', 'date_time_str'});
v(ind) = [];

vd = ['date_time'; v(:)];

staind = zeros(size(sta));
for n = 1:length(sta)
    
    d = cell2struct(cell(size(vd)), vd, 1);
    
    % get the station
    ind = strcmp(sta{n}, data.station_id);
    
    if sum(ind) > 0
        
        try
            % parse out the data to metadata structure
            dt = date_time(ind);
            timeIdx = ismember(timeStr,dt);
            d.date_time = times;
            for k = 1:length(v)
                d.(v{k}) = NaN(length(times),1);
                d.(v{k})(timeIdx) = data.(v{k})(ind);
            end
            
            metadata(n).data = d;
        catch ME
            warndlg(sprintf('Error loading station %s',sta{n}));
            staind(n) = 1;
        end
    else
        staind(n) = 1;
    end
    
    if h
        waitbar(n/length(sta), h);
    end
end
metadata(logical(staind)) = [];
