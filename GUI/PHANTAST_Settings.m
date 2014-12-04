function varargout = PHANTAST_Settings(varargin)
% PHANTAST_SETTINGS MATLAB code for PHANTAST_Settings.fig
%      PHANTAST_SETTINGS, by itself, creates a new PHANTAST_SETTINGS or raises the existing
%      singleton*.
%
%      H = PHANTAST_SETTINGS returns the handle to a new PHANTAST_SETTINGS or the handle to
%      the existing singleton*.
%
%      PHANTAST_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHANTAST_SETTINGS.M with the given input arguments.
%
%      PHANTAST_SETTINGS('Property','Value',...) creates a new PHANTAST_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PHANTAST_Settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PHANTAST_Settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PHANTAST_Settings

% Last Modified by GUIDE v2.5 17-Jul-2013 10:16:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PHANTAST_Settings_OpeningFcn, ...
                   'gui_OutputFcn',  @PHANTAST_Settings_OutputFcn, ...
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


% --- Executes just before PHANTAST_Settings is made visible.
function PHANTAST_Settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PHANTAST_Settings (see VARARGIN)

% Choose default command line output for PHANTAST_Settings
handles.output = hObject;

%set(hObject,'visible','off');


% We generate a universal callback for the LIVE mode
fields = fieldnames(handles);
for i=1:numel(fields)
    if(numel(strfind(fields{i},'param_')))
        set(handles.(fields{i}),'Callback',@callbackTest);
    end
end

% Update handles structure
handles.MainClass = varargin{3};
guidata(hObject, handles);

% UIWAIT makes PHANTAST_Settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function callbackTest(object,~)
handles = guidata(object);
handles.MainClass.settingsUpdated();

% --- Outputs from this function are returned to the command line.
function varargout = PHANTAST_Settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function param_epsilon_Callback(hObject, eventdata, handles)
% hObject    handle to param_epsilon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param_epsilon as text
%        str2double(get(hObject,'String')) returns contents of param_epsilon as a double


% --- Executes during object creation, after setting all properties.
function param_epsilon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param_epsilon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in param_contrastStretchingCheckBox.
function param_contrastStretchingCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to param_contrastStretchingCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of param_contrastStretchingCheckBox



function param_contrastStretchingSaturation_Callback(hObject, eventdata, handles)
% hObject    handle to param_contrastStretchingSaturation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param_contrastStretchingSaturation as text
%        str2double(get(hObject,'String')) returns contents of param_contrastStretchingSaturation as a double


% --- Executes during object creation, after setting all properties.
function param_contrastStretchingSaturation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param_contrastStretchingSaturation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in param_automaticThresholdDropdown.
function param_automaticThresholdDropdown_Callback(hObject, eventdata, handles)
% hObject    handle to param_automaticThresholdDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns param_automaticThresholdDropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from param_automaticThresholdDropdown


% --- Executes during object creation, after setting all properties.
function param_automaticThresholdDropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param_automaticThresholdDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function param_minimumFillArea_Callback(hObject, eventdata, handles)
% hObject    handle to param_minimumFillArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param_minimumFillArea as text
%        str2double(get(hObject,'String')) returns contents of param_minimumFillArea as a double


% --- Executes during object creation, after setting all properties.
function param_minimumFillArea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param_minimumFillArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function param_sigma_Callback(hObject, eventdata, handles)
% hObject    handle to param_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param_sigma as text
%        str2double(get(hObject,'String')) returns contents of param_sigma as a double


% --- Executes during object creation, after setting all properties.
function param_sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in param_haloRemovalCheckBox.
function param_haloRemovalCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to param_haloRemovalCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of param_haloRemovalCheckBox



function param_minimumObjectArea_Callback(hObject, eventdata, handles)
% hObject    handle to param_minimumObjectArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param_minimumObjectArea as text
%        str2double(get(hObject,'String')) returns contents of param_minimumObjectArea as a double


% --- Executes during object creation, after setting all properties.
function param_minimumObjectArea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param_minimumObjectArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in param_removeSmallObjectCheckbox.
function param_removeSmallObjectCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to param_removeSmallObjectCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of param_removeSmallObjectCheckbox


% --- Executes on button press in btn_Save.
function btn_Save_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MainClass.savePresets();

% --- Executes on button press in loadPresets.
function loadPresets_Callback(hObject, eventdata, handles)
% hObject    handle to loadPresets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in param_rescaleCheckbox.
function param_rescaleCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to param_rescaleCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of param_rescaleCheckbox



function param_HRremoveSmallObjects_Callback(hObject, eventdata, handles)
% hObject    handle to param_HRremoveSmallObjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param_HRremoveSmallObjects as text
%        str2double(get(hObject,'String')) returns contents of param_HRremoveSmallObjects as a double


% --- Executes during object creation, after setting all properties.
function param_HRremoveSmallObjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param_HRremoveSmallObjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function param_maxRemovalRatio_Callback(hObject, eventdata, handles)
% hObject    handle to param_maxRemovalRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param_maxRemovalRatio as text
%        str2double(get(hObject,'String')) returns contents of param_maxRemovalRatio as a double


% --- Executes during object creation, after setting all properties.
function param_maxRemovalRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param_maxRemovalRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function param_additionalHoleFillArea_Callback(hObject, eventdata, handles)
% hObject    handle to param_additionalHoleFillArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param_additionalHoleFillArea as text
%        str2double(get(hObject,'String')) returns contents of param_additionalHoleFillArea as a double


% --- Executes during object creation, after setting all properties.
function param_additionalHoleFillArea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param_additionalHoleFillArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in param_removeHolesAddCheckbox.
function param_removeHolesAddCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to param_removeHolesAddCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of param_removeHolesAddCheckbox


% --- Executes on button press in param_tidyUpBinaryImage.
function param_tidyUpBinaryImage_Callback(hObject, eventdata, handles)
% hObject    handle to param_tidyUpBinaryImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of param_tidyUpBinaryImage


% --- Executes on button press in btn_Load.
function btn_Load_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MainClass.loadPresets();

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
set(hObject,'visible','off');
%delete(hObject);


% --- Executes on button press in btn_Default.
function btn_Default_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MainClass.loadDefaults();


% --- Executes on button press in param_doDensityEstimation.
function param_doDensityEstimation_Callback(hObject, eventdata, handles)
% hObject    handle to param_doDensityEstimation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of param_doDensityEstimation


% --- Executes on button press in param_saveSegmentedImages.
function param_saveSegmentedImages_Callback(hObject, eventdata, handles)
% hObject    handle to param_saveSegmentedImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of param_saveSegmentedImages


% --- Executes on button press in btn_Optimize.
function btn_Optimize_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Optimize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MainClass.optimizer = Optimizer();
