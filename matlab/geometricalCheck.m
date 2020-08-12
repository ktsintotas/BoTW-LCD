% 

% Copyright 2020, Konstantinos A. Tsintotas
% ktsintot@pme.duth.gr
%
% This file is part of BoTW-LCD framework for visual loop closure detection
%
% BoTW-LCD framework is free software: you can redistribute 
% it and/or modify it under the terms of the MIT License as 
% published by the corresponding authors.
%  
% BoTW-LCD pipeline is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% MIT License for more details. <https://opensource.org/licenses/MIT>

function [properImage, inliersTotal] = geometricalCheck(It, iBoTW, params, candidate, visualData)
     
    properImage = uint16(0);
    inliersTotal = uint16(0); 
    acceptedImage = false;
    i = uint16(0);
    
    if length(candidate) > 10
        iterations = 10;
    else
        iterations = length(candidate);
    end
    
    while acceptedImage == false

    if i < iterations
        i = i + 1;
    elseif i <= iterations && acceptedImage == false
        acceptedImage = true;       
    end
    
        indexPairs = matchFeatures(iBoTW.queryDescriptors{It}, ...        
            visualData.features{candidate(i)}, 'Unique', true, 'Method', 'Exhaustive',  'MatchThreshold', 10.0, 'MaxRatio', params.queryingDatabase.maxRatio);
        
        if size(indexPairs, 1) >= params.queryingDatabase.inliersTheshold
            matchedPoints1 = iBoTW.queryPoints{It}(indexPairs(:, 1), :);
            matchedPoints2 = visualData.points{candidate(i)}.Location(indexPairs(:, 2), :);

            try
                [~, inliersIndex, ~] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, ...
                    'Method', 'RANSAC', 'DistanceType', 'Algebraic', 'DistanceThreshold', 1);
                if sum(inliersIndex) >= params.queryingDatabase.inliersTheshold
                    properImage = candidate(i);
                    inliersTotal = sum(inliersIndex);                
                    acceptedImage = true;
                end
            catch
            end
        else
            continue
        end
    end
end
