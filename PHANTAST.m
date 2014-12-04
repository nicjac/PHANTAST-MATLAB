classdef PHANTAST < handle
    %PHANTAT entry point
    
    properties
        images = {};
        processedImages = {};
        results = {};
        resultsHeaders = {};
        mainFigure = [];
        mlFigure = 0;
        MLTrainingSets;
        MLTrainingSegParameters;
        MLTrainingMLParameters;
        MLTrainingSetUniqueId;
        MLTrainingSetDescription;
        MLTestingSets;
        MLTestingSegParameters;
        MLTestingMLParameters;
        MLTestingSetUniqueId;
        MLTestingSetDescription;
        model;
        livePreviewImage;
        livePreviewFigure;
        axesPreviewFigure;
        h_livePreviewImage;
        livePreviewing=false;
        optimizer;
    end
    
    methods
        function obj=PHANTAST(obj)
            [pathstr,name,ext] = fileparts(mfilename('fullpath'));
            addpath(genpath(pathstr));
            obj.mainFigure=PHANTAST_MainGUI(obj);
        end
        
        function obj=saveTrainingSet(obj)
            mlFigureHandles = guidata(obj.mlFigure);
            [file,path] = uiputfile('*.mat','Save training set as');
            trainingSetToSave = obj.MLTrainingSets;
            trainingSetDescription = get(mlFigureHandles.trainingSetDescription,'String');
            MLTrainingSegParameters = obj.MLTrainingSegParameters;
            MLTrainingMLParameters = obj.MLTrainingMLParameters;
            MLTrainingSetUniqueId = obj.MLTrainingSetUniqueId;
            save(fullfile(path,file),'trainingSetToSave','trainingSetDescription','MLTrainingSegParameters','MLTrainingMLParameters','MLTrainingSetUniqueId');
        end
        
        function obj=loadTrainingSet(obj)
            [filename,path] = uigetfile('*.mat','Open training set');
            trainingSetFile = fullfile(path,filename);
            load(trainingSetFile,'trainingSetToSave','trainingSetDescription','MLTrainingSegParameters','MLTrainingMLParameters','MLTrainingSetUniqueId');
            obj.MLTrainingSetUniqueId = MLTrainingSetUniqueId;
            obj.MLTrainingSetDescription = trainingSetDescription;
            obj.MLTrainingSets = trainingSetToSave;
            obj.MLTrainingSegParameters = MLTrainingSegParameters;
            obj.MLTrainingMLParameters = MLTrainingMLParameters;
            obj.pushPresets(obj.MLTrainingSegParameters);
            obj.pushMLPresets(obj.MLTrainingMLParameters);
        end
        
        function obj=saveTestingSet(obj)
            mlFigureHandles = guidata(obj.mlFigure);
            [file,path] = uiputfile('*.mat','Save testing set as');
            testingSetsToSave = obj.MLTestingSets;
            testingSetDescription = get(mlFigureHandles.testingSetDescription,'String');
            MLTestingSegParameters = obj.MLTestingSegParameters;
            MLTestingMLParameters = obj.MLTestingMLParameters;
            MLTestingSetUniqueId = obj.MLTestingSetUniqueId;
            save(fullfile(path,file),'testingSetsToSave', 'testingSetDescription','MLTestingSegParameters','MLTestingMLParameters','MLTestingSetUniqueId');
        end
        
        function obj=loadTestingSet(obj)
            [filename,path] = uigetfile('*.mat','Open testing set');
            trainingSetFile = fullfile(path,filename);
            load(trainingSetFile,'testingSetsToSave', 'testingSetDescription','MLTestingSegParameters','MLTestingMLParameters','MLTestingSetUniqueId');
            obj.MLTestingSets = testingSetsToSave;
            obj.MLTestingSetUniqueId = MLTestingSetUniqueId;
            obj.MLTestingSetDescription = testingSetDescription;
            obj.MLTestingSegParameters = MLTestingSegParameters;
            obj.MLTestingMLParameters = MLTestingMLParameters;
            obj.pushPresets(obj.MLTestingSegParameters);
            obj.pushMLPresets(obj.MLTestingMLParameters);
        end
        
        function obj=savePresets(obj)
            [file,path] = uiputfile('*.mat','Save presets as');
            savedPresets = obj.getParamValues();
            save(fullfile(path,file),'savedPresets');
        end
        
        % Retrieve segmentation parameters
        function savedPresets=getParamValues(obj)
            handles = guidata(obj.mainFigure);
            handles = guidata(handles.SettingsWindow);
            fields = fieldnames(handles);
            for i=1:numel(fields)
                if(numel(strfind(fields{i},'param_')))
                    fieldType = get(handles.(fields{i}),'Style');
                    if(strcmp(fieldType,'edit'))
                        savedPresets.(fields{i}) = get(handles.(fields{i}),'String');
                    elseif(strcmp(fieldType,'checkbox'))
                        savedPresets.(fields{i}) = get(handles.(fields{i}),'Value');
                    elseif(strcmp(fieldType,'popupmenu'))
                        savedPresets.(fields{i}) = get(handles.(fields{i}),'Value');
                    else
                        error(['unknown field type!   ', fieldType]);
                    end
                end
            end
        end
        
        % Retrive ML parameters
        function savedPresets=getMLParamValues(obj)
            handles = guidata(obj.mlFigure);
            fields = fieldnames(handles);
            for i=1:numel(fields)
                if(numel(strfind(fields{i},'param_')))
                    fieldType = get(handles.(fields{i}),'Style');
                    if(strcmp(fieldType,'edit'))
                        savedPresets.(fields{i}) = get(handles.(fields{i}),'String');
                    elseif(strcmp(fieldType,'checkbox'))
                        savedPresets.(fields{i}) = get(handles.(fields{i}),'Value');
                    elseif(strcmp(fieldType,'popupmenu'))
                        savedPresets.(fields{i}) = get(handles.(fields{i}),'Value');
                    else
                        error(['unknown field type!   ', fieldType]);
                    end
                end
            end
        end
        
        
        function obj=loadPresets(obj)
            [filename,path] = uigetfile('*.mat','Open presets');
            presetFile = fullfile(path,filename);
            load(presetFile,'savedPresets');
            obj.pushPresets(savedPresets);
        end
        
        function obj=loadDefaults(obj)
            load('defaultSettings.mat','savedPresets');
            obj.pushPresets(savedPresets);
        end
        
        % Push presets to the UI
        function obj=pushPresets(obj,savedPresets)
            handles = guidata(obj.mainFigure);
            handles = guidata(handles.SettingsWindow);
            fields = fieldnames(savedPresets);
            
            for i=1:numel(fields)
                if(numel(strfind(fields{i},'param_')))
                    fieldType = get(handles.(fields{i}),'Style');
                    if(strcmp(fieldType,'edit'))
                        set(handles.(fields{i}),'String',savedPresets.(fields{i}));
                    elseif(strcmp(fieldType,'checkbox'))
                        set(handles.(fields{i}),'Value',savedPresets.(fields{i}));
                    elseif(strcmp(fieldType,'popupmenu'))
                        set(handles.(fields{i}),'Value',savedPresets.(fields{i}));
                    else
                        error(['unknown field type!   ', fieldType]);
                    end
                end
            end
        end
        
        % Push ML-specific stuff to the UI
        function obj=pushMLPresets(obj,savedPresets)
            handles = guidata(obj.mlFigure);
            fields = fieldnames(savedPresets);
            obj.MLTrainingSetUniqueId
            
            if(get(handles.setSelectionPane,'SelectedObject')==handles.trainingRadioButton)
                set(handles.trainingSetUniqueID,'String',obj.MLTrainingSetUniqueId);
                set(handles.trainingSetDescription,'String',obj.MLTrainingSetDescription);
            else
                set(handles.testingSetUniqueID,'String',obj.MLTestingSetUniqueId);
                set(handles.testingSetDescription,'String',obj.MLTestingSetDescription);
            end
            
            for i=1:numel(fields)
                if(numel(strfind(fields{i},'param_')))
                    fieldType = get(handles.(fields{i}),'Style');
                    if(strcmp(fieldType,'edit'))
                        set(handles.(fields{i}),'String',savedPresets.(fields{i}));
                    elseif(strcmp(fieldType,'checkbox'))
                        set(handles.(fields{i}),'Value',savedPresets.(fields{i}));
                    elseif(strcmp(fieldType,'popupmenu'))
                        set(handles.(fields{i}),'Value',savedPresets.(fields{i}));
                    else
                        error(['unknown field type!   ', fieldType]);
                    end
                end
            end
        end
        
        function settingsUpdated(obj)
            if(obj.livePreviewing)
                J = obj.processImage(obj.livePreviewImage);
                displayBorderImage(obj.livePreviewImage,J,'white',2,obj.axesPreviewFigure);
            end
        end
        
        function startLivePreview(obj,I)
            obj.livePreviewImage = I;
            obj.livePreviewFigure = figure('CloseRequestFcn',@obj.liveCloseFn);
            obj.axesPreviewFigure = axes('Parent',obj.livePreviewFigure);
            obj.h_livePreviewImage = imshow(I,'Parent',obj.axesPreviewFigure);
            obj.livePreviewing = true;
            obj.settingsUpdated(); % Force a first update!
            handles = guidata(obj.mainFigure);
            set(handles.SettingsWindow,'visible','on');
            
        end
        
        function liveCloseFn(obj,event,~)
            delete(event);
            obj.livePreviewing = false;
        end
        
        function [outputImage,distanceToNearestBlob] = processImage(obj,I)
            
            handles = guidata(obj.mainFigure);
            handleSettings = guidata(handles.SettingsWindow);
            
            %singleImageRadioButton = get(handles.singleImageRadioButton,'Value');
            doContrastStretching = get(handleSettings.param_contrastStretchingCheckBox,'Value');
            contrastStretchingSaturation = str2double(get(handleSettings.param_contrastStretchingSaturation,'String'));
            sigma = str2double(get(handleSettings.param_sigma,'String'));
            epsilon = str2double(get(handleSettings.param_epsilon,'String'));
            doHaloRemoval = get(handleSettings.param_haloRemovalCheckBox,'Value');
            minimumFillArea = str2double(get(handleSettings.param_minimumFillArea,'String'));
            doRemoveSmallObjects = get(handleSettings.param_removeSmallObjectCheckbox,'Value');
            minimumObjectArea = str2double(get(handleSettings.param_minimumObjectArea,'String'));
            doRescale = get(handleSettings.param_rescaleCheckbox,'Value');
            HRremoveSmallObjects = str2double(get(handleSettings.param_HRremoveSmallObjects,'String'));
            maxRemovalRatio = str2double(get(handleSettings.param_maxRemovalRatio,'String'));
            doAdditionalRemoveHoles = get(handleSettings.param_removeHolesAddCheckbox,'Value');
            additionalHoleFillArea = str2double(get(handleSettings.param_additionalHoleFillArea,'String'));
            doDensityEstimation = get(handleSettings.param_doDensityEstimation,'Value');
            saveSegmentedImages = get(handleSettings.param_saveSegmentedImages,'Value');
            doTidyUp = get(handleSettings.param_tidyUpBinaryImage,'Value');
            
            I_org = I;
            
            if(doContrastStretching)
                I = contrastStretching(I,contrastStretchingSaturation);
            end
            
            J = localContrast(I,sigma,epsilon);
            
            if(doHaloRemoval)
                J = haloRemoval(I,J,minimumFillArea,'kirsch',HRremoveSmallObjects,maxRemovalRatio);
            end
            
            % If we want to remove Holes
            if(doAdditionalRemoveHoles)
                J = removeHoles(J,additionalHoleFillArea);
            end
            
            if(doRemoveSmallObjects)
                J = removeSmallObjects(J,minimumObjectArea);
            end
            
            % Note: this is done automatically by removalHaloGradient
            if(doTidyUp)
                J = bwmorph2(J,'majority',20);
                J = bwmorph(J,'clean');
            end
            
            
            if(doDensityEstimation)
                
                BIFsigma = 4;
                BIFepsilon = 0;
                
                % Density Estimation stuff
                BIF4Blobs = computeBIFs(contrastStretching(I,0.5),BIFsigma,BIFepsilon);
                
                BIF4Blobs(~J)=0;
                
                BIFblobs = filterBIFs(BIF4Blobs,[4],true);
                CCblobs = bwconncomp(BIFblobs);
                statsBlobs = regionprops(CCblobs,'PixelIdxList','Centroid','PixelList');
                
                % BIF Blobs Centroid neighbours
                centroids = round(vertcat(statsBlobs.Centroid));
                centroidIndices = sub2ind(size(I),centroids(:,2),centroids(:,1));
                centroidImage = zeros(size(I));
                centroidImage(centroidIndices)=1;
                
                distanceToNearestBlob = mean2(bwdist(centroidImage));
            else
                distanceToNearestBlob = 0;
            end
            
            outputImage = J;
            
        end
    end
    
    
end

