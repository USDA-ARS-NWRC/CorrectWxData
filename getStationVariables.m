function [station_ind,variable_ind] = getStationVariables(handles)
% Returns the selected stations and variables
% 20150316 Scott Havens

% stations to save
station_ind = find(ismember(handles.stations, ...
    handles.StationList.String(handles.StationList.Value)));

% VariableMenu to save
variable_ind = get(handles.variableList,'Value');

% correct the station list
% sind = find(any(handles.StationVariables(variable_ind,:),1));
% station_ind = sind(station_ind);
% 
% ind = zeros(length(handles.stations), length(variable_ind));
% for n = 1:length(handles.stations)
%     ind(n,:) = ismember(handles.variables(variable_ind), handles.StationVariables.(handles.stations{n}));
% end
% 
% ind = logical(sum(ind,1));
% 
% StationList = handles.stations(ind);
