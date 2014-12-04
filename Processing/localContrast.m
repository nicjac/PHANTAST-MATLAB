function result =localContrast(im,sigma,epsilon)

%LOCALCONTRAST Summary of this function goes here
%   Detailed explanation goes here

% Load image and normalize
if(~strcmp(class(im),'double'))
    if(~(ndims(im)==3))
        im = double(im)/255;
    else
        im = double( rgb2gray( im ) )/255;
    end
end

% Pre-computed to avoid unnecessary double computation later
filtered = gaussianFilter(im,sigma);

result=sqrt(gaussianFilter(im.^2,sigma)-filtered.^2)./filtered;

result = real(result); % Make the resulting matrix is real

result = im2bw(result,epsilon);

end

