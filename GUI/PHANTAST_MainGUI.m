function varargout = PHANTAST_MainGUI(varargin)
% PHANTAST_MAINGUI MATLAB code for PHANTAST_MainGUI.fig
%      PHANTAST_MAINGUI, by itself, creates a new PHANTAST_MAINGUI or raises the existing
%      singleton*.
%
%      H = PHANTAST_MAINGUI returns the handle to a new PHANTAST_MAINGUI or the handle to
%      the existing singleton*.
%
%      PHANTAST_MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHANTAST_MAINGUI.M with the given input arguments.
%
%      PHANTAST_MAINGUI('Property','Value',...) creates a new PHANTAST_MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PHANTAST_MainGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PHANTAST_MainGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PHANTAST_MainGUI

% Last Modified by GUIDE v2.5 22-Jul-2013 10:32:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PHANTAST_MainGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PHANTAST_MainGUI_OutputFcn, ...
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


% --- Executes just before PHANTAST_MainGUI is made visible.
function PHANTAST_MainGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PHANTAST_MainGUI (see VARARGIN)

% Choose default command line output for PHANTAST_MainGUI
handles.output = hObject;

handles.MainClass = varargin{1};

handles.SettingsWindow = PHANTAST_Settings('visible','off',handles.MainClass);

imshow(imread('phantast.png'),'Parent',handles.axesLogo);
set(handles.axesLogo,'Color','none');


set(handles.browserImageSlider,'min',0);
set(handles.browserImageSlider,'max',1);
set(handles.browserImageSlider,'Enable','off');


for i=1:4
    set(handles.(['browserAxes',num2str(i)]),'Visible','off');
end

%set(handles.resultTable,'ColumnName',handles.MainClass.resultsHeaders);
set(handles.processingStatus,'String','Ready');
set(handles.processingStatus,'ForegroundColor', 'blue');

set(handles.inputFolderPath,'String',getCurrentDir());

% Update handles structure
guidata(hObject, handles);

updateFileList(handles);
updateFilesDropdownMenu(handles);
setImageBrowser(handles);
updateImageBrowser(0,handles);

handles = guidata(hObject);

if(size(handles.fileNames,1) > 1)
    previewImageFromList(1,handles);
end

function currentDir = getCurrentDir()
if isdeployed() % Stand-alone mode.
    if(ismac())
        [~, result] = system('pwd');
        currentDir = result(1,1:end-1);
    else
        [~, result] = system('path');
        currentDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    end
else % MATLAB mode.
    currentDir = pwd;
end

function updateFilesDropdownMenu(handles)
handles = guidata(handles.figure1);
names = getImageFilesInDirectory(handles);

if(~isempty(names))
    set(handles.imagesInDirectory,'String',names);
end
guidata(handles.figure1,handles);

function updateImageBrowser(index,handles)
handles = guidata(handles.figure1); % Make sure handles are up to date
%selectedImageIdx = get(handles.imagesInDirectory,'Value');
names = getImageFilesInDirectory(handles);

if(numel(names)>0)
    count = 0;
    for i=1:4
        count = count+1;
        fieldName = ['browserAxes',num2str(count)];
        
        if(index+count <= numel(names))
            set(handles.(fieldName),'visible','on');
            imageToPreview = names{index+count};
            %I = imread(fullfile(getInputPathString(handles),imageToPreview));
                        
            image = imageFormatCheck(imread(fullfile(getInputPathString(handles),imageToPreview)));
            
            h=imshow(image,'Parent',handles.(fieldName));
            set(h,'Tag',num2str(index+count));
            set(h,'ButtonDownFcn',@previewImage);
            handles.(['Broswer',num2str(i),'_image']) = index+count;
            
            set(handles.(['browser',num2str(i),'text']),'string',imageToPreview);
        else
            cla(handles.(fieldName));
            set(handles.(fieldName),'visible','off');
            set(handles.(['browser',num2str(i),'text']),'string','');
        end
    end
else
    count = 0;
    for i=1:4
        count = count+1;
        fieldName = ['browserAxes',num2str(count)];
        cla(handles.(fieldName));
        set(handles.(fieldName),'visible','off');
        set(handles.(['browser',num2str(i),'text']),'string','');
    end
end
guidata(handles.figure1,handles);

function imageFormatted = imageFormatCheck(image)
if(size(image,3)>3)
    imageFormatted = image(:,:,1:3);
else
    imageFormatted = image;
end


function previewImage(info1,~,~)
imageToPreview = get(info1,'Tag');
window = get(get(info1,'Parent'),'Parent');
handles=guidata(window);

for i=1:4

    if(isfield(handles,['Broswer',num2str(i),'_image']))
        if(handles.(['Broswer',num2str(i),'_image']) == str2double(imageToPreview))
            set(handles.(['panelBrowser',num2str(i)]),'bordertype','line');
        else
            set(handles.(['panelBrowser',num2str(i)]),'bordertype','none');
        end
    end
end

set(handles.imagesInDirectory,'Value',str2double(imageToPreview));

names = getImageFilesInDirectory(handles);

image = imageFormatCheck(imread(fullfile(getInputPathString(handles),names{str2double(imageToPreview)})));

h=imshow(image,'Parent',handles.imagePreview);
set(h,'ButtonDownFcn',@imagePreviewCallback);

function previewImageFromList(index,handles)

for i=1:4
    if(isfield(handles,['Broswer',num2str(i),'_image']))
        if(handles.(['Broswer',num2str(i),'_image']) == index)
            set(handles.(['panelBrowser',num2str(i)]),'bordertype','line');
        else
            set(handles.(['panelBrowser',num2str(i)]),'bordertype','none');
        end
    end
end


names = getImageFilesInDirectory(handles);

image = imageFormatCheck(imread(fullfile(getInputPathString(handles),names{index})));

h=imshow(image,'Parent',handles.imagePreview);
set(h,'ButtonDownFcn',@imagePreviewCallback);

% --- Outputs from this function are returned to the command line.
function varargout = PHANTAST_MainGUI_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function imagesInDirectory_Callback(~, ~, handles) %#ok<DEFNU>
updateImageBrowser(get(handles.imagesInDirectory,'Value')-1,handles);
previewImageFromList(get(handles.imagesInDirectory,'Value'),guidata(handles.figure1));

% --- Executes on button press in pushbutton1.
function analysisButton_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handleSettings = guidata(handles.SettingsWindow);
liveRadioButton = get(handles.liveRadioButton,'Value');
singleImageRadioButton = get(handles.singleImageRadioButton,'Value');
doRescale = get(handleSettings.param_rescaleCheckbox,'Value');
doDensityEstimation = get(handleSettings.param_doDensityEstimation,'Value');
saveSegmentedImages = get(handleSettings.param_saveSegmentedImages,'Value');

selectedImageIdx = get(handles.imagesInDirectory,'Value');
names = getImageFilesInDirectory(handles);

if(liveRadioButton)
    
    selectedImage = names{selectedImageIdx};
    I = imread(fullfile(getInputPathString(handles),selectedImage));
    handles.MainClass.startLivePreview(I);
    %imshow(I);
    
else
    
    handles.MainClass.resultsHeaders = {};
    
    if(numel(names)==0)
        errordlg('No image selected!');
    else
        
        selectedImage = names{selectedImageIdx};
        
        if(singleImageRadioButton==1)
            iterationMax = 1;
        else
            iterationMax = numel(names);
        end
        
        handles.MainClass.images = [];
        handles.MainClass.processedImages = [];
        
        for i=1:iterationMax
            if(~singleImageRadioButton)
                selectedImage = names{i};
            end
            
            I = imread(fullfile(getInputPathString(handles),selectedImage));
            
            if(doRescale)
                I = imresize(I,[960,1280]);
            end
            
            I = imageFormatCheck(I);
            
            I_org = I;
            
            [J,distanceToNearestBlob] = handles.MainClass.processImage(I);
            
            L = imclearborder(J);
            stats = regionprops(J,'Area');
            
            [B,~] = bwboundaries(J,8);
            h=imshow(I_org,'Parent',handles.axes1);
            set(h,'ButtonDownFcn',@imagePreviewCallbackResult);
            
            hold(handles.axes1,'on');
            for k = 1:numel(B)
                boundary = B{k};
                plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 1.5,'Parent',handles.axes1)
            end
            hold(handles.axes1,'off');
            
            conf = computeConfluency(J);
            
            if(saveSegmentedImages)
                if(i==1)
                    images = cell(iterationMax,1);
                    processedImages = cell(iterationMax);
                end
                
                if(size(I_org,3)>1)
                    images{i} = rgb2gray(I_org);
                else
                    images{i} = I_org;
                end
                
                processedImages{i} = J;
            end
            
            if(doDensityEstimation)
                if(i==1)
                    results = cell(iterationMax,3);
                end
                
                results(i,:) = {names{i},conf{2}{1}, conf{2}{1}/distanceToNearestBlob};
            else
                
                if(i==1)
                    results = cell(iterationMax,3);
                end
                results(i,:) = {names{i},conf{2}{1}, mean([stats.Area])};
            end
            
            
            set(handles.processingStatus,'String',['Processing images (',num2str(round(i/iterationMax*100)),'%)']);
            set(handles.processingStatus,'ForegroundColor', 'red');
            drawnow % Check performance impact
            
        end
        
        handles.MainClass.resultsHeaders = {'Filename','Confluency'};
        
        if(doDensityEstimation)
            handles.MainClass.resultsHeaders{end+1} = 'PCC';
        end
        
        if(saveSegmentedImages)
            handles.MainClass.images = images;
            handles.MainClass.processedImages = processedImages;
        end
        
        handles.MainClass.results = results;
        
        set(handles.processingStatus,'String','Finished');
        set(handles.processingStatus,'ForegroundColor', [0    0.4980         0]);
        
        set(handles.resultTable, 'Data', results);
        set(handles.resultTable, 'ColumnName',handles.MainClass.resultsHeaders);
        guidata(hObject, handles);
    end
end

% --- Executes on button press in pushbutton4.
function exportButton_Callback(~, ~, handles) %#ok<DEFNU>
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
isempty(handles.MainClass.images)
size(handles.MainClass.images)
handles.MainClass.images
if(size(handles.MainClass.images,1)>0)
    ExploreResults(handles);
else
    errordlg('No results to explore!');
end

% --- Executes on button press in browseInputDirectory.
function browseInputDirectory_Callback(~, ~, handles) %#ok<DEFNU>
% hObject    handle to browseInputDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[chosenDirectory] = uigetdir();
if(chosenDirectory~=0)
    
    set(handles.inputFolderPath,'String',chosenDirectory);
    updateFileList(handles);
    setImageBrowser(handles);
    updateFilesDropdownMenu(handles);
    updateImageBrowser(1,handles);
end

function setImageBrowser(handles)
handles = guidata(handles.figure1); % Making sure handles are updated
files = getImageFilesInDirectory(handles);
if(numel(files)>4)
    sliderStep = [1, 1] / (numel(files) - 0);
    set(handles.browserImageSlider,'min',0);
    set(handles.browserImageSlider,'max',numel(files));
    set(handles.browserImageSlider,'SliderStep',sliderStep);
    set(handles.browserImageSlider,'Enable','on');
else
    set(handles.browserImageSlider,'Enable','off');
end
guidata(handles.figure1, handles);

function [fileNames] = getImageFilesInDirectory(handles)
if(isfield(handles,'fileNames'))
    fileNames = handles.fileNames;
else
    fileNames = {};
end


function updateFileList(handles)
handles = guidata(handles.figure1);
inputDir = getInputPathString(handles);

% From http://stackoverflow.com/questions/6385531/very-slow-dir-in-matlab
% Much, much faster than dir()
cellf = @(fun, arr) cellfun(fun, num2cell(arr), 'uniformoutput',0);

if(ismac && isdeployed)
    fileNames = dir(inputDir);
    fileNames = {fileNames.name};
else
    fileNames = cellf(@(f) char(f.toString()), java.io.File(inputDir).list());
end

startImage = str2double(get(handles.startingImage,'string'));
skipImages = str2double(get(handles.filterSkip,'string'));

idx = zeros(numel(fileNames));

for i=1:numel(fileNames)
    found = strfind(fileNames{i},['.',get(handles.extension,'String')]);
    if(numel(found)>0)
        idx(i)=1;
    end
end

fileNames = fileNames(logical(idx));

fileNames = fileNames(startImage:skipImages:end);

set(handles.numberOfImagesInInputPath,'String',num2str(numel(fileNames)));

handles.fileNames = fileNames;

guidata(handles.figure1,handles);

function inputPath = getInputPathString(handles)
inputPath = get(handles.inputFolderPath,'String');


% --- Executes on key press with focus on inputFolderPath and none of its controls.
function inputFolderPath_KeyPressFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to inputFolderPath (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if(strcmp(eventdata.Key,'return'))

end

function inputFolderPath_CallBack(object, eventdata, handles)
    %guidata(handles.figure1,handles);
    %'jm'


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(~, ~, handles) %#ok<DEFNU>
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.MainClass.livePreviewing)
    delete(handles.MainClass.livePreviewFigure)
end
delete(handles.MainClass)
delete(handles.SettingsWindow);
clear handles.MainClass;

% --- Executes on slider movement.
function browserImageSlider_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to browserImageSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateImageBrowser(round(get(hObject,'Value')),handles);

function showFullScreenImage(originalAxesHandle)
hFigureImage=figure('units','normalized','outerposition',[0 0 1 1]);
hAxesImage=axes('Parent',hFigureImage);
hImage=imshow(getimage(originalAxesHandle),'Parent',hAxesImage);

copyobj(allchild(originalAxesHandle),hAxesImage);

children = allchild(hAxesImage);

% Make sure that none of the children can raise a callback
for i=1:numel(children)
    set(children(i),'HitTest','off')
end

%export_fig('g.png','-native');

% Set the callback
set(hFigureImage,'ButtonDownFcn',@fullScreenCallback);


function fullScreenCallback(object,~)
close(get(get(object,'Parent'),'CurrentFigure'))

function imagePreviewCallback(object,~)
handles=guidata(get(get(object,'Parent'),'Parent'));
showFullScreenImage(handles.imagePreview);

function imagePreviewCallbackResult(object,~)
handles=guidata(get(get(object,'Parent'),'Parent'));
showFullScreenImage(handles.axes1);

function btn_Settings_Callback(~, ~, handles)
set(handles.SettingsWindow,'Visible','on');

% --- Executes during object creation, after setting all properties.
function imagesInDirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imagesInDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filterSkip_Callback(hObject, eventdata, handles)
% hObject    handle to filterSkip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterSkip as text
%        str2double(get(hObject,'String')) returns contents of filterSkip as a double


% --- Executes during object creation, after setting all properties.
function filterSkip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterSkip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startingImage_Callback(hObject, eventdata, handles)
% hObject    handle to startingImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startingImage as text
%        str2double(get(hObject,'String')) returns contents of startingImage as a double


% --- Executes during object creation, after setting all properties.
function startingImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startingImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function browserImageSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to browserImageSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function inputFolderPath_Callback(hObject, eventdata, handles)
% hObject    handle to inputFolderPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputFolderPath as text
%        str2double(get(hObject,'String')) returns contents of inputFolderPath as a double
updateFileList(handles);
updateFilesDropdownMenu(handles);
setImageBrowser(handles);
updateImageBrowser(0,handles);
handles = guidata(handles.figure1);
if(size(handles.fileNames,1) > 1)
    previewImageFromList(1,handles);
end

% --- Executes during object creation, after setting all properties.
function inputFolderPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputFolderPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over analysisButton.
function analysisButton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to analysisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over btn_Settings.
function btn_Settings_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to btn_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uipanel5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function extension_Callback(hObject, eventdata, handles)
% hObject    handle to extension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of extension as text
%        str2double(get(hObject,'String')) returns contents of extension as a double


% --- Executes during object creation, after setting all properties.
function extension_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over inputFolderPath.
function inputFolderPath_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to inputFolderPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btn_exportImage.
function btn_exportImage_Callback(hObject, eventdata, handles)
% hObject    handle to btn_exportImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% copyobj(allchild(handles.axes1),handles.hAxesImage);
% 
% children = allchild(hAxesImage);
% 
% % Make sure that none of the children can raise a callback
% for i=1:numel(children)
%     set(children(i),'HitTest','off')
% end

[filename, pathname] = uiputfile({'*.pdf';'*.png';'*.tif'},'Export as');
if(filename~=0)
    hFigureImage=figure('Visible','off');
    hAxesImage=axes('Parent',hFigureImage);
    hImage=imshow(getimage(handles.axes1),'Parent',hAxesImage);
    
    copyobj(allchild(handles.axes1),hAxesImage);
    
    export_fig(fullfile(pathname,filename),'-native',hAxesImage);
    
    delete(hAxesImage);
    delete(hFigureImage);
end
