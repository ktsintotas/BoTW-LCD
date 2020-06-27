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

function BoTW = initializationBoTW(visualData)
        
        % the visual dictionary
        BoTW.bagOfTrackedWords = single([]);
        % tracked words' indexing
        BoTW.twIndex = int16([]);
        % lamda is counting the number of tracked words belonging to the traversed location
        BoTW.lamda = zeros(1, size(visualData.inputImage, 2), 'int16');
        % maximum active point variable for the query process
        BoTW.maximumActivePoint = zeros(1, size(visualData.inputImage, 2), 'int16');
        % query points
        BoTW.queryPoints = cell(1, visualData.imagesLoaded);
        % query descriptors
        BoTW.queryDescriptors = cell(1, visualData.imagesLoaded);
        
end