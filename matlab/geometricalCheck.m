% 

% Copyright 2019, Konstantinos Tsintotas
% ktsintot@pme.duth.gr
%
% This file is part of iBoTW framework for visual loop closure detection
%
% iBoTW framework is free software: you can redistribute 
% it and/or modify it under the terms of the MIT License as 
% published by the corresponding authors.
%  
% iBoTW pipeline is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% MIT License for more details. <https://opensource.org/licenses/MIT>

function [properImage, inliersTotal] = geometricalCheck(It, iBoTW, params, candidates, visualData)
    
    properImage = int16(0);
    inliersTotal = int16(0);    
    i = int16(0);
    acceptedImage = false;
    
    while acceptedImage == false
        
        if i < length(candidates)
            i = i + 1;
        elseif i <= length(candidates) && acceptedImage == false
            acceptedImage = true;       
        end
        
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
                properImage = candidates(i);
                inliersTotal = sum(inliersIndex);
                acceptedImage = true;
            end
        catch
            continue
        end
        
    end
      
end