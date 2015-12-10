function [station_ind,variable_ind] = getStationVariables(handles)
% Returns the selected stations and variables
% 20150316 Scott Havens

% stations to save
station_ind = get(handles.StationList,'Value');

% VariableMenu to save
variable_ind = get(handles.variableList,'Value');

% correct the station list
sind = find(any(handles.StationVariables(variable_ind,:),1));
station_ind = sind(station_ind);