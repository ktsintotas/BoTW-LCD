% 

% Copyright 2019, Konstantinos A. Tsintotas
% ktsintot@pme.duth.gr
%
% This file is part of HMM-BoTW framework for visual loop closure detection
%
% HMM-BoTW framework is free software: you can redistribute 
% it and/or modify it under the terms of the MIT License as 
% published by the corresponding authors.
%  
% HMM-BoTW pipeline is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% MIT License for more details. <https://opensource.org/licenses/MIT>

close all;

query = 2522;
candidate = 379;

figure('IntegerHandle','on','Name','Querry Image');
imshow(visualData.inputImage{query});

figure('IntegerHandle','on','Name','Candidate Image');
imshow(visualData.inputImage{candidate});

if size(visualData.featuresSURF{query}, 1) > 200
    indexPairs = matchFeatures(iBoTW.queryDescriptors{query}, visualData.featuresSURF{candidate}(1:params.numPointsToTrack, :),...
        'Unique', true, 'Method', 'Exhaustive', 'MaxRatio', .6); % params.maxRatio
    matchedPoints1 = iBoTW.queryPoints{query}(indexPairs(:, 1), :);
    matchedPoints2 = visualData.pointsSURF{candidate}.Location(indexPairs(:, 2), :);
else
    indexPairs = matchFeatures(BoTWnew.queryDescriptors{query}, visualData.featuresSURF{candidate}(1:size(visualData.featuresSURF{candidates(i)}, 1), :), ...
        'Unique', true, 'Method', 'Approximate', 'MaxRatio', params.maxRatio); 
    matchedPoints1 = BoTWnew.queryPoints{query}(indexPairs(:, 1), :);
    matchedPoints2 = visualData.pointsSURF{candidate}.Location(indexPairs(:, 2), :);
end

figure; showMatchedFeatures(visualData.inputImage{query}, visualData.inputImage{candidate}, matchedPoints1,matchedPoints2);

[~, inliersIndex, ~] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, 'Method', 'RANSAC', 'DistanceType', 'Algebraic'), 'DistanceThreshold', 1);                    

% indexPairs = matchFeatures(BoTWnew.queryDescriptors{query}, visualData.featuresSURF{candidate}, 'Unique', true, 'Method', 'Exhaustive', 'MaxRatio', .6); 
% matchedPoints1 = BoTWnew.queryPoints{query}(indexPairs(:, 1), :);
% matchedPoints2 = visualData.pointsSURF{candidate}.Location(indexPairs(:, 2), :);                 

[~, inliersIndex, ~] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, 'Method', 'RANSAC'); %, 'DistanceType', 'Algebraic' ); %'DistanceThreshold', 1);                    

