% 

% Copyright 2019, Konstantinos Tsintotas
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

function [properImage, inliersTotal] = geometricalCheck(It, iBoTW, params, candidates, visualData)
    
    properImage = int16(0);
    candidateInliers = int16(zeros(1, length(candidates)));
    for i = 1 : length(candidates)       

        if size(visualData.featuresSURF{candidates(i)}, 1) > params.numPointsToTrack         
            indexPairs = matchFeatures(iBoTW.queryDescriptors{It}, visualData.featuresSURF{candidates(i)}(1:params.numPointsToTrack, :), ...
                'Unique', true, 'Method', 'Exhaustive', 'MaxRatio', params.maxRatio); 
            matchedPoints1 = iBoTW.queryPoints{It}(indexPairs(:, 1), :);
            matchedPoints2 = visualData.pointsSURF{candidates(i)}.Location(indexPairs(:, 2), :);
        else
            indexPairs = matchFeatures(iBoTW.queryDescriptors{It}, visualData.featuresSURF{candidates(i)}(1:size(visualData.featuresSURF{candidates(i)}, 1), :), ...
                'Unique', true, 'Method', 'Exhaustive', 'MaxRatio', params.maxRatio); 
            matchedPoints1 = iBoTW.queryPoints{It}(indexPairs(:, 1), :);
            matchedPoints2 = visualData.pointsSURF{candidates(i)}.Location(indexPairs(:, 2), :);
        end
                
        try
            [~, inliersIndex, ~] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, 'Method', 'RANSAC', 'DistanceType', 'Algebraic', 'DistanceThreshold', 1);                    
            if sum(inliersIndex) > params.inliersTheshold
                candidateInliers(i) = sum(inliersIndex);                    
            end                        
        catch
            continue
        end
        
    end
    
    [inliersTotal, mostInlliersIndex] = max(candidateInliers);
    if sum(candidateInliers) ~= 0
        properImage = candidates(mostInlliersIndex);        
    end                
end