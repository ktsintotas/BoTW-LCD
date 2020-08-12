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

function params = parametersDefinition()
    
    % incomingVisualData
    params.visualData.load = true;
    params.visualData.save = true;    
    % points' response, Phi (incomingVisualData)
    params.incomingVisualData.featuresResponse = 400.0;
    % strongest points to hold, Phi (incomingVisualData)
    params.incomingVisualData.strongest = 1000;
    % descriptor dimension (incomingVisualData)
    params.incomingVisualData.descriptorDimension = uint8(64);    
    
    % buildingDatabase 
    params.buildingDatabase.load = true;
    params.buildingDatabase.save = true; 
    % number of maximum points fed into the tracker, ni (buildingDatabase)
    params.buildingDatabase.numPointsToTrack = uint16(150);
    % minimum track word length, rho (buildingDatabase)
    params.buildingDatabase.trackLength = uint8(4);
    % minimum pointss distance, alpha (buildingDatabase)
    params.buildingDatabase.pointsDist = single(5);
    % minimum descriptors distance, vita (buildingDatabase)
    params.buildingDatabase.descriptorsDist = single(0.6);
    % minimum words sampling ratio (buildingDatabase)
    params.buildingDatabase.wordsRatio = single(0.5);
    
    % queryingDatabase
    params.queryingDatabase.load = true;
    params.queryingDatabase.save = true;
    % loop closure threshold, th (queryingDatabase)
    params.queryingDatabase.observationThreshold = 2e-9;
    % transition matrix states (queryingDatabase)
    params.queryingDatabase.numStates = 2;
    % hidden markov model transition matrix (queryingDatabase)
    params.queryingDatabase.HMM.TRANS = [ 0.975 0.025 ;  0.025 0.975];
    % hidden markov model emission matrix (queryingDatabase)
    params.queryingDatabase.HMM.EMIS = [1 0 ; 0.46 0.54];        
    % temporal consistency locations' range (queryingDatabase)
    params.queryingDatabase.locationRange = 5;    
    
    % feature matching max ration (queryingDatabase)
    params.queryingDatabase.maxRatio = 0.4;
    % RANSAC inliers, phi (queryingDatabase)
    params.queryingDatabase.inliersTheshold = uint16(8);    
    
    % tracked words' maximum distance (queryingDatabase)
    params.queryingDatabase.wordsDist = 0.4;
    % tracked words' correspondence (queryingDatabase)
    params.queryingDatabase.wordsCorrespondence = 0.5;
    
    % evaluation visualization results 
    params.visualizationResults = true;
    
end
