classdef Optimizer < handle
    %OPTIMIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        optimizerFigure;
        currentAutoOptimisationHistoric;
        optimisationMonitoringFigure;
        project;
        stopping = false;
        selectedRow;
        iter;
        selectedMethod;
        optimizationStartTime;
    end
    
    methods
        function obj = Optimizer(obj)
            obj.optimizerFigure = OptimizerUI(obj);
        end
        
        function update_waitbar(obj,value)
            handles = guidata(obj.optimizerFigure);
            h=handles.axes_waitbar;
            set(h,'Visible','On');
            axes(h);
            cla;
            h=patch([0,value,value,0],[0,0,1,1],[ 1.0000    0.6941    0.3922]);
            axis([0,1,0,1]);
            axis off;
        end
        
        function obj = automatedOptimisation(obj)
            obj.makeResultTableSortable();
            %obj.optimisationMonitoringFigure = OptimisationMonitoringUI();
            %handlesMonitoring = guidata(obj.optimisationMonitoringFigure);
            %obj.optimisationMonitoringAxes = axes('Parent',obj.optimisationMonitoringFigure);
            obj.currentAutoOptimisationHistoric = [];
            %plot(obj.currentAutoOptimisationHistoric,'Parent',handlesMonitoring.axes_cost);
            pause(0.1);
            %options = [];
            options = psoptimset('OutputFcns', @obj.updateAutoOptimisation);
            obj.iter = 0;
            
            handles = guidata(obj.optimizerFigure);
            set(handles.btn_Stop,'Enable','on');
            
            [x,fval,exitflag] = patternsearch(@obj.costProcessing,[1,0.1, 0.7],[],[],[],[],[0.01 0 0],[5,1,1],options)
            obj.project.results = obj.currentAutoOptimisationHistoric;
            set(handles.btn_Stop,'Enable','off');
        end
        
        function makeResultTableSortable(obj)
            handles = guidata(obj.optimizerFigure);
            
            set(handles.tbl_Results, 'ColumnName',{'Iteration','F-Value','Sigma','Epsilon','Ratio'});
            
            % Set the table as sortable
            jscrollpane = findjobj(handles.tbl_Results);
            jtable = jscrollpane.getViewport.getView;

            % Now turn the JIDE sorting on
            jtable.setSortable(true);		% or: set(jtable,'Sortable','on');
            jtable.setAutoResort(true);
            jtable.setMultiColumnSortable(true);
            jtable.setPreserveSelectionsAfterSorting(true);
        end
        
        function screeningOptimisation(obj)
            
            handles = guidata(obj.optimizerFigure);
            
            screeningType = get(handles.lst_screeningType,'Value');
            
            set(handles.btn_Stop,'Enable','on');
            
            switch(screeningType)
                
                case 1
                    epsilons = 0.1:0.05:0.3;
                    sigmas = 0.1:0.3:2;
                    ratios = 0:0.2:1;
                    
                case 2
                    epsilons = 0.1:0.03:0.3;
                    sigmas = 0.1:0.2:2;
                    ratios = 0:0.1:1; 
                    
                case 3
                    epsilons = 0.1:0.01:0.3;
                    sigmas = 0.1:0.2:2;
                    ratios = 0.1:0.1:1;
            end
            
            %small = 1:2:51;
            %big = 1:2:51;
            %threshold = 0.01:0.005:0.06;
            
            [p,q,z] = meshgrid(sigmas, epsilons,ratios);
            %[p,q,z] = meshgrid(small, big,threshold);
            pairs = [p(:) q(:) z(:)];
            
            results = [];
            
            totalSteps = size(pairs,1)*numel(obj.project.images);
            
            count = 0;
            
            obj.optimizationStartTime = clock();
            
            for j =1:size(pairs,1)
                if(obj.stopping)
                    obj.stopping =false;
                    break;
                end
                %j
                pairResults = [];
                for i=1:numel(obj.project.images)
                    count = count+1;
                    %i      
                    imageObject = obj.project.images(i);
                    
                    if(ndims(imageObject.pc)>2)
                        sizePC = size(rgb2gray(imageObject.pc));
                    else
                        sizePC = size(imageObject.pc);
                    end
                    
                    maskClass1 = reshape(imageObject.classMasks(1,:,:),sizePC);
                    maskClass2 = reshape(imageObject.classMasks(2,:,:),sizePC);
                    
                    maskClass1(logical(maskClass2)) = 0;
                    
                    
                    I = imageObject.pc;
                    
                    labeledPixels = logical(maskClass1 | maskClass2);
                    
                    GT = zeros(size(maskClass1));
                    GT(logical(maskClass1)) = 1;
                    
                    GT_labeled = GT(labeledPixels);
                    

                    %[~,K] = Topman_DetermineConfluency(I,pairs(j,1),pairs(j,2),pairs(j,3));
                    %K=~K;
                    K=obj.processImage(I,pairs(j,1),pairs(j,2),pairs(j,3));
                    
                    K_labeled = K(labeledPixels);
                    [Fvalue,precision,recall,accuracy,JaccardIndex,TP,FP,TN,FN,FPrate,TPrate,MCC] = compareBinaryImages(GT_labeled,K_labeled);
                    pairResults(i,:) = [Fvalue,precision,recall,accuracy,JaccardIndex,TP,FP,TN,FN,FPrate,TPrate,MCC];
                    
                    obj.update_waitbar(count/totalSteps);
                end
                
                results(j,:) = [j,mean(pairResults(i,1)),pairs(j,1),pairs(j,2),pairs(j,3)];
                
                rate=etime(clock(),obj.optimizationStartTime)/j;
                
                remaining=(size(pairs,1)-j)*rate;
                set(handles.txt_timeRemaining,'String',[num2str(remaining/60),' min']);
            end
            
            obj.project.results = results;
            handles = guidata(obj.optimizerFigure);
            set(handles.tbl_Results,'Data',results);
            set(handles.txt_timeRemaining,'String',' DONE!');
            obj.makeResultTableSortable();
            set(handles.btn_Stop,'Enable','off');
        end
        
     

        
        function [stop,options,optchanged] = updateAutoOptimisation(obj,optimvalues,options,flag)
            handles = guidata(obj.optimizerFigure);
            plot(obj.currentAutoOptimisationHistoric(:,2),'Parent',handles.axes_cost);
            scatter(obj.currentAutoOptimisationHistoric(:,3),obj.currentAutoOptimisationHistoric(:,2),'Parent',handles.axes_param1);
            ylim([0,1]);
            scatter(obj.currentAutoOptimisationHistoric(:,4),obj.currentAutoOptimisationHistoric(:,2),'Parent',handles.axes_param2);
            ylim([0,1]);
            scatter(obj.currentAutoOptimisationHistoric(:,5),obj.currentAutoOptimisationHistoric(:,2),'Parent',handles.axes_param3);
            ylim([0,1]);
            
            xlabel(handles.axes_cost,'Iteration');
            ylabel(handles.axes_cost,'F-Value');
           
            set(handles.axes_param1,'ytick',[]);
            ylabel(handles.axes_param1,'Sigma');
            set(handles.axes_param2,'ytick',[]);
            ylabel(handles.axes_param2,'Epsilon');
            set(handles.axes_param3,'ytick',[]);
            ylabel(handles.axes_param3,'Ratio');
            
            set(handles.tbl_Results,'Data',obj.currentAutoOptimisationHistoric);
            
            drawnow();
            
            if(~obj.stopping)
                stop = false;
            else
                stop = true;
                obj.stopping = false;
            end
            
            optchanged = false;
        end
        
        function cost = costProcessing(obj,X)
            obj.iter = obj.iter +1;
            for i=1:numel(obj.project.images)
                imageObject = obj.project.images(i);
                
                if(ndims(imageObject.pc)>2)
                    sizePC = size(rgb2gray(imageObject.pc));
                else
                    sizePC = size(imageObject.pc);
                end
                
                maskClass1 = reshape(imageObject.classMasks(1,:,:),sizePC);
                maskClass2 = reshape(imageObject.classMasks(2,:,:),sizePC);

                maskClass1(logical(maskClass2)) = 0;
                
                labeledPixels = logical(maskClass1 | maskClass2);
                
                GT = zeros(size(maskClass1));
                GT(logical(maskClass1)) = 1;
                
                GT_labeled = GT(labeledPixels);
                I = imageObject.pc;
                K = obj.processImage(I,X(1),X(2),X(3));

                %K = J;
                
                [F,~,~,~,~,~,~,~,~,~,~,MCC]=compareBinaryImages(GT_labeled,K(labeledPixels));
                costs(i) = 1-F;
                
            end
            
            %cost = (2*mean(costs) + 1*std(costs)) / (2+1);
            %mean(costs)
            cost = mean(costs);
            
            obj.currentAutoOptimisationHistoric(end+1,:) = [obj.iter,1-cost,X(1),X(2),X(3)];
            %obj.updateAutoOptimisation();
        end
        
        function K=processImage(obj,I,sigma,epsilon,ratio)
            %I = contrastStretching(I,0.005);
            J = localContrast(I,sigma,epsilon);
            K = haloRemoval(I,J,325,'kirsch',25,ratio);
        end
    end
end

