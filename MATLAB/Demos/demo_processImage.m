% Demo showing how to use PHANTAST in MATLAB scripts
% Please make sure that the entire phantast/MATLAB directory as well as its
% sub-directories are in the MATLAB path

% Read the demo image
I = imread('Demo_image.tif');

% Compute the local contrast image (sigma = 1.4) and threshold it (epsilon
% = 0.06)
J = localContrast(I,1.4,0.06);

% Correct for halo artefacts (fill area threshold = 300, kernel = 'kirsch',
% smoll object removal threshold = 200, max object fraction to correct =
% 0.3
K = haloRemoval(I,J,320,'kirsch',200,0.3);

% Display the result of the processing
subplot(1,4,1);
imshow(I,[]); % Input PCM image
subplot(1,4,2);
imshow(J,[]); % Contrast-threshold output
subplot(1,4,3);
imshow(K,[]); % Halo-corrected output
h=subplot(1,4,4);
displayBorderImage(I,K,'green',1.5,h) % Segmentation overlaid on input PCM image
