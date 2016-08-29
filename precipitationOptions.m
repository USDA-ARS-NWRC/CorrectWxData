function varargout = precipitationOptions(varargin)
% PRECIPITATIONOPTIONS MATLAB code for precipitationOptions.fig
%      PRECIPITATIONOPTIONS, by itself, creates a new PRECIPITATIONOPTIONS or raises the existing
%      singleton*.
%
%      H = PRECIPITATIONOPTIONS returns the handle to a new PRECIPITATIONOPTIONS or the handle to
%      the existing singleton*.
%
%      PRECIPITATIONOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRECIPITATIONOPTIONS.M with the given input arguments.
%
%      PRECIPITATIONOPTIONS('Property','Value',...) creates a new PRECIPITATIONOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before precipitationOptions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to precipitationOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help precipitationOptions

% Last Modified by GUIDE v2.5 29-Aug-2016 12:46:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @precipitationOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @precipitationOptions_OutputFcn, ...
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


% --- Executes just before precipitationOptions is made visible.
function precipitationOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to precipitationOptions (see VARARGIN)

% Choose default command line output for precipitationOptions
handles.output = hObject;

if ~isempty(varargin)
    input = varargin{1};
    handles.bucketDump = input.bucketDump;
    handles.recharge = input.recharge;
    handles.noise = input.noise;
    handles.noData = input.noData;
    handles.interp = input.interp;
    
    % set the values
    set(handles.bucketDumpInput,'String',handles.bucketDump)
    set(handles.rechargeInput,'String',handles.recharge)
    set(handles.noiseInput,'String',handles.noise)
    set(handles.noDataInput,'Value',handles.noData)
    set(handles.linearInterp,'Value',handles.interp)
        
else
    % set the defaults
    handles.bucketDump = 6.25;
    handles.recharge = 25;
    handles.noise = 2.5;
    handles.noData = -6999;
    handles.interp = 0;
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes precipitationOptions wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = precipitationOptions_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(handles.figure1);

function bucketDumpInput_Callback(hObject, eventdata, handles)
% hObject    handle to bucketDumpInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bucketDumpInput as text
%        str2double(get(hObject,'String')) returns contents of bucketDumpInput as a double

val = str2double(get(hObject,'String'));

handles.bucketDump = val;

if isnan(val)
    set(hObject,'String',6.25)
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function bucketDumpInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bucketDumpInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rechargeInput_Callback(hObject, eventdata, handles)
% hObject    handle to rechargeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rechargeInput as text
%        str2double(get(hObject,'String')) returns contents of rechargeInput as a double

val = str2double(get(hObject,'String'));

handles.recharge = val;

if isnan(val)
    set(hObject,'String',25)
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function rechargeInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rechargeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noiseInput_Callback(hObject, eventdata, handles)
% hObject    handle to noiseInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noiseInput as text
%        str2double(get(hObject,'String')) returns contents of noiseInput as a double

val = str2double(get(hObject,'String'));

handles.noise = val;

if isnan(val)
    set(hObject,'String',2.5)
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function noiseInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noiseInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noDataInput_Callback(hObject, eventdata, handles)
% hObject    handle to noDataInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noDataInput as text
%        str2double(get(hObject,'String')) returns contents of noDataInput as a double

val = str2double(get(hObject,'String'));

handles.noData = val;

if isnan(val)
    set(hObject,'String',-6999)
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function noDataInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noDataInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
% hObject    handle to doneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

options.bucketDump = handles.bucketDump;
options.recharge = handles.recharge;
options.noise = handles.noise;
options.noData = handles.noData;
options.interp = handles.interp;
handles.output = options;

guidata(hObject,handles);

close(handles.figure1);

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
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


% --- Executes on button press in linearInterp.
function linearInterp_Callback(hObject, eventdata, handles)
% hObject    handle to linearInterp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of linearInterp

handles.interp = get(hObject, 'Value');

guidata(hObject,handles);



