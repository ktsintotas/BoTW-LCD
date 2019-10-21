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

function params = parametersDefinition()
    
    % visual information
    params.visualData.load = true;
    params.visualData.save = true;
    
    % database
    params.buildingDatabase.load = true;
    params.buildingDatabase.save = true;
    
    % matches
    params.queryingDatabaseHMM.load = true;
    params.queryingDatabaseHMM.save = true;     

    % number of maximum points fed into the tracker, ni
    params.numPointsToTrack = int16(200);
    % minimum track word length, rho
    params.trackLength = int8(4);
    % minimum pointss distance, alpha
    params.pointsDist = single(5);
    % minimum descriptors distance, vita
    params.descriptorsDist = single(0.6);
    
    % loop closure threshold, delta
    params.observation2threshold = 1e-5;
    params.observation3threshold = 1e-12;
    
    % hidden markon forward algorithm
    params.filtering = true;    
    % transition matrix states
    params.numStates = 2;
    % hidden markov model transition matrix
    params.HMM.TRANS = [.95 .05 ; .1 .9];
    % hidden markov model emission matrix
    params.HMM.EMIS = [.65 .20 .15 ; 0 .4 6];
    % observations accessed
    params.temporalview = 1;
    
    % temporal consistency check
    params.temporalConsistency = true;     
    % temporal consistency locations' range
    params.locationRange = 8;    
    
    % vocabulary management
    params.vocabularyManagement = true; 
    % tracked words correspondance visualization
    params.visualizationMerging = false;
    % tracked words' maximum distance
    params.wordsDist = 0.2;
    % tracked words' correspondence
    params.wordsCorrespondence = 0.5;
    
    % geometrical verification check 
    params.verification =  true;                     
    % feature matching max ration
    params.maxRatio = 0.5;
    % feature matching least total of points
    params.numPointsToMatch = 400;
    % RANSAC inliers, phi
    params.inliersTheshold = int16(9);
    
    % evaluation visualization results
    params.visualizationResults = true;
    
end