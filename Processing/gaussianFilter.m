function filteredImage = gaussianFilter(image, sigma)

    % Optimal size should be 2.9786*sigma
    kernelSize=ceil(2.9786*sigma);
    x = -kernelSize:kernelSize; 
    
    % Compute the Gaussian kernel
    gaussianKernel = exp(- x.^2 / (2*sigma^2) );

    % Normalise kernel
    gaussianKernel = gaussianKernel .* 1/sum(sum(gaussianKernel));
    
    % Make a copy of the image variable
    filteredImage = image;
    
    % Convolve the image in each direction individually
    for i=1:2
        % We switch direction of the kernel for the second iteration
        if(i==2)
            gaussianKernel = gaussianKernel';
        end
        
        filteredImage = imfilter(filteredImage,gaussianKernel,'symmetric','same');
    end
end

