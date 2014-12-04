function result=computeConfluency(image)

if(~islogical(image))
    image = im2bw(image);
    warning('Warning:binaryImageRequired','Using compute confluency with a non-binary image, converting automatically');
end

onPixels = nnz(image); 
offPixels = numel(image)-onPixels;

if(offPixels == 0) 
    confluency = 1;
else 
    confluency = onPixels/numel(image);
end

result = {{'confluency','on','off'},{confluency, onPixels, offPixels}};

end

