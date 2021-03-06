function varargout = CorrectWxData(varargin)
% CORRECTWXDATA MATLAB code for CorrectWxData.fig
%      CORRECTWXDATA, by itself, creates a new CORRECTWXDATA or raises the existing
%      singleton*.
%
%      H = CORRECTWXDATA returns the handles to a new CORRECTWXDATA or the handles to
%      the existing singleton*.
%
%      CORRECTWXDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CORRECTWXDATA.M with the given input arguments.
%
%      CORRECTWXDATA('Property','Value',...) creates a new CORRECTWXDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CorrectWxData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CorrectWxData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIhandles

% Edit the above text to modify the response to help CorrectWxData

% Last Modified by GUIDE v2.5 20-Sep-2016 14:56:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CorrectWxData_OpeningFcn, ...
    'gui_OutputFcn',  @CorrectWxData_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CorrectWxData is made visible.
function CorrectWxData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handles to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CorrectWxData (see VARARGIN)

if isempty(varargin)
    error('Must specifiy configuration file!')
end

% parse the configuration file
ini = IniConfig();
ini.ReadFile(varargin{1});
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

% load the variables
handles.variables = strtrim(regexp(config.variables.var, ',', 'split'));
set(handles.variableList, 'String', handles.variables)

% load the dem
if isfield(config.dem,'fileName')
    d = readASCII(config.dem.fileName, ' ', 6);
    d.y = fliplr(d.y);
    fieldNames = fieldnames(d);
    for i = 1:size(fieldNames,1)
        config.dem.(fieldNames{i}) = d.(fieldNames{i});
    end
end

handles.config = config;

% Choose default command line output for CorrectWxData
handles.output = hObject;

% set some defaults
handles.MaxValue = NaN;
handles.MinValue = NaN;
handles.noDataValue = NaN;
handles.offsetValue = NaN;
handles.maxGapValue = 0;

% filtering default values
handles.smoothn.smoothingParameterValue = 0.5;
handles.smoothn.TolZValue = 1e-3;
handles.smoothn.MaxIterValue = 100;
handles.smoothn.WeightValue = 'bisquare';
handles.smoothn.RobustValue = 0;
handles.medfilt.FilterOrderValue = 3;

% precip correction factors
handles.precip.bucketDump = 6.25;
handles.precip.recharge = 25;
handles.precip.noise = 2.5;
handles.precip.noData = -6999;
handles.precip.outputInterval = 'same';
handles.precip.interp = 0;

% radiation calculations
handles.radiation.tau = 0.4;
handles.radiation.scale = 1;
handles.radiation.zone = 0;
handles.radiation.slope = 0;
handles.radiation.aspect = 0;
handles.radiation.um = 0.28;
handles.radiation.um2 = 2.8;
handles.radiation.omega = 0.85;
handles.radiation.g = 0.3;
handles.radiation.R0 = 0.5;
handles.radiation.d = false;
handles.radiation.cfTimeStep = 1;
handles.radiation.keep_plot = 0;
handles.clear_sky = [];


% plot the map
if isfield(config.dem,'data')
    imagesc(config.dem.x, config.dem.y, config.dem.data,...
        'Parent', handles.mapAxes)
    hold(handles.mapAxes, 'on')
    axis(handles.mapAxes,'equal','tight')
    set(handles.mapAxes,'XTickLabel',[],...
        'YTickLabel',[],...
        'YDir','normal')
end
handles.StationPlot = [];

% plotPanel axes
handles.plotAxes = [];
handles.brushObject = brush;

for n = 1:length(handles.variables)
    handles.DiffButton.(handles.variables{n}) = 0;
end
handles.DiffButton.vapor_pressure = 0;
handles.DiffButton.dew_point_temperature = 0;
handles.DiffButton.cloud_factor = 0;

handles.splitVariables = struct('variable', [], 'u', [], 'v', []);

handles.saveVariables = [];

% Update handles structure
guidata(hObject, handles);

% call the database
if isfield(config,'database')
    Menu_LoadData_Database_Callback(hObject, eventdata, handles)
end

% UIWAIT makes CorrectWxData wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CorrectWxData_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handles to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in variableList.
function variableList_Callback(hObject, eventdata, handles)
% hObject    handle to variableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns variableList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from variableList

handles = guidata(hObject);

[station_ind,variable_ind] = getStationVariables(handles);

% get the selected variable
val = get(hObject,'Value');
handles.variable_ind = val;

% get the stations
sta = handles.stations(station_ind);

% update the station list
% handles.StationList.Value = 1;
StationList = createStationList(handles);
set(handles.StationList,'String',StationList);

% try to set the same stations if possible
ind = find(ismember(StationList, sta));
handles.StationList.Value = ind;

% plot the stations on the map
handles = UpdateMap(handles);

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function variableList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in StationList.
function StationList_Callback(hObject, eventdata, handles)
% hObject    handles to StationList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StationList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StationList

% plot the stations on the map
handles = UpdateMap(handles);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function StationList_CreateFcn(hObject, eventdata, handles)
% hObject    handles to StationList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Menu_LoadData_Callback(hObject, eventdata, handles)
% hObject    handles to Menu_LoadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function editDbParameters_Callback(hObject, eventdata, handles)
% hObject    handle to editDbParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Menu_LoadData_Database_Callback(hObject, eventdata, handles)
% hObject    handles to Menu_LoadData_Database (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Call the database access script that ouputs the query into a structure
% named "data" and "vars" to the workspace
results = CallDatabase(handles);

if isstruct(results)
    
    % store the results in handles
    handles.originalData = results;
    handles.workingData = results;
    handles.savedData = results;
    for n = 1:length(handles.savedData)
        handles.savedData(n).data = [];
    end
    
    % get the stations that have data for each variables
    handles.StationVariables = struct([]);
    for n = 1:length(handles.variables)
        handles.StationVariables(1).(handles.variables{n}) = cell(0);
        for k = 1:length(results)
            ind = sum(isnan(results(k).data.(handles.variables{n}))) ~= length(results(k).data.date_time);
            if ind
                handles.StationVariables.(handles.variables{n}){end+1,1} = results(k).primary_id;
            end
        end
        
    end
    
    handles.stations = {results.primary_id}';
    
    %%% load the stations into the list %%%
    StationList = createStationList(handles);
    set(handles.StationList,'String',StationList);
    % set(handles.StationList,'Value',1)
    % handles.station_ind = 1;
    
    % plot the stations on the map
    handles = UpdateMap(handles);
    
    % save the data
    guidata(hObject,handles);
    
    
    
    % plot the first station, first variable
    %     UpdatePlot_Callback(handles.UpdatePlot,eventdata,handles);
    
end

function handles = UpdateMap(handles)
% 20151209 Scott Havens
%
% Plot the stations on the map

% get the current list of stations
StationList = createStationList(handles);

% check if there has been a plot before and remove old staitons
if ~isempty(handles.StationPlot)
    delete(handles.StationPlot)
end

hold(handles.mapAxes,'on')

for n = 1:length(StationList)
    
    % index into the main data struct
    ind = strcmp(StationList{n}, handles.stations);
    
    if ismember(n, handles.StationList.Value)
        markerFaceColor = 'r';
        markerSize = 10;
    else
        markerFaceColor = 'none';
        markerSize = 6;
    end
    
    try
        p(n) = plot(handles.mapAxes, handles.originalData(ind).X, handles.originalData(ind).Y,...
            'ro', 'MarkerFaceColor', markerFaceColor,...
            'MarkerSize', markerSize,...
            'Tag',handles.originalData(ind).primary_id);
    catch ME
        keyboard
    end
end

handles.StationPlot = p;

% hold(handles.mapAxes,'off')



% --- Executes on button press in UpdatePlot.
function UpdatePlot_Callback(hObject, eventdata, handles)
% hObject    handles to UpdatePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%% DETERMINE THE STATION AND VARIABLES TO PLOT %%%
[station_ind,variable_ind] = getStationVariables(handles);
stations = handles.stations;
vars = handles.variables(variable_ind);

%%% PLOT THE VARIABLES AND STATIONS %%%

% check to see toggle button status
% if ~isempty(handles.DiffButton)
%    for n = 1:length(handles.DiffButton)
%        value(n) = get(handles.DiffButton(n),'Value');
%    end
%    value(n:length(variable_ind)) = 0;
% else
%     value(length(variable_ind),1) = 0;
% end

% check to see if radiation is plotted and clear sky is desired
clear_flag = false;
if sum(strcmp('solar_radiation', vars)) && handles.radiation.keep_plot
    clear_flag = true;
end

% remove and create the axes
delete(handles.plotPanel.Children)
sp = tight_subplot2(handles.plotPanel, length(variable_ind), 1, 0.02, 0.05, 0.08);

btn_hgt = 0.05;
gap = 1.05;

for v = 1:length(variable_ind)
    
    hold(sp(v), 'on')
    set(sp(v), 'Tag', vars{v})  % add a tag to know what we are plotting
    
    % create the buttons
    pos = get(sp(v),'Position');
    handles.CorrectButton(v) = uicontrol(handles.plotPanel, 'Style', 'pushbutton', ...
        'String', 'Correct',...
        'Units', 'normal',....
        'Position', [0.01 pos(2)+pos(4)*1/4+3*gap*btn_hgt 0.05 btn_hgt],...
        'Callback', {@correctDataButton_Callback, vars{v}});
    handles.SaveButton(v) = uicontrol(handles.plotPanel, 'Style', 'pushbutton', ...
        'String', 'Save',...
        'Units', 'normal',....
        'Position', [0.01 pos(2)+pos(4)*1/4+2*gap*btn_hgt 0.05 btn_hgt],...
        'Callback', {@saveDataButton_Callback, vars{v}});
    handles.ResetButton(v) = uicontrol(handles.plotPanel, 'Style', 'pushbutton', ...
        'String', 'Reset',...
        'Units', 'normal',....
        'Position', [0.01 pos(2)+pos(4)*1/4+1*gap*btn_hgt 0.05 btn_hgt],...
        'Callback', {@resetWorkingDataButton_Callback, vars{v}});
    uicontrol(handles.plotPanel, 'Style', 'togglebutton', ...
        'String', 'Diff',...
        'Units', 'normal',...
        'Value', handles.DiffButton.(vars{v}),...
        'Position', [0.01 pos(2)+pos(4)*1/4 0.05 btn_hgt],...
        'Callback', {@diffWorkingDataButton_Callback, vars{v}});
    
    
    % get the colors
    nStations = length(station_ind);
    colors = lines(nStations);
    set(gca, 'ColorOrder', colors)
    
    % clear sky
    if clear_flag && strcmp('solar_radiation', vars{v})
        plot(sp(v), handles.workingData(station_ind(1)).data.date_time, ...
            handles.clear_sky, 'k--');
    end
    
    % pull out all stations with data
    pl = NaN(3,length(station_ind));
    for k = 1:length(station_ind)
        
        % check to see if the station has any data to plot
        flag = ismember(stations{station_ind(k)}, handles.StationVariables.(vars{v}));
        %         flag = any(strcmp(vars{v}, handles.StationVariables.(stations{station_ind(k)})));
        
        % plot the original data
        if handles.OriginalDataCheck.Value && flag
            pl(1,k) = plot(sp(v), handles.originalData(station_ind(k)).data.date_time, ...
                handles.originalData(station_ind(k)).data.(vars{v}),'o--',...
                'color',colors(k,:));
            set(pl(1,k), 'Tag', 'originalData')
        end
        
        % plot the working data
        if handles.WorkingDataCheck.Value && flag
            pl(2,k) = plot(sp(v), handles.workingData(station_ind(k)).data.date_time, ...
                handles.workingData(station_ind(k)).data.(vars{v}),'-',...
                'color',colors(k,:));
            set(pl(2,k), 'Tag', 'workingData')
        end
        
        % plot the saved data
        if handles.SavedDataCheck.Value && flag && isfield(handles.savedData(station_ind(k)).data, vars(v))
            
            pl(3,k) = plot(sp(v), handles.savedData(station_ind(k)).data.date_time, ...
                handles.savedData(station_ind(k)).data.(vars{v}),'-',...
                'Linewidth',2,...
                'color',colors(k,:));
            set(pl(3,k), 'Tag', 'savedData')
        end
        
    end
    
    axis(sp(v), 'tight')
    
    % fix the x axis
    if v == length(variable_ind)
        datetick(sp(v), 'x','mm-dd-yy','keeplimits','keepticks')
    else
        set(sp(v),'XTickLabel',[])
    end
    
    % fix the y axis
    set(sp(v),'YAxisLocation','right',...
        'Fontsize',14,...
        'Fontweight','bold')
    yl = ylabel(sp(v), handles.variables{variable_ind(v)});
    set(yl,'interpreter','none')
    
    pl(sum(isnan(pl),2) == size(pl,2),:) = [];   % remove rows with all nan
    
    if ~isempty(pl)
        % variable selected, one station, but no data
        pl = pl(end,:);
        pind = ~isnan(pl);
        legend(sp(v), pl(pind), handles.stations(station_ind(pind)),...
            'Location','NorthwestOutside')
    end
    
    xl(v,:) = get(sp(v), 'XLim');
    %     set(sp(v),'YTickLabel',get(sp(v),'YTick'))
    
    
    if strcmp(vars{v}, 'air_temp')
        plot(sp(v), xl(v,:), [0 0], 'k--')
    end
    
end

linkaxes(sp,'x')

% remove some emply plots
xl(xl < 10) = NaN;

for k = 1:length(sp)
    set(sp(k), 'XLim', [nanmin(xl(:,1)) nanmax(xl(:,2))],...
        'YTickLabelMode','auto',...
        'YTickMode','auto')
end

handles.plotAxes = sp;

% save the data
guidata(hObject,handles);




function [StationList,ind] = createStationList(handles)
% create the station list based on the variable_ind

% variables selected
variable_ind = get(handles.variableList,'Value');

ind = zeros(length(handles.stations), length(variable_ind));
% for n = 1:length(handles.stations)
%     ind(n,:) = ismember(handles.variables(variable_ind), handles.StationVariables.(handles.stations{n}));
% end
v = {};
for n = 1:length(variable_ind)
    v = vertcat(v, handles.StationVariables.((handles.variables{variable_ind(n)})));
end
v = unique(v);

ind = ismember(handles.stations, v);

% ind = logical(sum(ind,2));

StationList = handles.stations(ind);


% --- Executes on button press in OriginalDataCheck.
function OriginalDataCheck_Callback(hObject, eventdata, handles)
% hObject    handle to OriginalDataCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OriginalDataCheck


% --- Executes on button press in WorkingDataCheck.
function WorkingDataCheck_Callback(hObject, eventdata, handles)
% hObject    handle to WorkingDataCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WorkingDataCheck


% --- Executes on button press in showBadValues.
function showBadValues_Callback(hObject, eventdata, handles)
% hObject    handle to showBadValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showBadValues



function valueMax_Callback(hObject, eventdata, handles)
% hObject    handle to valueMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of valueMax as text
%        str2double(get(hObject,'String')) returns contents of valueMax as a double

val = str2double(get(hObject,'String')); %get the value

handles.MaxValue = val;

if isnan(val)
    set(hObject,'String','Max')
end

% save the data
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function valueMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valueMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function valueMin_Callback(hObject, eventdata, handles)
% hObject    handle to valueMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of valueMin as text
%        str2double(get(hObject,'String')) returns contents of valueMin as a double

val = str2double(get(hObject,'String')); %get the value

handles.MinValue = val;

if isnan(val)
    set(hObject,'String','Min')
end

% save the data
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function valueMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valueMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SavedDataCheck.
function SavedDataCheck_Callback(hObject, eventdata, handles)
% hObject    handle to SavedDataCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SavedDataCheck

% --- Executes on button press in correctDataButton.
function correctDataButton_Callback(hObject, eventdata, variable)
% hObject    handle to correctDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This performs the correction for the currently selected variable

handles = guidata(hObject);

% calls the correcting functions
if get(handles.PrecipCorrectionCheck,'Value')
    [station_ind,variable_ind] = getStationVariables(handles);
    
    for n = 1:length(station_ind)
        CumPPT(:,n) = handles.workingData(station_ind(n)).data.precip_accum;
    end
    date = handles.workingData(station_ind(1)).data.date_time;
    
    % if we need to linear interpolate missing data
    if handles.precip.interp
        for n = 1:length(station_ind)
            ind = ~isnan(CumPPT(:,n));
            d = date(ind);
            
            c = interp1(d, CumPPT(ind,n), date, 'linear');
            CumPPT(:,n) = c;
        end
    end
    
    
    
    CumPPT(isnan(CumPPT)) = handles.precip.noData;
    M = size(CumPPT,2);
    
    bucketDump = handles.precip.bucketDump*ones(1,M);
    recharge = handles.precip.recharge*ones(1,M);
    noise = handles.precip.noise*ones(1,M);
    noData = handles.precip.noData*ones(1,M);
    outputInterval = handles.precip.outputInterval;
    
    
    
    % correct the data and store
    precip_corr = correctPrecipitation(date,CumPPT,bucketDump,recharge,noise,noData,outputInterval);
    
    for n = 1:length(station_ind)
        handles.workingData(station_ind(n)).data.precip_accum = precip_corr(:,n);
    end
    
else
    
    handles = correctData(handles, variable);4
end

guidata(hObject,handles);

UpdatePlot_Callback(handles.UpdatePlot, eventdata, handles);

% --- Executes on button press in saveDataButton.
function saveDataButton_Callback(hObject, eventdata, variable)
% hObject    handle to saveDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);

[station_ind,variable_ind] = getStationVariables(handles);

if isempty(handles.saveVariables)
    handles.saveVariables{1} = variable;
elseif sum(ismember(handles.saveVariables, variable)) == 0
    handles.saveVariables{end+1} = variable;
end

for n = 1:length(station_ind)
    handles.savedData(station_ind(n)).data.date_time = handles.workingData(station_ind(n)).data.date_time;
    handles.savedData(station_ind(n)).data.(variable) = handles.workingData(station_ind(n)).data.(variable);
end

guidata(hObject,handles);



function noDataValue_Callback(hObject, eventdata, handles)
% hObject    handle to noDataValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noDataValue as text
%        str2double(get(hObject,'String')) returns contents of noDataValue as a double

handles.noDataValue = str2double(get(hObject,'String'));

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function noDataValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noDataValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resetWorkingDataButton.
function resetWorkingDataButton_Callback(hObject, eventdata, variable)
% hObject    handle to resetWorkingDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('Are you sure you want to clear the current working data for these stations?', ...
    'Clear Working Data', ...
    'Yes','No','No');

handles = guidata(hObject);

if strcmp(choice,'Yes')
    [station_ind,variable_ind] = getStationVariables(handles);
    for n = 1:length(station_ind)
        handles.workingData(station_ind(n)).data.(variable) =  handles.originalData(station_ind(n)).data.(variable);
    end
    %     handles.workingData(:,station_ind,variable_ind) = handles.originalData(:,station_ind,variable_ind);
end

guidata(hObject,handles);

% update the plot automatically
UpdatePlot_Callback(handles.UpdatePlot, eventdata, handles);


% --- Executes on button press in diffWorkingDataButton.
function diffWorkingDataButton_Callback(hObject, eventdata, variable)
% hObject    handle to resetWorkingDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
[station_ind,variable_ind] = getStationVariables(handles);

if hObject.Value
    
    for n = 1:length(station_ind)
        nans(n) = sum(isnan(handles.workingData(station_ind(n)).data.(variable)));
    end
    if sum(nans) > 0
        %         warndlg('NaNs are present in the data and undoing diff may have unindended concequences.')
        choice = questdlg('NaNs are present in the data and undoing diff may have unindended concequences.', ...
            'Diff', ...
            'Continue','Cancel','Cancel');
        if strcmp(choice,'Cancel')
            hObject.Value = 0;
            return;
        end
    end
    
    for n = 1:length(station_ind)
        %         a = handles.workingData(station_ind(n)).data.(variable);
        handles.workingData(station_ind(n)).data.(variable) =  ...
            [handles.workingData(station_ind(n)).data.(variable)(1); diff(handles.workingData(station_ind(n)).data.(variable))];
    end
else
    for n = 1:length(station_ind)
        handles.workingData(station_ind(n)).data.(variable) = ...
            nancumsum(handles.workingData(station_ind(n)).data.(variable),[],2);
    end
end

handles.DiffButton.(variable) = hObject.Value;

guidata(hObject,handles);

% update the plot automatically
UpdatePlot_Callback(handles.UpdatePlot, eventdata, handles);


function offsetValueInput_Callback(hObject, eventdata, handles)
% hObject    handle to offsetValueInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of offsetValueInput as text
%        str2double(get(hObject,'String')) returns contents of offsetValueInput as a double

val = str2double(get(hObject,'String')); %get the value

handles.offsetValue = val;

if isnan(val)
    set(hObject,'String','Offset')
end

% save the data
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function offsetValueInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offsetValueInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Menu_Filtering_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Filtering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Menu_Filtering_Smoothn_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Filtering_Smoothn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the options
output = smoothnOptions(handles.smoothn);

if isstruct(output)
    
    handles.smoothn.smoothingParameterValue = output.smoothingParameterValue;
    handles.smoothn.TolZValue = output.TolZValue;
    handles.smoothn.MaxIterValue = output.MaxIterValue;
    handles.smoothn.WeightValue = output.WeightValue;
    handles.smoothn.RobustValue = output.RobustValue;
    
end

guidata(hObject,handles);

% --------------------------------------------------------------------
function Menu_Filtering_MedianFilter_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Filtering_MedianFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x = inputdlg('Enter median filter order number ',...
    'Medfilt1', [1 50]);
data = str2num(x{:});

handles.medfilt.FilterOrderValue = data;

guidata(hObject,handles);

function maxGapValueInput_Callback(hObject, eventdata, handles)
% hObject    handle to maxGapValueInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxGapValueInput as text
%        str2double(get(hObject,'String')) returns contents of maxGapValueInput as a double

val = str2double(get(hObject,'String')); %get the value

handles.maxGapValue = val;

if isnan(val)
    set(hObject,'String','0')
end

% save the data
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function maxGapValueInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxGapValueInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PrecipCorrectionCheck.
function PrecipCorrectionCheck_Callback(hObject, eventdata, handles)
% hObject    handle to PrecipCorrectionCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PrecipCorrectionCheck



% --------------------------------------------------------------------
function brushTool_OnCallback(hObject, eventdata, handles)
% hObject    handle to brushTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

display('brush on')

% if handles.OriginalDataCheck.Value || handles.SavedDataCheck.Value
%     
%     hObject.State = 'off';
%     errordlg('Cannot use brush when original or saved data is plotted')
%     
% else

% turn on the brush tool
h = brush(handles.figure1);
set(h, 'Enable', 'on')
handles.brushObject = h;
    
% end

% save the data
guidata(hObject,handles);

% --------------------------------------------------------------------
function brushTool_OffCallback(hObject, eventdata, handles)
% hObject    handle to brushTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

display('brush off')

set(handles.brushObject, 'Enable', 'off')

% get the data that was affected
% go through all the axes and get the data

%%% DETERMINE THE STATION AND VARIABLES TO PLOT %%%
[station_ind,variable_ind] = getStationVariables(handles);
vars = handles.variables(variable_ind);

for n = 1:length(handles.plotAxes)
    
    % determine what variable it is
    h = get(handles.plotAxes(n));
    v = h.Tag;
    
    for m = 1:length(h.Children)
        
        if strcmp(h.Children(m).Tag, 'workingData')
            
            % determine the station since they may not line up
            sta_name = h.Children(m).DisplayName;
            stind = strcmp(sta_name, handles.stations);
            
            % have to make sure that 'remove points' will work
            ind = ismember(handles.workingData(stind).data.date_time, h.Children(m).XData);
            handles.workingData(stind).data.(v) = NaN(size(ind));
            
            handles.workingData(stind).data.(v)(ind) = h.Children(m).YData;
        end
    end
    
end

% save the data
guidata(hObject,handles);



% --------------------------------------------------------------------
function Menu_Filtering_Precipitation_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Filtering_Precipitation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% get the options
output = precipitationOptions(handles.precip);

if isstruct(output)
    
    % precip correction factors
    handles.precip.bucketDump = output.bucketDump;
    handles.precip.recharge = output.recharge;
    handles.precip.noise = output.noise;
    handles.precip.noData = output.noData;
    handles.precip.outputInterval = 'same';
    handles.precip.interp = output.interp;
    
end

guidata(hObject,handles);

% --------------------------------------------------------------------
function Menu_SaveData_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_SaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Menu_SaveData_Database_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_SaveData_Database (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

result = SaveDatabase(handles);

if result == 0
    errordlg('Error saving data to database')
end

% --------------------------------------------------------------------
function Menu_SaveData_matFile_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_SaveData_matFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uiputfile('CorrectedData.mat','Save MAT File');

f = fullfile(pathname,filename);

% remove any stations with all NaN's
[dtime, sData, stations, vars] = minimizeData(handles.savedData, ...
    handles.stations, handles.saveVariables);

% remove any stations with all NaN's
% [sData,stations,vars] = minimizeData(sData,stations,vars);

% save the data
save(f,'sData','stations','vars','dtime')


% --------------------------------------------------------------------
function Menu_SaveData_csvFile_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_SaveData_csvFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


pathname = uigetdir(pwd,'Save CSV''s to Directory ');

% remove any stations with all NaN's
[dtime, sData, stations, vars] = minimizeData(handles.savedData, ...
    handles.stations, handles.saveVariables);

% write a file for each variable
hdr = ['date_time' stations(:)'];
hdr = strjoin(hdr,',');
sData(isnan(sData)) = -9999;

for n = 1:length(vars)
    
    % open the file
    f = fullfile(pathname,['CorrectedData.' vars{n} '.csv']);
    fid = fopen(f,'w');
    
    % write the header row
    fwrite(fid,sprintf('%s\n',hdr));
    
    % write the data
    for k = 1:size(sData,1)
        line = sData(k,:,n);
        line = cellstr(num2str(line(:)))';  % convert numbers to strings
        
        dt = datestr(dtime(k),'yyyy-mm-dd HH:MM');
        
        % add date and commas
        line = strtrim([dt line]);
        line = strjoin(line,',');
        
        fprintf(fid,'%s\n',line);
        
    end
    
    fclose(fid);
end

% --------------------------------------------------------------------
function Menu_Calculate_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Menu_Calculate_DewPoint_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Calculate_DewPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% must have something plotted
if ~isempty(handles.plotAxes)
    
    [station_ind,variable_ind] = getStationVariables(handles);
    
    if sum(ismember(handles.variables(variable_ind),{'vapor_pressure'})) ~= 1
        errordlg('Error: vapor_pressure must be loaded/calculated first')
        return;
    end
    
    % check to see if the vapor pressure is variable
    if ~strcmp('dew_point_temperature',handles.variables)
        % have to create a new working data and add to the  variable
        % to the variable list
        
        for n = 1:length(handles.stations)
            handles.originalData(n).data.dew_point_temperature = ...
                NaN(size( handles.workingData(n).data.date_time));
            handles.workingData(n).data.dew_point_temperature = ...
                NaN(size( handles.workingData(n).data.date_time));
        end
        
        % add to the variable to the variable list
        handles.variables = [handles.variables 'dew_point_temperature'];
        val = handles.variableList.Value;
        val(end+1) = length(handles.variables);
        handles.variableList.String = handles.variables;
        handles.variableList.Value = val;
        
        %         ind = ismember(handles.variables,{'vapor_pressure'});
        %         handles.StationVariables(end+1,:) = handles.StationVariables(ind,:);
        
    elseif sum(strcmp('dew_point_temperature',handles.variables(variable_ind))) == 0
        % vapor_pressure is not selected
        val = handles.variableList.Value;
        val(end+1) = find(strcmp(handles.variables,'dew_point_temperature'));
        handles.variableList.Value = sort(val);
        
    end
    
    % calculate the dew_point_temperature
    f = {'originalData','workingData'};
    % add the dew_point_temperature to the StationVariables if not
    % already there
    %                 if any(strcmp('dew_point_temperature', handles.StationVariables.(handles.stations{station_ind(n)}))) == 0
    if ~any(strcmp('dew_point_temperature', fieldnames(handles.StationVariables)))
        %                     handles.StationVariables.(handles.stations{station_ind(n)}){end + 1} = 'dew_point_temperature';
        handles.StationVariables.dew_point_temperature = cell(0);
    end
    for n = 1:length(station_ind)
        for k = 1:2
            
            vp = handles.(f{k})(station_ind(n)).data.vapor_pressure;
            
            if sum(isnan(vp)) ~= length(vp)
                ind = isnan(vp);
                vp(ind) = 300;
                dpt = dewpt(vp);
                dpt(ind) = NaN;
                handles.(f{k})(station_ind(n)).data.dew_point_temperature = dpt;
                
                handles.StationVariables.dew_point_temperature{end+1} = handles.stations{station_ind(n)};
                
            end
        end
    end
    handles.StationVariables.dew_point_temperature = unique(handles.StationVariables.dew_point_temperature);
    
    % ensure that workingData is selected
    handles.WorkingDataCheck.Value = 1;
    
    guidata(hObject,handles);
    
    % update the plot
    UpdatePlot_Callback(handles.UpdatePlot, eventdata, handles);
    
else
    warndlg('Must calculate and plot vapor_pressure first')
end

% --------------------------------------------------------------------
function Menu_Calculate_VaporPressure_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Calculate_VaporPressure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% must have something plotted
if ~isempty(handles.plotAxes)
    
    [station_ind,variable_ind] = getStationVariables(handles);
    
    if sum(ismember(handles.variables(variable_ind),{'air_temp','relative_humidity'})) ~= 2
        errordlg('Error: air_temp and relative_humidity must be loaded')
        return;
    end
    
    % check to see if the vapor pressure is variable
    if ~strcmp('vapor_pressure',handles.variables)
        % have to create a new working data and add to the  variable
        % to the variable list
        
        for n = 1:length(handles.stations)
            handles.originalData(n).data.vapor_pressure = ...
                NaN(size( handles.workingData(n).data.date_time));
            handles.workingData(n).data.vapor_pressure = ...
                NaN(size( handles.workingData(n).data.date_time));
        end
        
        % add to the variable to the variable list
        handles.variables = [handles.variables 'vapor_pressure'];
        val = handles.variableList.Value;
        val(end+1) = length(handles.variables);
        handles.variableList.String = handles.variables;
        handles.variableList.Value = val;
        
        % see if the station has air_temp and relative_humidity and add the
        % vapor_pressure
        %         for n = 1:length(station_ind)
        %             ind = ismember({'air_temp','relative_humidity'}, handles.StationVariables.(handles.stations{station_ind(n)}));
        %             if sum(ind) == 2
        %                 handles.StationVariables.(handles.stations{station_ind(n)}){end + 1} = 'vapor_pressure';
        %             end
        %         end
        
    elseif sum(strcmp('vapor_pressure',handles.variables(variable_ind))) == 0
        % vapor_pressure is not selected
        val = handles.variableList.Value;
        val(end+1) = find(strcmp(handles.variables,'vapor_pressure'));
        handles.variableList.Value = sort(val);
        
    end
    
    % calculate the vapor pressure
    f = {'originalData','workingData'};
    % add the vapor_pressure to the StationVariables if not
    % already there
    %                 if any(strcmp('vapor_pressure', handles.StationVariables.(handles.stations{station_ind(n)}))) == 0
    if ~any(strcmp('dew_point_temperature', fieldnames(handles.StationVariables)))
        %                     handles.StationVariables.(handles.stations{station_ind(n)}){end + 1} = 'vapor_pressure';
        handles.StationVariables.vapor_pressure = cell(0);
    end
    for n = 1:length(station_ind)
        
        for k = 1:2
            ta = handles.(f{k})(station_ind(n)).data.air_temp;
            rh = handles.(f{k})(station_ind(n)).data.relative_humidity;
            if nanmax(rh) > 1
                rh = rh/100;
            end
            
            if sum(isnan(rh)) ~= length(rh) && sum(isnan(ta)) ~= length(ta)
                vp = rh2vp(ta, rh);
                handles.(f{k})(station_ind(n)).data.vapor_pressure = vp;
                
                handles.StationVariables.vapor_pressure{end+1} = handles.stations{station_ind(n)};
                
            end
        end
    end
    handles.StationVariables.vapor_pressure = unique(handles.StationVariables.vapor_pressure);
    
    % ensure that workingData is selected
    handles.WorkingDataCheck.Value = 1;
    
    guidata(hObject,handles);
    
    % update the plot
    UpdatePlot_Callback(handles.UpdatePlot, eventdata, handles);
    
else
    warndlg('Must plot air_temp and relative humidity first')
end


function [dtimes,sData,stations,vars] = minimizeData(data, stations, vars)
% Take the matrix data and remove all colums with all NaN values in the 3rd
% dimension.  Return the stations and variables associated with it.


% put all the saved data into a big matrix
for n = 1:length(data)
    if ~isempty(data(n).data)
        dtimes = data(n).data.date_time;
        break
    end
end

sData = NaN(length(dtimes), length(data), length(vars));
for v = 1:length(vars)
    for s = 1:length(data)
        if isfield(data(s).data, vars{v})
            sData(:,s,v) = data(s).data.(vars{v});
        end
    end
end


nVals = size(sData,1);
variable_ind = sum(isnan(sData),1) ~= nVals;
station_ind = sum(variable_ind,3) ~= 0;
variable_ind = sum(variable_ind,2) ~= 0;

sData = sData(:,station_ind,variable_ind);
stations = stations(station_ind);
vars = vars(variable_ind);


% --------------------------------------------------------------------
function splitComponents_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to splitComponents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% create a list dialog
[Selection,ok] = listdlg('ListString', handles.variables,...
    'SelectionMode', 'single',...
    'Name', 'Variable component',...
    'PromptString', 'Select variable to split into components',...
    'ListSize',[300 150]);

if ok == 1
    
    % the variable selected
    var = handles.variables{Selection};
    
    % check to see if it's already been split
    if sum(strcmp(var, handles.splitVariables.variable)) >= 1
        errordlg('Variable already has been split')
        return
    else
        
        % add to the structure to track what's being split
        c = {[var '_u'], [var '_v']};
        vs = struct('variable', var, 'u', [], 'v', []);
        vs.u = c{1};
        vs.v = c{2};
        
        if isempty(handles.splitVariables(1).variable)
            handles.splitVariables = vs;
        else
            handles.splitVariables(end+1) = vs;
        end
        
        % add the variables to the list
        handles.variables = [handles.variables c];
        handles.variableList.String = handles.variables;
        
        % add the station variables
        handles.StationVariables.(c{1}) = handles.StationVariables.(var);
        handles.StationVariables.(c{2}) = handles.StationVariables.(var);
        %         for n = 1:length(handles.stations)
        %             ind = any(ismember(handles.StationVariables.(handles.stations{n}), var));
        %             if ind
        %                 handles.StationVariables.(handles.stations{n}){end+1} = c{1};
        %                 handles.StationVariables.(handles.stations{n}){end+1} = c{2};
        %             end
        %         end
        
        % add to the diff button tracker
        handles.DiffButton.(c{1}) = 0;
        handles.DiffButton.(c{2}) = 0;
        
        % now split the variables
        for n = 1:length(handles.originalData)
            
            d = handles.originalData(n).data.(var);
            v = sind(d);
            u = cosd(d);
            
            % add to the original data
            handles.originalData(n).data.(c{1}) = u;
            handles.originalData(n).data.(c{2}) = v;
            
            % add to the working data
            handles.workingData(n).data.(c{1}) = u;
            handles.workingData(n).data.(c{2}) = v;
            
        end
        
    end
    
    guidata(hObject,handles);
end

% --------------------------------------------------------------------
function unsplitComponents_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to unsplitComponents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% create a list dialog
[Selection,ok] = listdlg('ListString', {handles.splitVariables.variable},...
    'SelectionMode', 'single',...
    'Name', 'Variable combine',...
    'PromptString', 'Select variable combine from components',...
    'ListSize',[300 150]);

if ok == 1
    
    var = handles.splitVariables(Selection).variable;
    u = handles.splitVariables(Selection).u;
    v = handles.splitVariables(Selection).v;
    
    for n = 1:length(handles.workingData)
        
        az = atan2(handles.workingData(n).data.(v), handles.workingData(n).data.(u)) * 180/pi;
        az(az < 0) = az(az < 0) + 360;
        
        handles.workingData(n).data.(var) = az;
        
    end
    
    guidata(hObject,handles);
    
    % update the plot automatically
    UpdatePlot_Callback(handles.UpdatePlot, eventdata, handles);
    
end


% --------------------------------------------------------------------
function joinVariables_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to joinVariables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[Selection,ok] = listdlg('ListString', handles.variables,...
    'InitialValue', handles.variableList.Value, ...
    'SelectionMode', 'multiple',...
    'Name', 'Variable combine',...
    'PromptString', 'Select variables to join',...
    'ListSize',[300 150]);


if ok == 1
    
    % turn off the brush if on
    brush_flag = 0;
    if strcmp(handles.brushTool.State, 'on')
        brushTool_OffCallback(handles.brushTool, eventdata, handles);
        handles = guidata(hObject); % need to reload
        brush_flag = 1;
    end
    
    % get the stations that are showing
    [station_ind,variable_ind] = getStationVariables(handles);
    
    if sum(ismember(Selection, variable_ind)) ~= length(Selection)
        errordlg('The variables that will be joined must be displayed')
        return
    end
    
    if length(Selection) < 2
        errordlg('Please pick more than two variables to join');
        return
    end
    
    
    vars = handles.variables(Selection);
    stations = handles.stations;
    
    for n = 1:length(station_ind)
        
        % deteremine where all the NaN values are
        ind = zeros(size(handles.workingData(station_ind(n)).data.date_time));
        for v = 1:length(vars)
            % only record values that are at the stations
            flag = any(strcmp(stations{station_ind(n)}, handles.StationVariables.(vars{v}))); %faster
            %             flag = ismember(stations{station_ind(n)}, handles.StationVariables.(vars{v}));      %cleaner
            if flag
                ind = ind + isnan(handles.workingData(station_ind(n)).data.(vars{v}));
            end
        end
        
        ind = logical(ind);
        
        % remove all the NaN values
        for v = 1:length(vars)
            flag = any(strcmp(stations{station_ind(n)}, handles.StationVariables.(vars{v})));
            if flag
                handles.workingData(station_ind(n)).data.(vars{v})(ind) = NaN;
            end
        end
        
    end
    
    guidata(hObject,handles);
    
    % turn the bursh back on if it was
    if brush_flag
        brushTool_OnCallback(handles.brushTool, eventdata, handles);
    end
    
    % update the plot automatically
    UpdatePlot_Callback(handles.UpdatePlot, eventdata, handles);
    
    
    
end



% --------------------------------------------------------------------
function lassoTool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to lassoTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --------------------------------------------------------------------
function lassoTool_OnCallback(hObject, eventdata, handles)
% hObject    handle to lassoTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% turn brush off if it's on
brushTool_OffCallback(handles.brushTool, eventdata, handles);

% get the map axis image handle
h = findobj(handles.mapAxes, 'Type', 'image');

% have the user select some data
[pointslist,xselect,yselect] = selectdata('Axes', handles.mapAxes,...
    'Action', 'list',...
    'Ignore', h,...
    'SelectionMode', 'Rect');

% the last one should be the image data so remove
% xselect(end) = [];
% yselect(end) = [];

xselect = cell2mat(xselect);
yselect = cell2mat(yselect);

if ~isempty(xselect)
    
    %     xselect = unique(xselect);
    %     yselect = unique(yselect);
    
    [StationList,station_ind] = createStationList(handles);
    
    % have to determine the hard way which points they are
    xdata = cell2mat({handles.originalData(station_ind).X}');
    ydata = cell2mat({handles.originalData(station_ind).Y}');
    
    
    station_ind = NaN(size(xselect));
    for n = 1:length(xselect)
        % find the distance to all the points
        D = sqrt((xdata - xselect(n)).^2 + (ydata - yselect(n)).^2);
        
        % get the minimum value
        [~,I] = min(D);
        station_ind(n) = I;
    end
    station_ind = sort(station_ind);
    
    % now update the highlighted list
    handles.StationList.Value = station_ind;
    
    % plot the stations on the map
    handles = UpdateMap(handles);
    
    guidata(hObject,handles);
    
end

lassoTool_OffCallback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function lassoTool_OffCallback(hObject, eventdata, handles)
% hObject    handle to lassoTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'State', 'off')


% --------------------------------------------------------------------
function Menu_Calculate_Radiation_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Calculate_Radiation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Menu_Calculate_Radiation_Options_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Calculate_Radiation_Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open a dialog to set the options for calculating the clear sky radiation

% get the options
output = clearSkyOptions(handles.radiation);

if isstruct(output)
    
    fnames = fieldnames(output);
    for f = 1:length(fnames)
        handles.radiation.(fnames{f}) = output.(fnames{f});
    end
    
end

guidata(hObject,handles);

% --------------------------------------------------------------------
function Menu_Calculate_Radiation_ClearSky_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Calculate_Radiation_ClearSky (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% deteremine how many solar fields are plotted, as only one can be
% calculated at a time

% get the stations that are showing
[station_ind,variable_ind] = getStationVariables(handles);

if isempty(handles.plotAxes)
    errordlg('Nothing plotted, plot only one station and only solar radiation');
    return
end

if length(station_ind) > 1
    errordlg('Can only calculate clear sky radiation one station at a time');
    return
end

% if length(variable_ind) > 1
%     errordlg('Only solar radiation must be plotted.');
%     return
% end

if strcmp(handles.variables(variable_ind), 'solar_radiation') == 0
    errordlg('Solar radiation must be plotted');
    return
end

if handles.OriginalDataCheck.Value || handles.SavedDataCheck.Value
    errordlg('Can only calculate clear sky when working data is plotted')
    return
end


% % check to see if this station has a tau already
% if isfield(handles.radiation, handles.stations{station_ind})
%     tau = handle.radiation.tau;
% else
%     tau = handles.radiation.(handles.stations{station_ind});
% end

date_time = handles.workingData(station_ind).data.date_time;
lat = handles.workingData(station_ind).latitude;
lon = handles.workingData(station_ind).longitude;

clear_sky = calcClearSky(date_time, lat, lon, handles.radiation);
handles.clear_sky = clear_sky;

guidata(hObject,handles);

% plot the clear sky below the solar, use the UpdatePlot function
old_value = handles.radiation.keep_plot;
handles.radiation.keep_plot = 1;
UpdatePlot_Callback(handles.UpdatePlot, eventdata, handles);

% reset to the users value
handles = guidata(hObject);
handles.radiation.keep_plot = old_value;
guidata(hObject,handles);





% --------------------------------------------------------------------
function Menu_Calculate_Radiation_CloudFactor_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Calculate_Radiation_CloudFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the stations that are showing
[station_ind,variable_ind] = getStationVariables(handles);

if isempty(handles.plotAxes)
    errordlg('Nothing plotted, plot only one station and only solar radiation');
    return
end

if length(station_ind) > 1
    errordlg('Can only calculate clear sky radiation one station at a time');
    return
end

% if length(variable_ind) > 1
%     errordlg('Only solar radiation must be plotted.');
%     return
% end

if strcmp(handles.variables(variable_ind), 'solar_radiation') == 0
    errordlg('Solar radiation must be plotted');
    return
end

if handles.OriginalDataCheck.Value || handles.SavedDataCheck.Value
    errordlg('Can only calculate clear sky when working data is plotted')
    return
end

% get some values
date_time = handles.workingData(station_ind).data.date_time;
clear_sky = handles.clear_sky;

ind = ismember({handles.variables{variable_ind}}, 'solar_radiation');
solar = handles.workingData(station_ind).data.solar_radiation;

if sum(isnan(solar))
    warndlg('Solar radiation has NaN values and may affect cloud factor calculation')
end

cfTimeStep = handles.radiation.cfTimeStep;

% go through and get the cloud factor
% cloud_factor is measured/modeled
if cfTimeStep == 24
    % this is a special case when daily integration is desired, so we have
    % to find the local midnight to midnight values
    
    cloud_factor = NaN(size(solar));
    
    % convert to local time
    local_time = TimezoneConvert( date_time, ...
        handles.config.date_range.data_time_zone, ...
        handles.config.date_range.local_time_zone);
    
    % round and find out the days
    days = floor(local_time);
    d = unique(days);
    
    [fill,fill_value] = deal(zeros(size(cloud_factor)));
    
    for n = 1:length(d)
        
        ind = days == d(n);
        ms = trapz(solar(ind));
        md = trapz(clear_sky(ind));
        
        cloud_factor(ind) = ms/md;
        
        if sum(ind) < 5 && isnan(ms/md)
            fill(ind) = 1;
            fill_value(ind) = n+1;
        end
        
    end
    
    % fill in those that are flagged
    ind = find(fill);
    for n = 1:length(ind)
        dyind = find(days == d(fill_value(ind(n))));
        cloud_factor(ind(n)) = cloud_factor(dyind(1));
    end
    
    
elseif cfTimeStep == 1
    % another special case when it'll just be straight step by step
    % comparison
    clear_sky(clear_sky<=0) = NaN; %Flag nighttime values as NaN
    cloud_factor = solar./clear_sky; %Find ratios of measured to modeled for daytime hours
    cloud_factor(cloud_factor>1)=1;  %Cap ratios at 1.0 to remove reflection spikes
    %Flag the last measurements of each day as NaN:
    for ii=1:length(cloud_factor)
        if (ii+1)>length(cloud_factor)
            break
        end
        if isnan(cloud_factor(ii))==0 && isnan(cloud_factor(ii+1))==1
            cloud_factor(ii)=NaN;
        end
    end
    %Flag the first measurements of each day as NaN:
    for jj=length(cloud_factor):-1:1
        if (jj-1)==0
            break
        end
        if isnan(cloud_factor(jj))==0 && isnan(cloud_factor(jj-1))==1
            cloud_factor(jj)=NaN;
        end
    end
    ld=0; %Define initial "Last Daylight" value as zero.
    ldh=0; %Define initial "Last Daylight Hour" value as zero.
    output=zeros(length(cloud_factor),1); %Initialize output for speed
    for ii=1:length(cloud_factor)
        if jj>length(cloud_factor)
            break
        end
        %Determine if starting time step is at night:
        if isnan(cloud_factor(ii))==1 && ld==0
            %         if sum(isnan(cloud_atten(:)))==length(cloud_atten)
            %             break
            %         end
            jj=ii;
            %Look at the next hour:
            while isnan(cloud_factor(jj))==1 && ld==0
                if jj==length(cloud_factor)
                    break
                end
                jj=jj+1;
            end
            cloud_factor(ii)=cloud_factor(jj);
            %j=0;
            %Interpolation step between sunset and sunrise cloud covers:
        elseif isnan(cloud_factor(ii))==1 && ld>0
            jj=ii;
            while isnan(cloud_factor(jj))==1 && jj<length(cloud_factor)
                jj=jj+1;
            end
            if isnan(cloud_factor(jj))==0
                cloud_factor(ii)=(cloud_factor(jj)-ld)/(jj-ldh)*(ii-ldh)+ld;
                %This line printed to the command window is for diagnostics:
                %fprintf('i=%d j=%d cloud_atten[%d]=%.4f last_daylight=%.4f last_daylight_hour=%d cloud_atten[%d]=%.4f\n',...
                %i,j,j,cloud_atten(j),ld,ldh,i,cloud_atten(i));
            else
                cloud_factor(ii)=ld;
            end
            %Otherwise, do nothing to cloud ratio:
        else
            ld=cloud_factor(ii);
            ldh=ii;
        end
        %Store output into a new array:
        output(ii)=cloud_factor(ii);
    end
    cloud_factor = output;
    
else
    % something in between, take from the beginning of the time series and
    % go through
    
    % determine the indicies for the times
    nvals = ceil(length(solar)/cfTimeStep); % number of values that will be calculated
    v = 1:nvals;
    v = repmat(v, cfTimeStep, 1);
    v = v(:);
    v = v(1:length(solar));
    
    cloud_factor = NaN(size(solar));
    
    % loop through and integrate
    %     for n = 1:nvals
    %         ind = v == n;
    %         ms = trapz(solar(ind));
    %         md = trapz(clear_sky(ind));
    %
    %         if ms == 0 && md == 0
    %            pind = find(v == n-1);
    %            cloud_factor(ind) = cloud_factor(pind(1));
    %         else
    %             cloud_factor(ind) = ms/md;
    %         end
    %     end
    
    % do a moving window integration
    ts = floor(cfTimeStep/2);
    r = [-ts:ts];
    if length(r) > cfTimeStep
        r = r(1:cfTimeStep);
    end
    for n = 1:length(cloud_factor)
        
        ind = n + r;
        ind(ind <= 0 | ind > length(cloud_factor)) = [];
        
        ms = trapz(solar(ind));
        md = trapz(clear_sky(ind));
        
        if md == 0
            % if it's night time
            pind = n-1;
            pind(pind <= 0 | pind > length(cloud_factor)) = [];
            if isempty(pind)
                cloud_factor(n) = NaN;
            else
                cloud_factor(n) = cloud_factor(pind(1));
            end
        else
            cloud_factor(n) = ms/md;
        end
        
        
    end
    
end

% clean up a little bit
cloud_factor(isinf(cloud_factor)) = 0;
cloud_factor(cloud_factor > 1) = 1;
cloud_factor(cloud_factor < 0) = 0;

% check to see if the cloud factor is variable
if ~strcmp('cloud_factor',handles.variables)
    % have to create a new working data and add to the  variable
    % to the variable list
    
    for n = 1:length(handles.stations)
        handles.originalData(n).data.cloud_factor = ...
            NaN(size( handles.workingData(n).data.date_time));
        handles.workingData(n).data.cloud_factor = ...
            NaN(size( handles.workingData(n).data.date_time));
    end
    
    % add to the variable to the variable list
    handles.variables = [handles.variables 'cloud_factor'];
    val = handles.variableList.Value;
    val(end+1) = length(handles.variables);
    handles.variableList.String = handles.variables;
    handles.variableList.Value = val;
    
    %         ind = ismember(handles.variables,{'vapor_pressure'});
    %         handles.StationVariables(end+1,:) = handles.StationVariables(ind,:);
    
elseif sum(strcmp('cloud_factor',handles.variables(variable_ind))) == 0
    % cloud_factor is not selected
    val = handles.variableList.Value;
    val(end+1) = find(strcmp(handles.variables,'cloud_factor'));
    handles.variableList.Value = sort(val);
    
end

% add the cloud_factor to the StationVariables if not already there
% if any(strcmp('cloud_factor', handles.StationVariables.(handles.stations{station_ind}))) == 0
%     handles.StationVariables.(handles.stations{station_ind}){end + 1} = 'cloud_factor';
% end

if ~any(strcmp('cloud_factor', fieldnames(handles.StationVariables)))
    handles.StationVariables.cloud_factor = cell(0);
end

% add the cloud_factor to the station
handles.StationVariables.cloud_factor{end+1} = handles.stations{station_ind};
handles.StationVariables.cloud_factor = unique(handles.StationVariables.cloud_factor);

handles.originalData(station_ind).data.cloud_factor = cloud_factor;
handles.workingData(station_ind).data.cloud_factor = cloud_factor;

% ensure that workingData is selected
handles.WorkingDataCheck.Value = 1;

guidata(hObject,handles);

% update the plot
UpdatePlot_Callback(handles.UpdatePlot, eventdata, handles);


% --------------------------------------------------------------------
function clearSkyOptionsPush_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to clearSkyOptionsPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Menu_Calculate_Radiation_Options_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function clearSkyPush_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to clearSkyPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Menu_Calculate_Radiation_ClearSky_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function cloudFactorPush_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to cloudFactorPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Menu_Calculate_Radiation_CloudFactor_Callback(hObject, eventdata, handles)


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



switch eventdata.Key
    case 's'
        Menu_Calculate_Radiation_Options_Callback(hObject, eventdata, handles)
    case 't'
        Menu_Calculate_Radiation_ClearSky_Callback(hObject, eventdata, handles);
    case 'f'
        Menu_Calculate_Radiation_CloudFactor_Callback(hObject, eventdata, handles)
        
end





