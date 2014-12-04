function [Fvalue,precision,recall,accuracy,JaccardIndex,TP,FP,TN,FN,FPrate,TPrate,MCC] = compareBinaryImages( reference, toTest )
%COMPAREBINARYIMAGES Compute various similarity metrics between two binary images
%   reference = grouth truth binary image
%   toTest = binary image to be compared to the reference image

if(ndims(reference)~=2 && ndims(toTest)~=2) 
    error('Inputs must be two 2-dimensional matrices'); 
end; 

%  TP = numel(find(reference==1 & toTest==1)==1); % True positive
%  FP = numel(find(reference==0 & toTest==1)==1); % False positive
%  TN = numel(find(reference==0 & toTest==0)==1); % True negative
%  FN = numel(find(reference==1 & toTest==0)==1); % False negative


 TP = nnz(reference==1 & toTest==1); % True positive
 FP = nnz(reference==0 & toTest==1); % False positive
 TN = nnz(reference==0 & toTest==0); % True negative
 FN = nnz(reference==1 & toTest==0); % False negative

P = TP + FN; % Total positive for the true class (= reference)
N = FP + TN; % TOtal negative for the true class (= reference)

FPrate = FP/N; % False positive rate
TPrate = TP/P; % True positive rate

precision = TP/(TP+FP);
recall = TP/P;
accuracy = (TP+TN)/(P+N);

MCC = (TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
2/((1/precision)+(1/recall));

% Alternative form for Fvalue
2*(precision*recall/(precision+recall));

% Avoid getting a division by 0 if only negatives and perfect detection
if(TN==numel(reference))
    'gaga'
    Fvalue = 1;
    warning('FValue was set to 1 as all pixels were true negatives');
else
    Fvalue=2*TP/(FP+TP+P);
end

2*TP/((FP+TP)+(TP+FN));

JaccardIndex = TP / (FP+TP+FN);

end

