function varargout = smoothnOptions(varargin)
% SMOOTHNOPTIONS MATLAB code for smoothnOptions.fig
%      SMOOTHNOPTIONS, by itself, creates a new SMOOTHNOPTIONS or raises the existing
%      singleton*.
%
%      H = SMOOTHNOPTIONS returns the handle to a new SMOOTHNOPTIONS or the handle to
%      the existing singleton*.
%
%      SMOOTHNOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SMOOTHNOPTIONS.M with the given input arguments.
%
%      SMOOTHNOPTIONS('Property','Value',...) creates a new SMOOTHNOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before smoothnOptions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to smoothnOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help smoothnOptions

% Last Modified by GUIDE v2.5 16-Mar-2015 11:20:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @smoothnOptions_OpeningFcn, ...
    'gui_OutputFcn',  @smoothnOptions_OutputFcn, ...
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


% --- Executes just before smoothnOptions is made visible.
function smoothnOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to smoothnOptions (see VARARGIN)

% Choose default command line output for smoothnOptions
handles.output = hObject;

if ~isempty(varargin)
    input = varargin{1};
    handles.smoothingParameterValue = input.smoothingParameterValue;
    handles.TolZValue = input.TolZValue;
    handles.MaxIterValue = input.MaxIterValue;
    handles.WeightValue = input.WeightValue;
    handles.RobustValue = input.RobustValue;
    
    % set the values
    set(handles.smoothingParameterInput,'String',handles.smoothingParameterValue)
    set(handles.TolZInput,'String',handles.TolZValue)
    set(handles.MaxIterInput,'String',handles.MaxIterValue)
    set(handles.robustSmoothingCheck,'Value',handles.RobustValue)
    
    contents = cellstr(get(handles.WeightInput,'String'));
    ind = find(strcmp(handles.WeightValue,contents));
    set(handles.WeightInput,'Value',ind);
    
else
    % set the defaults
    handles.smoothingParameterValue = NaN;
    handles.TolZValue = 1e-3;
    handles.MaxIterValue = 100;
    handles.WeightValue = 'bisquare';
    handles.RobustValue = 0;
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes smoothnOptions wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = smoothnOptions_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(handles.figure1);


function smoothingParameterInput_Callback(hObject, eventdata, handles)
% hObject    handle to smoothingParameterInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothingParameterInput as text
%        str2double(get(hObject,'String')) returns contents of smoothingParameterInput as a double

val = str2double(get(hObject,'String'));

handles.smoothingParameterValue = val;

if isnan(val)
    set(hObject,'String',NaN)
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function smoothingParameterInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothingParameterInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in robustSmoothingCheck.
function robustSmoothingCheck_Callback(hObject, eventdata, handles)
% hObject    handle to robustSmoothingCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of robustSmoothingCheck

handles.RobustValue = get(hObject,'Value');

guidata(hObject,handles);



function TolZInput_Callback(hObject, eventdata, handles)
% hObject    handle to TolZInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TolZInput as text
%        str2double(get(hObject,'String')) returns contents of TolZInput as a double

val = str2double(get(hObject,'String'));

handles.TolZValue = val;

if isnan(val)
    set(hObject,'String',1e-3)
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function TolZInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TolZInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxIterInput_Callback(hObject, eventdata, handles)
% hObject    handle to MaxIterInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxIterInput as text
%        str2double(get(hObject,'String')) returns contents of MaxIterInput as a double

val = str2double(get(hObject,'String'));

handles.MaxIterValue = val;

if isnan(val)
    set(hObject,'String',100)
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function MaxIterInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxIterInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in WeightInput.
function WeightInput_Callback(hObject, eventdata, handles)
% hObject    handle to WeightInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WeightInput contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WeightInput

contents = cellstr(get(hObject,'String'));
val = contents{get(hObject,'Value')};

handles.WeightValue = val;

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function WeightInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WeightInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DonePush.
function DonePush_Callback(hObject, eventdata, handles)
% hObject    handle to DonePush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

options.smoothingParameterValue = handles.smoothingParameterValue;
options.TolZValue = handles.TolZValue;
options.MaxIterValue = handles.MaxIterValue;
options.WeightValue = handles.WeightValue;
options.RobustValue = handles.RobustValue;
handles.output = options;

guidata(hObject,handles);

close(handles.figure1);

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = 0;
guidata(hObject,handles);

close(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
