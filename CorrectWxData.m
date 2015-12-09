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

% Last Modified by GUIDE v2.5 09-Dec-2015 08:50:37

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

% get the selected variable
val = get(hObject,'Value');
handles.variable_ind = val;

% update the station list
handles.StationList.Value = 1;
StationList = createStationList(handles);
set(handles.StationList,'String',StationList);

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
    handles.savedData = cell2struct(cell(size(fieldnames(results))),fieldnames(results),1);
    
    % get the stations that have data for each variables
    ind = zeros(length(handles.variables),length(results));
    for n = 1:length(handles.variables)
        for k = 1:length(results)
            ind(n,k) = sum(isnan(results(k).data.(handles.variables{n}))) ~= length(results(k).data.date_time);
        end
    end
    handles.StationVariables = ind;
    
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
    
    p(n) = plot(handles.mapAxes, handles.originalData(ind).X, handles.originalData(ind).Y,...
        'ro', 'MarkerFaceColor', markerFaceColor,...
        'MarkerSize', markerSize);
    
end

handles.StationPlot = p;



% --- Executes on button press in UpdatePlot.
function UpdatePlot_Callback(hObject, eventdata, handles)
% hObject    handles to UpdatePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%% DETERMINE THE STATION AND VARIABLES TO PLOT %%%
[station_ind,variable_ind] = getStationVariables(handles);
vars = handles.variables(variable_ind);

%%% PLOT THE VARIABLES AND STATIONS %%%

% remove and create the axes
delete(handles.plotPanel.Children)
sp = tight_subplot2(handles.plotPanel, length(variable_ind),1);

for v = 1:length(variable_ind)
    
    hold(sp(v), 'on')
    
    % get the colors
    nStations = length(station_ind);
    colors = lines(nStations);
    set(gca, 'ColorOrder', colors)
    
    % pull out all stations with data
    pl = NaN(3,length(station_ind));
    for k = 1:length(station_ind)
        
        % plot the original data
        if handles.OriginalDataCheck.Value && handles.StationVariables(variable_ind(v),station_ind(k))
            pl(1,k) = plot(sp(v), handles.originalData(station_ind(k)).data.date_time, ...
                handles.originalData(station_ind(k)).data.(vars{v}),'--',...
                'color',colors(k,:));
        end
        
        % plot the working data
        if handles.WorkingDataCheck.Value && handles.StationVariables(variable_ind(v),station_ind(k))
            pl(2,k) = plot(sp(v), handles.workingData(station_ind(k)).data.date_time, ...
                handles.workingData(station_ind(k)).data.(vars{v}),'-',...
                'color',colors(k,:));
        end
        
        % plot the working data
        if handles.SavedDataCheck.Value && handles.StationVariables(variable_ind(v),station_ind(k))
            pl(3,k) = plot(sp(v), handles.workingData(station_ind(k)).data.date_time, ...
                handles.workingData(station_ind(k)).data.(vars{v}),'-',...
                'Linewidth',2,...
                'color',colors(k,:));
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
    pind = ~isnan(pl);
    
    if ~isempty(pl)
        % variable selected, one station, but no data
        pl = pl(end,:);
        legend(sp(v), pl(pind), handles.stations(station_ind(pind)),...
            'Location','Northwest')
    end
end

linkaxes(sp,'x')
handles.plotAxes = sp;

% save the data
guidata(hObject,handles);




function StationList = createStationList(handles)
% create the station list based on the variable_ind

ind = handles.StationVariables(get(handles.variableList,'Value'),:);
ind = logical(sum(ind,1));

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
function correctDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to correctDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% calls the correcting functions
if get(handles.PrecipCorrectionCheck,'Value')
    [station_ind,variable_ind] = getStationVariables(handles);
    CumPPT = handles.workingData(:,station_ind,variable_ind);
    date = handles.dtimes;
    
    CumPPT(isnan(CumPPT)) = handles.precip.noData;
    M = size(CumPPT,2);
    
    bucketDump = handles.precip.bucketDump*ones(1,M);
    recharge = handles.precip.recharge*ones(1,M);
    noise = handles.precip.noise*ones(1,M);
    noData = handles.precip.noData*ones(1,M);
    outputInterval = handles.precip.outputInterval;
    
    % correct the data and store
    precip_corr = correctPrecipitation(date,CumPPT,bucketDump,recharge,noise,noData,outputInterval);
    
    handles.workingData(:,station_ind,variable_ind) = precip_corr;
    
else
    
    handles = correctData(handles);
end

guidata(hObject,handles);

UpdatePlot_Callback(handles.UpdatePlot, eventdata, handles);

% --- Executes on button press in saveDataButton.
function saveDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[station_ind,variable_ind] = getStationVariables(handles);

handles.savedData(:,station_ind,variable_ind) = handles.workingData(:,station_ind,variable_ind);

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
function resetWorkingDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetWorkingDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('Are you sure you want to clear the current working data for these stations?', ...
    'Clear Working Data', ...
    'Yes','No','No');

if strcmp(choice,'Yes')
    [station_ind,variable_ind] = getStationVariables(handles);
    handles.workingData(:,station_ind,variable_ind) = handles.originalData(:,station_ind,variable_ind);
end

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
function Menu_Precipitation_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Precipitation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Menu_Precipitation_Options_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Precipitation_Options (see GCBO)
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
    
end

guidata(hObject,handles);


% --------------------------------------------------------------------
function Menu_SaveData_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_SaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Menu_SaveData_matFile_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_SaveData_matFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uiputfile('CorrectedData.mat','Save MAT File');

f = fullfile(pathname,filename);

% get the data
stations = handles.stations;
dtime = handles.dtimes;
sData = handles.savedData;
vars = handles.vars;

% remove any stations with all NaN's
[sData,stations,vars] = minimizeData(sData,stations,vars);

% save the data
save(f,'sData','stations','vars','dtime')


% --------------------------------------------------------------------
function Menu_SaveData_csvFile_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_SaveData_csvFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


pathname = uigetdir(pwd,'Save CSV''s to Directory ');

% get the data
stations = handles.stations;
dtime = handles.dtimes;
sData = handles.savedData;
vars = handles.vars;

% remove any stations with all NaN's
[sData,stations,vars] = minimizeData(sData,stations,vars);

% write a file for each variable
hdr = ['date' stations(:)'];
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
        
        dt = datestr(dtime(k),'mm-dd-yyyy HH:MM');
        
        % add date and commas
        line = strtrim([dt line]);
        line = strjoin(line,',');
        
        fprintf(fid,'%s\n',line);
        
    end
    
    fclose(fid);
end


function [data,stations,vars] = minimizeData(data,stations,vars)
% Take the matrix data and remove all colums with all NaN values in the 3rd
% dimension.  Return the stations and variables associated with it.

nVals = size(data,1);
variable_ind = sum(isnan(data),1) ~= nVals;
station_ind = sum(variable_ind,3) ~= 0;
variable_ind = sum(variable_ind,2) ~= 0;

data = data(:,station_ind,variable_ind);
stations = stations(station_ind);
vars = vars(variable_ind);



