function varargout = clearSkyOptions(varargin)
% CLEARSKYOPTIONS MATLAB code for clearSkyOptions.fig
%      CLEARSKYOPTIONS, by itself, creates a new CLEARSKYOPTIONS or raises the existing
%      singleton*.
%
%      H = CLEARSKYOPTIONS returns the handle to a new CLEARSKYOPTIONS or the handle to
%      the existing singleton*.
%
%      CLEARSKYOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLEARSKYOPTIONS.M with the given input arguments.
%
%      CLEARSKYOPTIONS('Property','Value',...) creates a new CLEARSKYOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before clearSkyOptions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to clearSkyOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help clearSkyOptions

% Last Modified by GUIDE v2.5 25-Feb-2016 09:08:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @clearSkyOptions_OpeningFcn, ...
    'gui_OutputFcn',  @clearSkyOptions_OutputFcn, ...
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


% --- Executes just before clearSkyOptions is made visible.
function clearSkyOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to clearSkyOptions (see VARARGIN)

% Choose default command line output for clearSkyOptions
handles.output = hObject;

if ~isempty(varargin)
    input = varargin{1};
    %     handles.bucketDump = input.bucketDump;
    
    fnames = fieldnames(input);
    for f = 1:length(fnames)
        handles.(fnames{f}) = input.(fnames{f});
        
        if ~strcmp(fnames{f}, 'd') && ~strcmp(fnames{f}, 'keep_plot')
            v = [fnames{f} 'Input'];
            set(handles.(v),'String',handles.(fnames{f}))
        else
            v = [fnames{f} 'Check'];
            set(handles.(v),'Value',handles.(fnames{f}))
        end
    end
    
else
    % set the defaults
    handles.tau = 0.4;
    handles.scale = 1;
    handles.zone = 0;
    handles.slope = 0;
    handles.aspect = 0;
    handles.um = 0.28;
    handles.um2 = 2.8;
    handles.omega = 0.85;
    handles.g = 0.3;
    handles.R0 = 0.5;
    handles.d = 0;
    handles.cfTimeStep = 1;
    handles.keep_plot = 0;
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes clearSkyOptions wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = clearSkyOptions_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(handles.figure1);


function tauInput_Callback(hObject, eventdata, handles)
% hObject    handle to tauInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tauInput as text
%        str2double(get(hObject,'String')) returns contents of tauInput as a double

val = str2double(get(hObject,'String'));
handles.tau = val;

if isnan(val)
    set(hObject, 'String', 0.4)
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function tauInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scaleInput_Callback(hObject, eventdata, handles)
% hObject    handle to scaleInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaleInput as text
%        str2double(get(hObject,'String')) returns contents of scaleInput as a double

val = str2double(get(hObject,'String'));
handles.scale = val;

if isnan(val)
    set(hObject, 'String', 1)
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function scaleInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zoneInput_Callback(hObject, eventdata, handles)
% hObject    handle to zoneInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zoneInput as text
%        str2double(get(hObject,'String')) returns contents of zoneInput as a double

val = str2double(get(hObject,'String'));
handles.zone = val;

if isnan(val)
    set(hObject, 'String', 0)
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function zoneInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoneInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slopeInput_Callback(hObject, eventdata, handles)
% hObject    handle to slopeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slopeInput as text
%        str2double(get(hObject,'String')) returns contents of slopeInput as a double

val = str2double(get(hObject,'String'));
handles.slope = val;

if isnan(val)
    set(hObject, 'String', 0)
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slopeInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slopeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function umInput_Callback(hObject, eventdata, handles)
% hObject    handle to umInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of umInput as text
%        str2double(get(hObject,'String')) returns contents of umInput as a double

val = str2double(get(hObject,'String'));
handles.um = val;

if isnan(val)
    set(hObject, 'String', 0.28)
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function umInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to umInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function aspectInput_Callback(hObject, eventdata, handles)
% hObject    handle to aspectInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of aspectInput as text
%        str2double(get(hObject,'String')) returns contents of aspectInput as a double

val = str2double(get(hObject,'String'));
handles.aspect = val;

if isnan(val)
    set(hObject, 'String', 0)
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function aspectInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aspectInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function omegaInput_Callback(hObject, eventdata, handles)
% hObject    handle to omegaInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of omegaInput as text
%        str2double(get(hObject,'String')) returns contents of omegaInput as a double

val = str2double(get(hObject,'String'));
handles.omega = val;

if isnan(val)
    set(hObject, 'String', 0.85)
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function omegaInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to omegaInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function um2Input_Callback(hObject, eventdata, handles)
% hObject    handle to um2Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of um2Input as text
%        str2double(get(hObject,'String')) returns contents of um2Input as a double

val = str2double(get(hObject,'String'));
handles.um2 = val;

if isnan(val)
    set(hObject, 'String', 2.8)
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function um2Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to um2Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gInput_Callback(hObject, eventdata, handles)
% hObject    handle to gInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gInput as text
%        str2double(get(hObject,'String')) returns contents of gInput as a double

val = str2double(get(hObject,'String'));
handles.g = val;

if isnan(val)
    set(hObject, 'String', 0.3)
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function gInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function R0Input_Callback(hObject, eventdata, handles)
% hObject    handle to R0Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R0Input as text
%        str2double(get(hObject,'String')) returns contents of R0Input as a double

val = str2double(get(hObject,'String'));
handles.R0 = val;

if isnan(val)
    set(hObject, 'String', 0.5)
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function R0Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R0Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dCheck.
function dCheck_Callback(hObject, eventdata, handles)
% hObject    handle to dCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dCheck

val = str2double(get(hObject,'Value'));
handles.d = val;

guidata(hObject,handles);


% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
% hObject    handle to doneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

options.tau = handles.tau;
options.scale = handles.scale;
options.zone = handles.zone;
options.slope = handles.slope;
options.aspect = handles.aspect;
options.um = handles.um;
options.um2 = handles.um2;
options.omega = handles.omega;
options.g = handles.g;
options.R0 = handles.R0;
options.d = handles.d;
options.keep_plot = handles.keep_plot;
options.cfTimeStep = handles.cfTimeStep;

handles.output = options;

guidata(hObject,handles);

close(handles.figure1);

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = 0;

guidata(hObject, handles);

close(handles.figure1);


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% set the defaults
handles.tau = 0.4;
handles.scale = 1;
handles.zone = 0;
handles.slope = 0;
handles.aspect = 0;
handles.um = 0.28;
handles.um2 = 2.8;
handles.omega = 0.85;
handles.g = 0.3;
handles.R0 = 0.5;
handles.d = 0;
handles.cfTimeStep = 1;
handles.keep_plot = 0;

fnames = {'tau','scale','zone','slope','aspect','um','um2','omega','g','R0','d','cfTimeStep','keep_plot'};

for f = 1:length(fnames)
    if ~strcmp(fnames{f}, 'd') && ~strcmp(fnames{f}, 'keep_plot')
        v = [fnames{f} 'Input'];
        set(handles.(v),'String',handles.(fnames{f}))
    else
        v = [fnames{f} 'Check'];
        set(handles.(v),'Value',handles.(fnames{f}))
    end
end

guidata(hObject,handles);


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



function cfTimeStepInput_Callback(hObject, eventdata, handles)
% hObject    handle to cfTimeStepInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cfTimeStepInput as text
%        str2double(get(hObject,'String')) returns contents of cfTimeStepInput as a double

val = str2double(get(hObject,'String'));
handles.cfTimeStep = val;

if isnan(val)
    set(hObject, 'String', 1)
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function cfTimeStepInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cfTimeStepInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in keep_plotCheck.
function keep_plotCheck_Callback(hObject, eventdata, handles)
% hObject    handle to keep_plotCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keep_plotCheck

val = get(hObject,'Value');
handles.keep_plot = val;

guidata(hObject,handles);
