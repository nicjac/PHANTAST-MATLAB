function resultImage = removeHoles(image,maxArea)
    filled = imfill(image, 'holes');
    holes = filled & ~image;

    dataHoles = regionprops(logical(holes),'Area','PixelList','PixelIdxList','Centroid');
    
    count = 1;
    for i=1:numel(dataHoles)
        if(dataHoles(i).Area > maxArea) % If the hole is above the min area, it will _not_ be filled
            if(count==1)
                toDelete(1) = i;
            else
                toDelete = [toDelete i];
            end
            count = count+1;
        end
    end
    
    if(exist('toDelete','var') && size(dataHoles,1) > 0)
        dataHoles(toDelete) = [];
    end

    pixels = vertcat(dataHoles.PixelIdxList);

    image(pixels)=1;
    resultImage = image;
end

