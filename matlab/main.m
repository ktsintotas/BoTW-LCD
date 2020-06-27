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

clear all; close all;

dataPath = ('images path\'); % e.g., myDatasetImages\
dataFormat = '*.png'; % e.g., for png input data

% parameters' definitions
params = parametersDefinition();
% extraction of visual sensory information
[visualData, timer] = incomingVisualData(params, dataPath, dataFormat);
% dataset's frame rate definition
visualData.frameRate = 10; 
% timers memory allocation
timer = timersInitialization(visualData, timer);
% 1) the vocabulary build
[BoTW, timer] = buildingDatabase(visualData, params, timer);
% 2)  the query procedure
[matches, HMMresults, iBoTW, timer] = queryingDatabaseHMM(params, visualData, BoTW, timer);
% method's evaluation
close all;
results = methodEvaluation(params, matches, groundTruth);