function varargout = PainterUI(varargin)
% PAINTERUI MATLAB code for PainterUI.fig
%      PAINTERUI, by itself, creates a new PAINTERUI or raises the existing
%      singleton*.
%
%      H = PAINTERUI returns the handle to a new PAINTERUI or the handle to
%      the existing singleton*.
%
%      PAINTERUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PAINTERUI.M with the given input arguments.
%
%      PAINTERUI('Property','Value',...) creates a new PAINTERUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PainterUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PainterUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PainterUI

% Last Modified by GUIDE v2.5 18-Jul-2013 10:16:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PainterUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PainterUI_OutputFcn, ...
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


% --- Executes just before PainterUI is made visible.
function PainterUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PainterUI (see VARARGIN)

handles.imageObject = varargin{1};

% Choose default command line output for PainterUI
handles.output = hObject;

set(hObject,'ButtonDownFcn',@buttonDownFcn);
set(hObject,'WindowButtonUpFcn',@buttonUpFcn);

set(hObject,'Units','pixels');


% Perf tweak
set(hObject,'doublebuffer','off');

handles.scalingFactor = 0.5;
handles.changed = false;
handles.opacity = 1;
set(handles.slider_Opacity,'Value',1);

% Showing the main image
%I = imread('nolif_1_2.tif');
I = handles.imageObject.pc;
%I = imresize(I,0.5);
handles.image = I;
h = imshow(imresize(I,handles.scalingFactor),'Parent',handles.axes_Image);

% All hits are set to off, we detect clicks on the window

set(h,'HitTest','off');

sizeImage = [size(I,1) size(I,2)];

if(ndims(I)>2)
    maskSize = size(imresize(rgb2gray(I),handles.scalingFactor,'nearest'));
else
    maskSize = size(imresize(I,handles.scalingFactor,'nearest'));
end
% Setting up the overlays

for i=1:2
    % ClassImage holds the painted information
    mask = reshape(handles.imageObject.classMasks(i,:,:),sizeImage);
    mask = imresize(mask,handles.scalingFactor,'nearest');
    
    %handles.(['Class',num2str(i),'Image']) = logical(reshape(handles.imageObject.classMasks(i,:,:),size(rgb2gray(handles.imageObject.pc))));
    handles.(['Class',num2str(i),'Image']) = mask;
    % Colormask are used to display the overlays in color. Their CData is
    % not changed during paintaing, only their alpha data
    
    if(i==1)
        handles.(['colorMask',num2str(i)]) = im2uint8(cat(3, zeros(maskSize),ones(maskSize), zeros(maskSize)));
    else    
        handles.(['colorMask',num2str(i)]) = im2uint8(cat(3, ones(maskSize),zeros(maskSize), zeros(maskSize)));
    end
    
    % Display the color mask
    handles.(['overlay',num2str(i)]) = imshow(handles.(['colorMask',num2str(i)]),'Parent',handles.(['axes_overlay',num2str(i)]));
    axis image;
    
    % Set HitTest to zeros so it doesn't interfer with click callbacks
    set(handles.(['overlay',num2str(i)]),'HitTest','off');
    
    
    % Set alpha mapping to none to speed up changes in alpha data
    set(handles.(['overlay',num2str(i)]),'AlphaDataMapping','none');
    
    % Initially set the alpha data to zeros in order to hide the mask
    set(handles.(['overlay',num2str(i)]),'AlphaData',zeros(maskSize));
end

linkaxes([handles.axes_Image,handles.axes_overlay1, handles.axes_overlay2]);

% Pre-compute the grid used for painting purposes
[handles.xGrid, handles.yGrid] = meshgrid(1:size(handles.Class1Image,2), 1:size(handles.Class1Image,1)); 

updateView(handles);
h=zoom;
set(h,'ActionPreCallback',@zoomCallback);
set(h,'ActionPostCallback',@zoomCallback2);

guidata(hObject, handles);

% UIWAIT makes PainterUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function zoomCallback(a,b)
a
b
function zoomCallback2(a,b)
a
b
function buttonDownFcn(a,b)
set(a,'WindowButtonMotionFcn',@PaintGo);

function buttonUpFcn(a,b)
set(a,'WindowButtonMotionFcn','');

function updateView(handles)

% Iterate through the different classes
for i=1:2
    % Update the alpha data of the corresponding overlay
    set(handles.(['overlay',num2str(i)]), 'AlphaData', (handles.(['Class',num2str(i),'Image'])==1)*handles.opacity);
end

guidata(handles.figure1, handles);

% --- Executes on button press in btn_TrainAndGo.
function btn_TrainAndGo_Callback(hObject, eventdata, handles)
% hObject    handle to btn_TrainAndGo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save(handles);




function save(handles)
for i=1:2
    % Save the masks!
    handles.imageObject.classMasks(i,:,:) = logical(imresize(handles.(['Class',num2str(i),'Image']),1/handles.scalingFactor,'nearest'));
end
handles.changed = false;
guidata(handles.figure1,handles);

function PaintGo(figure,b)

    handles = guidata(figure);
    
    handles.changed = true;
    
    % Get the currently selected class
    currentClass = get(get(handles.classSelector,'SelectedObject'),'UserData');
    currentField = ['Class',num2str(currentClass),'Image'];
    
    % Get the clicked point
    point=get(handles.axes_overlay2,'CurrentPoint');
    coords = point(1,:);
    x = coords(2);
    y = coords(1);

    % Get the brush radius
    brushRadius = str2num(get(handles.txt_BrushSize,'String'));
    
    maskSize = size(handles.(currentField));
    
    if(get(handles.pop_BrushStyle,'Value')==2)
        handles.(currentField)(round(x),round(y))=1;
        %[xGrid, yGrid] = meshgrid(1:size(handles.(currentField),2), 1:size(handles.(currentField),1));
        %handles.(currentField)(sqrt((handles.xGrid-y).^2 + (handles.yGrid-x).^2) <= brushRadius)=1;  
    elseif(get(handles.pop_BrushStyle,'Value')==3)
        
        minX = x-brushRadius;
        if(minX<=1)
            minX = 1;
        end
        
        maxX = x+brushRadius;
        
        if(maxX>=maskSize(1))
            maxX = maskSize(1);
        end
        
        minY = y-brushRadius;
        if(minY<=1)
            minY = 1;
        end
        
        maxY = y+brushRadius;
        
        if(maxY>=maskSize(2))
            maxY = maskSize(2);
        end
        
        xRange = minX:maxX;
        yRange = minY:maxY;
        handles.Class1Image(round(xRange),round(yRange))=0; 
        handles.Class2Image(round(xRange),round(yRange))=0; 
    else
        minX = x-brushRadius;
        if(minX<=1)
            minX = 1;
        end
        
        maxX = x+brushRadius;
        
        if(maxX>=maskSize(1))
            maxX = maskSize(1);
        end
        
        minY = y-brushRadius;
        if(minY<=1)
            minY = 1;
        end
        
        maxY = y+brushRadius;
        
        if(maxY>=maskSize(2))
            maxY = maskSize(2);
        end
        
        xRange = minX:maxX;
        yRange = minY:maxY;

        
        handles.(currentField)(round(xRange),round(yRange))=1;
    end    

    guidata(figure,handles);
    updateView(handles);
    
function mask = createLearningMask(handles)

for i=1:2
    currentField = ['Class',num2str(i),'Image'];
    
    if(i==1)
        mask = zeros(size(handles.(currentField)));
    end
    
    mask(logical(handles.(currentField)))=i;
end
    
    
% --- Outputs from this function are returned to the command line.
function varargout = PainterUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in pop_BrushStyle.
function pop_BrushStyle_Callback(hObject, eventdata, handles)
% hObject    handle to pop_BrushStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_BrushStyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_BrushStyle


% --- Executes during object creation, after setting all properties.
function pop_BrushStyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_BrushStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_Class.
function pop_Class_Callback(hObject, eventdata, handles)
% hObject    handle to pop_Class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_Class contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_Class


% --- Executes during object creation, after setting all properties.
function pop_Class_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_Class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when selected object is changed in classSelector.
function classSelector_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in classSelector 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
handles.currentClass = get(eventdata.NewValue,'UserData');
guidata(handles.figure1,handles);

function txt_BrushSize_Callback(hObject, eventdata, handles)
% hObject    handle to txt_BrushSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_BrushSize as text
%        str2double(get(hObject,'String')) returns contents of txt_BrushSize as a double

% --- Executes during object creation, after setting all properties.
function txt_BrushSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_BrushSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_Opacity_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Opacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.opacity = get(hObject,'Value');
updateView(handles);
guidata(handles.figure1,handles);

% --- Executes during object creation, after setting all properties.
function slider_Opacity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Opacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

if(handles.changed)
    choice = questdlg('Unsaved changes, save?', 'Unsaved changes','Save','Discard','Cancel','Save');

    switch choice
        case 'Save'
            save(handles);
            delete(hObject);
        case 'Discard'
            delete(hObject);
        case 'Cancel'
    end
else
    delete(hObject);
end




