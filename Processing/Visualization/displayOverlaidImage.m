function handle=displayOverlaidImage(I,binaryImage,alpha)

if(size(I,3) > 3)
I = I(:,:,1:3);
end

if(size(I,3) > 1)
I = rgb2gray(I);
end

handle=displayBorderImage(I,binaryImage,'Black',4);

green = cat(3, zeros(size(I)),ones(size(I)), zeros(size(I)));
%red = cat(3, ones(size(I)),zeros(size(I)), zeros(size(I)));
hold on
h = imshow(green);
%h2 = imshow(red);

hold off

alphaMap = zeros(size(I));
alphaMap2 = zeros(size(I));

alphaMap(binaryImage==1) = alpha;
set(h, 'AlphaData', alphaMap)

%alphaMap2(binaryImage==1) = 0.5;
%set(h2, 'AlphaData', alphaMap2)
