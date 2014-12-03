function varargout = OptimizerUI(varargin)
% OPTIMIZERUI MATLAB code for OptimizerUI.fig
%      OPTIMIZERUI, by itself, creates a new OPTIMIZERUI or raises the existing
%      singleton*.
%
%      H = OPTIMIZERUI returns the handle to a new OPTIMIZERUI or the handle to
%      the existing singleton*.
%
%      OPTIMIZERUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTIMIZERUI.M with the given input arguments.
%
%      OPTIMIZERUI('Property','Value',...) creates a new OPTIMIZERUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OptimizerUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OptimizerUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OptimizerUI

% Last Modified by GUIDE v2.5 18-Jul-2013 12:43:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OptimizerUI_OpeningFcn, ...
                   'gui_OutputFcn',  @OptimizerUI_OutputFcn, ...
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


% --- Executes just before OptimizerUI is made visible.
function OptimizerUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OptimizerUI (see VARARGIN)

% Choose default command line output for OptimizerUI
handles.output = hObject;

handles.OptimizeClass = varargin{1};

set(handles.axes_param1,'xtick',[],'ytick',[]);
set(handles.axes_param2,'xtick',[],'ytick',[]);
set(handles.axes_param3,'xtick',[],'ytick',[]);
set(handles.axes_Image,'xtick',[],'ytick',[])

xlabel(handles.axes_cost,'Iteration');
ylabel(handles.axes_cost,'F-Value');
xlim(handles.axes_cost,[0 1]);

set(handles.axes_param1,'ytick',[]);
ylabel(handles.axes_param1,'Sigma');
set(handles.axes_param2,'ytick',[]);
ylabel(handles.axes_param2,'Epsilon');
set(handles.axes_param3,'ytick',[]);
ylabel(handles.axes_param3,'Ratio');

handles.OptimizeClass.selectedMethod = 1;
set(handles.lst_screeningType,'Enable','off');

guidata(hObject, handles);

function newProject(handles)
handles.OptimizeClass.project = Project();
enableControls(handles);
updateList(handles);

function enableControls(handles)
set(handles.btn_addImage,'Enable','on')
set(handles.btn_removeImage,'Enable','on');
set(handles.btn_edit,'Enable','on');
set(handles.btn_GO,'Enable','on');
set(handles.radio_Screening,'Enable','on');
set(handles.radio_Auto,'Enable','on');

function index = optimise(handles)
handles.OptimizeClass.project.images(1).results;

for i=1:numel(handles.OptimizeClass.project.images)
    if(i==1)
        allResults = handles.OptimizeClass.project.images(i).results;
    else
        allResults = allResults + handles.OptimizeClass.project.images(i).results;
    end
end

TP = allResults(:,6);
FP = allResults(:,7);
TN = allResults(:,8);
FN = allResults(:,9);
P = TP + FN;
MCC = (TP.*TN-FP.*FN)./sqrt((TP+FP).*(TP+FN).*(TN+FP).*(TN+FN));
Fvalue=2.*TP./(FP+TP+P);
[b,index] = max(MCC);
[a,index2] = max(Fvalue);
%allResults = [allResults, (1:size(allResults,1))'];

%allResults_sorted = sortrows(allResults,-1);


%allResults(:,12)

function updateView(handles)
imageMode = get(handles.lst_ImageMode,'value');
selectedImage = handles.OptimizeClass.project.images(get(handles.lst_Images,'Value'));

switch(imageMode)
    case 1
        imshow(selectedImage.pc,'Parent',handles.axes_Image);
                    
            %gaga = handles.OptimizeClass.project.results;
            %save('yap.mat','gaga');
            %'hh'
    case 2
        if(ndims(selectedImage.pc)>2)
            sizePC = size(rgb2gray(selectedImage.pc));
        else
            sizePC = size(selectedImage.pc);
        end

        imshow(selectedImage.pc,'Parent',handles.axes_Image);

        hold(handles.axes_Image)
        for i=1:size(selectedImage.classMasks,1)
            
            if(i==1)
                colorImage = im2uint8(cat(3, zeros(sizePC),ones(sizePC), zeros(sizePC)));
            else    
                colorImage = im2uint8(cat(3, ones(sizePC),zeros(sizePC), zeros(sizePC)));
            end
            
            %I = zeros(sizePC);
            mask = reshape(selectedImage.classMasks(i,:,:),sizePC);

            h=imshow(colorImage,'Parent',handles.axes_Image);

            set(h, 'AlphaData', mask*0.5);

        end
        
        hold(handles.axes_Image)

    case 3
        % Need to do some Java black magic in order to retrieve the correct
        % iteration ID after sorting to the table
        jscrollpane = findjobj(handles.tbl_Results);       
        jtable = jscrollpane.getViewport.getView;

    
        selectedIter = jtable.getValueAt(jtable.getSelectedRow(),0);
        selectedIter = str2double(['',selectedIter]);

        
        parameters = handles.OptimizeClass.project.results(selectedIter,3:end);
        parameters
        J = localContrast(selectedImage.pc, parameters(1),parameters(2));
        K = haloRemoval(selectedImage.pc,J,325,'kirsch',25,parameters(3));
        %[~,K] = Topman_DetermineConfluency(selectedImage.pc,parameters(1),parameters(2),parameters(3));
        %K=~K;
        %h=imshow(K,'Parent',handles.axes_Image);
        displayBorderImage(selectedImage.pc,K,'white',1.5,handles.axes_Image);
    otherwise
        imshow(selectedImage.pc,'Parent',handles.axes_Image);
end


function createImageFromFile(handles,path)
image = Image(path);
handles.OptimizeClass.project.images(end+1) = image;
%addToList(handles,image);
updateList(handles);

function updateList(handles)
images = handles.OptimizeClass.project.images;
imageString = {};
for i=1:numel(images)
    imageString = [imageString,{images(i).name}];
end
set(handles.lst_Images,'String',imageString);


function removeFromList(handles,idx)
% Remove from project
handles.OptimizeClass.project.images(idx) = [];
set(handles.lst_Images, 'value', 1);
updateList(handles);


function loadProjectFromFile(handles,path)
load(path,'project');
handles.OptimizeClass.project = project;
clear('project');

if(~isempty(handles.OptimizeClass.project.results))
    set(handles.tbl_Results,'Data',handles.OptimizeClass.project.results);
    handles.OptimizeClass.makeResultTableSortable();
end
enableControls(handles);
updateList(handles);

%handles.OptimizeClass.project = Project();
%createImageFromFile(handles,'D:\Dropbox\complex\phd\Code\MATLAB\Optimiser\nolif_1_2.tif');
%createImageFromFile(handles,'D:\Dropbox\complex\phd\results\Differentiation\12052013\lif_1_2.tif');
%createImageFromFile(handles,'D:\Dropbox\complex\phd\results\Differentiation\12052013\lif_2_2.tif');
% Update handles structure

% --- Outputs from this function are returned to the command line.
function varargout = OptimizerUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lst_Images.
function lst_Images_Callback(hObject, eventdata, handles)
% hObject    handle to lst_Images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lst_Images contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_Images

%contents{get(hObject,'Value')}
%get(hObject)

if(~isempty(cellstr(get(hObject,'string'))))
    updateView(handles)
end

% --- Executes during object creation, after setting all properties.
function lst_Images_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_Images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_addImage.
function btn_addImage_Callback(hObject, eventdata, handles)
% hObject    handle to btn_addImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile({'*.jpg;*.tif;*.png','Support image files (*.jpg,*.tif,*.png)'},'Select image file to add to project')

if(FileName~=0)
    createImageFromFile(handles,fullfile(PathName,FileName));
end


% --- Executes on button press in btn_removeImage.
function btn_removeImage_Callback(hObject, eventdata, handles)
% hObject    handle to btn_removeImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
removeFromList(handles,get(handles.lst_Images,'Value'));

% --- Executes on button press in btn_edit.
function btn_edit_Callback(hObject, eventdata, handles)
% hObject    handle to btn_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PainterUI(handles.OptimizeClass.project.images(get(handles.lst_Images,'Value')));

% --- Executes on button press in btn_GO.
function btn_GO_Callback(hObject, eventdata, handles)
% hObject    handle to btn_GO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(handles.OptimizeClass.selectedMethod == 1)
    handles.OptimizeClass.automatedOptimisation();
else
    handles.OptimizeClass.screeningOptimisation();
end

%project = handles.OptimizeClass.project;
%project.results
%save('projetTest.mat','project','-v7');


% --- Executes on button press in btn_Optimise.
function btn_Optimise_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Optimise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

optimise(handles);


% --- Executes on selection change in lst_ImageMode.
function lst_ImageMode_Callback(hObject, eventdata, handles)
% hObject    handle to lst_ImageMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lst_ImageMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_ImageMode
updateView(handles);

% --- Executes during object creation, after setting all properties.
function lst_ImageMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_ImageMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_auto.
function btn_auto_Callback(hObject, eventdata, handles)
% hObject    handle to btn_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.OptimizeClass.automatedOptimisation();


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(handles.OptimizeClass);
delete(hObject);


% --- Executes on button press in btn_newProject.
function btn_newProject_Callback(hObject, eventdata, handles)
% hObject    handle to btn_newProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newProject(handles);

% --- Executes on button press in btn_loadProject.
function btn_loadProject_Callback(hObject, eventdata, handles)
% hObject    handle to btn_loadProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile({'*.mat','Optimisation project file'},'Select the optimization project file to load');

if(FileName~=0)
    loadProjectFromFile(handles,fullfile(PathName,FileName));
end

% --- Executes on button press in btn_saveProject.
function btn_saveProject_Callback(hObject, eventdata, handles)
% hObject    handle to btn_saveProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uiputfile({'*.mat','Optimisation project file'},'Select location to save optimization project file');

project = handles.OptimizeClass.project;
if(FileName~=0)
    save(fullfile(PathName,FileName),'project');
    project.results
end


% --- Executes on button press in btn_Stop.
function btn_Stop_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.OptimizeClass.stopping = true;


% --- Executes when entered data in editable cell(s) in tbl_Results.
function tbl_Results_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tbl_Results (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when selected cell(s) is changed in tbl_Results.
function tbl_Results_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to tbl_Results (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
indices = eventdata.Indices;

if(~isempty(indices))
    index = indices(1);

    jscrollpane = findjobj(handles.tbl_Results);       
    jtable = jscrollpane.getViewport.getView;


    selectedIter = jtable.getValueAt(jtable.getSelectedRow(),0);
    selectedIter = str2double(['',selectedIter]);

    handles.selectedParameters = handles.OptimizeClass.project.results(selectedIter,3:end);
end

guidata(handles.figure1,handles);



% --- Executes when selected object is changed in pnl_Optimization.
function pnl_Optimization_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in pnl_Optimization 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(get(eventdata.NewValue,'Tag'),'radio_Auto'))
    handles.OptimizeClass.selectedMethod = 1;
    set(handles.lst_screeningType,'Enable','off');
else
    handles.OptimizeClass.selectedMethod = 2;
    set(handles.lst_screeningType,'Enable','on');
end

% --- Executes during object creation, after setting all properties.
function pnl_Optimization_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pnl_Optimization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_screeningType.
function lst_screeningType_Callback(hObject, eventdata, handles)
% hObject    handle to lst_screeningType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lst_screeningType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_screeningType


% --- Executes during object creation, after setting all properties.
function lst_screeningType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_screeningType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btn_setCurrent.
function btn_setCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to btn_setCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedParameters