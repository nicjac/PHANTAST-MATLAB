function varargout = ExploreResults(varargin)
% EXPLORERESULTS MATLAB code for ExploreResults.fig
%      EXPLORERESULTS, by itself, creates a new EXPLORERESULTS or raises the existing
%      singleton*.
%
%      H = EXPLORERESULTS returns the handle to a new EXPLORERESULTS or the handle to
%      the existing singleton*.
%
%      EXPLORERESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPLORERESULTS.M with the given input arguments.
%
%      EXPLORERESULTS('Property','Value',...) creates a new EXPLORERESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExploreResults_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExploreResults_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExploreResults

% Last Modified by GUIDE v2.5 02-Jul-2013 10:43:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExploreResults_OpeningFcn, ...
                   'gui_OutputFcn',  @ExploreResults_OutputFcn, ...
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


% --- Executes just before ExploreResults is made visible.
function ExploreResults_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExploreResults (see VARARGIN)

% Choose default command line output for ExploreResults
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
mainHandles = varargin{1};

%varargin{1}

handles.MainClass = mainHandles.MainClass;
guidata(hObject, handles);

handles.currentOverlay=2;
handles.currentImageIdx = 1;
guidata(hObject, handles);
updateImageOverlay(get(handles.uipanel1,'SelectedObject'),handles);
set(handles.exploreResultsTable,'ColumnName',handles.MainClass.resultsHeaders);
set(handles.exploreResultsTable,'Data',handles.MainClass.results);
%imshow(gaga,'Parent', handles.resultsAxes)
% UIWAIT makes ExploreResults wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ExploreResults_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function exploreResultsTable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to exploreResultsTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eventdata


% --- Executes when selected cell(s) is changed in exploreResultsTable.
function exploreResultsTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to exploreResultsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
imageIdx = eventdata.Indices(1);
handles.currentImageIdx = imageIdx;
guidata(hObject, handles);
refreshImage(handles);

% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
updateImageOverlay(eventdata.NewValue,handles);

function image = getCurrentImage(handles)
currentIdx = handles.currentImageIdx;

if(handles.currentOverlay==1 | handles.currentOverlay==3)
    %image = handles.MainClass.images(currentIdx,1,:,:);
    image = handles.MainClass.images{currentIdx};
    %image = reshape(image,size(image,3),size(image,4));
elseif(handles.currentOverlay==2)
    image = handles.MainClass.processedImages{currentIdx};
    %image = logical(reshape(image,size(image,3),size(image,4)));
end

function updateImageOverlay(newSelection,handles)
if(newSelection==handles.rawImageButton)
    handles.currentOverlay=1;
elseif(newSelection==handles.binaryMaskButton)
    handles.currentOverlay=2;
elseif(newSelection==handles.rawImageWithContoursButton)
    handles.currentOverlay=3;
end

guidata(handles.figure1,handles);
refreshImage(handles);



function binaryImage = getBinaryImage(handles)
currentIdx = handles.currentImageIdx;
%binaryImage = handles.MainClass.images(currentIdx,2,:,:);
binaryImage = handles.MainClass.processedImages{currentIdx};
%binaryImage = reshape(binaryImage,size(binaryImage,3),size(binaryImage,4));

function refreshImage(handles)
image = getCurrentImage(handles);
imshow(getCurrentImage(handles), 'Parent', handles.resultsAxes);
if(handles.currentOverlay==3)
    hold on;
    [B,~] = bwboundaries(getBinaryImage(handles),8);
    for k = 1:numel(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 1.5,'Parent', handles.resultsAxes)
    end
    hold off;
    
    %export_fig('Eloy.tif',handles.resultsAxes)

end
    
    
