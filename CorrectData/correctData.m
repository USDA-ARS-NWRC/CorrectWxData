function handles = correctData(handles)

% Correct the data given the variable options. This will use the
% workingData so that continual corrections can be made
%
% 20150313 Scott Havens

% get the station and variables selected
[station_ind,variable_ind] = getStationVariables(handles);

% get the working data
data = handles.workingData(:,station_ind,variable_ind);

% the no data value
noData = handles.noDataValue;


%%% 1. CORRECT FOR MIN AND MAX VALUES %%%
if ~isnan(handles.MinValue)
    data(data < handles.MinValue) = NaN;
end

if ~isnan(handles.MaxValue)
    data(data > handles.MaxValue) = NaN;
end


%%% 2. APPLY AN OFFSET %%%
if ~isnan(handles.offsetValue)
    data = data + handles.offsetValue;
end

%%% 3. PERFORM SMOOTHING FILTERS %%%
if get(handles.noSmoothingRadio,'Value') == 0
    
    % preserve the NaN's by replacing at the end
    ind = isnan(data);
    
    
    % do smoothn filter
    if get(handles.smoothnRadio,'Value') == 1
        
        options.TolZ = handles.smoothn.TolZValue;
        options.MaxIter = handles.smoothn.MaxIterValue;
        options.Weight = handles.smoothn.WeightValue;
        
        
        if handles.smoothn.RobustValue == 1
            for s = 1:size(data,2) 
                data(:,s) = smoothn(data(:,s),'robust',options);
            end
            
        elseif ~isnan(handles.smoothn.smoothingParameterValue)
            for s = 1:size(data,2) 
                data(:,s) = smoothn(data(:,s),handles.smoothn.smoothingParameterValue,options);
            end
            
        else
            data = smoothn(data,options);
        end
        
        
        % Do medfilt1
    elseif get(handles.medianFilterRadio,'Value') == 1
        
        data = medfilt1(data,handles.medfilt.FilterOrderValue);
        
    end
    
    % add the NaN's back
    if handles.maxGapValue == Inf
        % don't replace the NaN
    elseif handles.maxGapValue ~= 0
        for n = 1:size(data,2)
            [x,xi] = deal(1:size(data,1));
            x(ind(:,n)) = [];
            
            xind = fillGaps(x,xi,handles.maxGapValue);
            data(xind,n) = NaN;
        end
    else
        data(ind) = NaN;
    end
    
end

% set all the NaN to noDataValue
data(isnan(data)) = noData;

% save data back in the working data
handles.workingData(:,station_ind,variable_ind) = data;



function ind_int = fillGaps(x,xq,maxgapval)

% Given the x (index) of values with data, fill the data with NaN if the gap
% is larger than maxgapval

x = x(:);
xq = xq(:);

% Find indices of gaps in x larger than maxgapval:
x_gap = diff(x);
ind = find(abs(x_gap) > maxgapval);

% Preallocate array which will hold vq indices corresponding to large gaps in x data:
ind_int = [];

% For each gap, find corresponding xq indices:
for N = 1:length(ind)
    
    ind_int = [ind_int; find((xq>x(ind(N)) & xq<x(ind(N)+1)))];
    
end
