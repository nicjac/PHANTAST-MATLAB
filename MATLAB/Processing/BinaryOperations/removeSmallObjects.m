function result = removeSmallObjects(image,thresholdArea)
%REMOVESMALLOBJECTS Summary of this function goes here
%   Detailed explanation goes here

data = regionprops(image,'Area','PixelIdxList');

count = 0;

toDelete = [];

for i=1:numel(data)
    if(data(i).Area <= thresholdArea) % If the hole is above the min area, it will _not_ be filled
        count = count+1;
        if(count==1)
            toDelete(1) = i;
        else
            toDelete = [toDelete i];
        end
    end
end

if(exist('toDelete','var') && size(data,1) > 0)
    data(toDelete) = [];
end

pixels = vertcat(data.PixelIdxList);

newImage = zeros(size(image));
newImage(pixels)=1;

result = logical(newImage);

end

