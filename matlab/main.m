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

clear all; close all;

dataPath = ('images path\'); % e.g., myDatasetImages\

dataFormat = '*.png'; % e.g., for png input data

params = parametersDefinition();    

visualData = incomingVisualData(params, dataPath, dataFormat);
% define the dataset's frame rate
visualData.frameRate = 20; 

BoTW = buildingDatabase(visualData, params);

[matches, HMMresults, iBoTW] = queryingDatabaseHMM(params, visualData, BoTW);

results = methodEvaluation(params, matches, groundTruth);