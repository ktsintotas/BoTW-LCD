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

function matches = matchesInitialization(visualData, params)
        
        % votes' matrix to visualize the voting procedure
        matches.votesMatrix = zeros(visualData.imagesLoaded, visualData.imagesLoaded, 'uint16');
        % binomial matrix to visualize the generated probabilities
        matches.binomialMatrix = zeros(visualData.imagesLoaded, visualData.imagesLoaded);
        % generated loop closure matrix by the framework
        matches.loopClosureMatrix = false(visualData.imagesLoaded, visualData.imagesLoaded);
        % image to image correspondence
        matches.matches = zeros(visualData.imagesLoaded, 1, 'single');
        % inliers from geometrical check of the selected image
        matches.inliers = zeros(visualData.imagesLoaded, 1, 'uint16');
        % hold the nearest neighbor of each query descriptor to the vocabulary
        matches.knnIDx = zeros(params.buildingDatabase.numPointsToTrack, visualData.imagesLoaded, 'uint16');
        
end
