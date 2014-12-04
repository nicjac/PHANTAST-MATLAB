function resultImage = contrastStretching(image,saturationPercentage)
%CONTRASTSTRETCHING Stretch the contrast of an image to full range

    if(~strcmp(class(image),'double'))
        if(~(ndims(image)==3))
            image = im2double(image);
        else
            image = im2double(rgb2gray(image));
        end
    end
    
    if(saturationPercentage==0)
        resultImage = image;
    else
        resultImage = imadjust(image,stretchlim(image,saturationPercentage/100));
    end
end
