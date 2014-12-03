function J = haloRemoval(I,binaryImage,maxFillArea,kernelType,smallObjectRemovalArea,deleteRatio)
% REMOVEHALO Correction of halo artefacts on binary masks computed from phase contrast images
% By Nicolas Jaccard ( n.jaccard@ucl.ac.uk )
% License: GPLv2
% Version: 0.1

%tic;
directionOffsets=[
    0,1;...     % EAST 1
    -1,1;...    % NORTH EAST 2 
    -1,0;...    % NORTH 3
    -1,-1;...   % NORTH WEST 4
    0,-1;...    % WEST 5
    1,-1;...    % SOUTH WEST 6 
    1,0;...     % SOUTH 7
    1,1;...     % SOUTH EAST 8
    ];

projectionCones = [
    1 2 8;...
    2 1 3;...
    3 2 4;...
    4 3 5;...
    5 4 6;...
    6 5 7;...
    7 6 8;....
    8 1 7;....
];

if(~strcmp(class(I),'double'))
    if(~(ndims(I)==3))
        I = im2double(I);
    else
        I = im2double(rgb2gray(I));
    end
end

if(nargin < 5)
 smallObjectRemovalArea = 100;
end

if(nargin < 6)
 deleteRatio = 0.3;
end

%
binaryImage = removeSmallObjects(binaryImage,smallObjectRemovalArea);

%Remove small holes from the binary image
if(~(maxFillArea==0))
 binaryImage = removeHoles(binaryImage,maxFillArea);
end

[B,~] = bwboundaries(binaryImage,8);

coordinates = vertcat(B{:}); % Concatenated boundaries coordinates
pixelsToProcess = uint16(coordinates);

if(strcmp(kernelType,'kirsch'))

    masks(:,:,1) = [-3 -3 5 
                    -3 0 5 
                    -3 -3 5 ];
    masks(:,:,2) = [-3 5 5 ; 
                    -3 0 5 ; 
                    -3 -3 -3];
    masks(:,:,3) = [5 5 5; 
                    -3 0 -3; 
                    -3 -3 -3];
    masks(:,:,4) = [5 5 -3; 
                    5 0 -3; 
                    -3 -3 -3];
    masks(:,:,5) = [5 -3 -3; 
                    5 0 -3; 
                    5 -3 -3];
    masks(:,:,6) = [-3 -3 -3; 
                    5 0 -3; 
                    5 5 -3];
    masks(:,:,7) = [-3 -3 -3; 
                    -3 0 -3; 
                    5 5 5];
    masks(:,:,8) = [-3 -3 -3; 
                    -3 0 5; 
                    -3 5 5];
          
elseif(strcmp(kernelType,'sobel'))
    
    masks(:,:,1) = [-1 0 1 
                    -2 0 2 
                    -1 0 1 ];
    masks(:,:,2) = [0 1 2 ; 
                    -1 0 1 ; 
                    -2 -1 0];
    masks(:,:,3) = [1 2 1; 
                    0 0 0; 
                    -1 -2 -1];
    masks(:,:,4) = [2 1 0; 
                    1 0 -1; 
                    0 -1 -2];
    masks(:,:,5) = [1 0 -1; 
                    2 0 -2; 
                    1 0 -1];
    masks(:,:,6) = [0 -1 -2; 
                    1 0 -1; 
                    2 1 0];
    masks(:,:,7) = [-1 -2 -1; 
                    0 0 0; 
                    1 2 1];
    masks(:,:,8) = [-2 -1 0; 
                    -1 0 1; 
                    0 1 2];

elseif(strcmp(kernelType,'robinson'))
    
    masks(:,:,1) = [-1 0 1 
                    -1 0 1 
                    -1 0 1 ];
    masks(:,:,2) = [0 1 1 ; 
                    -1 0 1 ; 
                    -1 -1 0];
    masks(:,:,3) = [1 1 1; 
                    0 0 0; 
                    -1 -1 -1];
    masks(:,:,4) = [1 1 0; 
                    1 0 -1; 
                    0 -1 -1];
    masks(:,:,5) = [1 0 -1; 
                    1 0 -1; 
                    1 0 -1];
    masks(:,:,6) = [0 -1 -1; 
                    1 0 -1; 
                    1 1 0];
    masks(:,:,7) = [-1 -1 -1; 
                    0 0 0; 
                    1 1 1];
    masks(:,:,8) = [-1 -1 0; 
                    -1 0 1; 
                    0 1 1];
                
elseif(strcmp(kernelType,'prewitt'))
    
    masks(:,:,1) = [-1 1 1 
                    -1 -2 1 
                    -1 1 1 ];
    masks(:,:,2) = [1 1 1 ; 
                    -1 -2 1 ; 
                    -1 -1 1];
    masks(:,:,3) = [1 1 1; 
                    1 -2 1; 
                    -1 -1 -1];
    masks(:,:,4) = [1 1 1; 
                    1 -2 -1; 
                    1 -1 -1];
    masks(:,:,5) = [1 1 -1; 
                    1 -2 -1; 
                    1 1 -1];
    masks(:,:,6) = [1 -1 -1; 
                    1 -2 -1; 
                    1 1 1];
    masks(:,:,7) = [-1 -1 -1; 
                    1 -2 1; 
                    1 1 1];
    masks(:,:,8) = [-1 -1 1; 
                    -1 -2 1; 
                    1 1 1];
else
    error('Invalid kernel type');
end
            
I_k = zeros(size(I,1),size(I,2),8);

for i=1:8
   I_k(:,:,i) = imfilter(I,masks(:,:,i));
end

[gradientIntensityMap, gradientDirectionMap] = max(I_k,[],3);

%imshow(gradientIntensityMap,[]);
go=1;

objectsInImage = bwconncomp(binaryImage);

consideredAsStartingPoint = logical(zeros(size(I)));

while(go)
    [consideredAsStartingPoint,toAddToQueueX,toAddToQueueY,toBeRemovedX,toBeRemovedY] = shrinkRegion(pixelsToProcess,gradientDirectionMap,projectionCones,consideredAsStartingPoint,directionOffsets,binaryImage);
    
    toAddToQueue = [toAddToQueueX, toAddToQueueY];
    

    toBeRemoved = double([toBeRemovedX, toBeRemovedY]);

    % Remove the pixels from the binary image
    
    if(size(toBeRemoved,1) > 0)
        binaryImage(sub2ind(size(binaryImage),toBeRemoved(:,1),toBeRemoved(:,2))) = 0;
    end

    % This part works pretty good
    %props = bwconncomp(binaryImage);
    %sizes = cellfun(@(x) size(x,1),props.PixelIdxList);
    %consideredAsStartingPoint(vertcat(props.PixelIdxList{(sizes < minDelete)})) = 1;

    for i=1:numel(objectsInImage.PixelIdxList)
        pixels = objectsInImage.PixelIdxList{i};
        if(nnz(binaryImage(pixels)) < deleteRatio*numel(pixels))
            consideredAsStartingPoint(pixels) =1;
        end
    end
    
    toAddToQueue = unique(toAddToQueue,'rows');

    
    %if(size(toAddToQueue) == size(pixelsToProcess) & nnz(toAddToQueue==pixelsToProcess)==size(toAddToQueue,1)*2)
    %    go = 0;
    %end
    
    pixelsToProcess = toAddToQueue;

    if(size(pixelsToProcess,1) ==0)
        go = 0;
    end   
    
end

J = binaryImage;
J = bwmorph(J,'majority',20);
J = bwmorph(J,'clean');


% for i=1:size(I,1)
%     for j=1:size(I,2)
%         fx(i,j) = directionOffsets(gradientDirectionMap(i,j),2);
%         fy(i,j) = directionOffsets(gradientDirectionMap(i,j),1);
%     end
% end
% 
%imshow(I)
%imshow(label2rgb(parentMap));
%  hold on;
%  quiver(fx,fy);
% for k = 1:numel(B)
%     boundary = B{k};
%     plot(boundary(:,2), boundary(:,1),'--','LineWidth',3,'Color','w')
% end
% 
%[newB,L] = bwboundaries(J,8);

%for k = 1:numel(newB)
%    boundary = newB{k};
%    plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 3)
%end
%hold off;


% figure,
% imshow(I);
% hold on
% 
% [newB,L] = bwboundaries(J,8);
% 
% for k = 1:numel(newB)
%     boundary = newB{k};
%     plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2)
% end
% 
% for k = 1:numel(B)
%     boundary = B{k};
%     plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
% end
% 
% 
% hold off;
%toc;
end
