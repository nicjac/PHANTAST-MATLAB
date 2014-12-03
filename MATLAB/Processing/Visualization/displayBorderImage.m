% Display an image with the overlaid border of a binary mask
function [h,hIm]=displayBorderImage(I,J,color,width,parent)
    B = bwboundaries(J,4);
    
    if nargin < 3
        color = 'black';
    end
    
    if nargin < 4
        width = 1;
    end
    
    if(size(I,3)>3)
        I = I(:,:,1:3);
    end
    
    if(nargin <5)
        h=figure();
    else
        h=0;
    end
    
    if(nargin <5)
        hIm = imshow(I,[]);
        %freezeColors();
    else
        hIm = imshow(I,'Parent',parent);
        %freezeColors();
    end
       
    if(nargin >=5)
        hold(parent);
    else
        hold on
    end
    
    for k = 1:numel(B)
        if(nargin <5)
            plot(B{k}(:,2), B{k}(:,1), color, 'Linewidth', width);
        else
            plot(B{k}(:,2), B{k}(:,1), color, 'Linewidth', width,'Parent',parent);
        end
    end
    
    if(nargin >=5)
        hold(parent);
    else
        hold off
    end
end