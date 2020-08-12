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

function BoTW = initializationBoTW(visualData, params)
        
        % the visual dictionary
        BoTW.bagOfTrackedWords = single(zeros(100000, params.incomingVisualData.descriptorDimension));
        % tracked words' indexing
        BoTW.twIndex = uint16(zeros(100000, 3));
        % tracked words' location indexing
        BoTW.twLocationIndex = false(100000, size(visualData.inputImage, 2));
        % the deteled words
        BoTW.deleted = uint16(0);
        % lamda is counting the number of tracked words belonging to the traversed location
        BoTW.lamda = zeros(1, size(visualData.inputImage, 2), 'uint16');
        % maximum active point variable for the query process
        BoTW.maximumActivePoint = zeros(1, size(visualData.inputImage, 2), 'uint16');
        % query points
        BoTW.queryPoints = cell(1, visualData.imagesLoaded);
        % query descriptors
        BoTW.queryDescriptors = cell(1, visualData.imagesLoaded);
        
end
