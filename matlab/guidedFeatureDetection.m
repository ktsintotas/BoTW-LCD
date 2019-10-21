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

function [pointsFedtoTracker, pointsDescriptors, pointRepeatability, trackObservation, pointsToSearch, descriptorsToSearch, trackedPointsBag, trackedDescriptorsBag] = ...
    guidedFeatureDetection(params, visualData, previousImg, It, pointsFedtoTracker, pointsDescriptors, trackedPoints, trackedPointsValidity, pointRepeatability, trackedPointsBag, trackedDescriptorsBag, trackObservation)
    
    pointsToSearch = single(visualData.pointsSURF{It}.Location);        
    descriptorsToSearch = visualData.featuresSURF{It};
    % SURF Points in order to find the appropriate descriptor in previous image
    SPprevious = KDTreeSearcher(visualData.pointsSURF{previousImg}.Location); 
    excludedPoint = int16([]);

    for j = 1 : params.numPointsToTrack
        
        % exclusion of point that used before from guided point detection in order a duplicate to be avoided
        pointsToSearch(excludedPoint, :) = [];
        % exclusion of descriptor that used before from guided feature detection in order a duplicate to be avoided
        descriptorsToSearch(excludedPoint, :) = [];
        % preparation of pointsToSearch database for k-NN
        SP = KDTreeSearcher(pointsToSearch);
        
        % check if point of the previous image is tracked in the current and if the number of points are lower the desired            
        if j <= size(trackedPointsValidity, 1) && trackedPointsValidity(j) == 1 && ~isempty(pointsToSearch)

            % nearest neighbor index and points' distance between the tracked point "tp" and SURF points "SP" in I(t)
            [IdxNN, pointsDist] = knnsearch(SP, trackedPoints(j, :), 'K', 1 );
            % descriptors' distance
            [p, ~] = knnsearch(SPprevious, pointsFedtoTracker(j, :), 'K', 1 );
            descriptorsDist= norm(visualData.featuresSURF{previousImg}(p, :) - descriptorsToSearch(IdxNN, :));

            % two conditions for acceptance of a tracked point
            if pointsDist < params.pointsDist && descriptorsDist < params.descriptorsDist
                % accepted point and descriptor
                trackObservation(j) = true;
                % to maintain the correct point detected in the current image                                     
                pointsFedtoTracker(j, :) = pointsToSearch(IdxNN, :);
                % adding points in order to be used for geometrical procedure
                trackedPointsBag{j} = [trackedPointsBag{j}; pointsFedtoTracker(j, :)];
                % to maintain the correct descriptor detected in the current image                                                        
                pointsDescriptors(j, :) = descriptorsToSearch(IdxNN, :);                
                % adding descriptors in order to be transformed at Tracked Word and also used for geometrical procedure
                trackedDescriptorsBag{j} = [trackedDescriptorsBag{j}; pointsDescriptors(j, :)];
                % point repeatability along consecutive images
                pointRepeatability(j) = pointRepeatability(j) + 1;
                % point to be deleted from the repetitive function
                excludedPoint = IdxNN;                
            else                
                trackObservation(j) = false; 
                excludedPoint = [];
            end

        else
            trackObservation(j) = false;      
            excludedPoint = [];
        end   
        
    end
    
    % exclusion of point and descriptor that used before from tracking device for
    % avoidance of duplicate at the new points addition
    pointsToSearch(excludedPoint, :) = [];    
    descriptorsToSearch(excludedPoint, :) = []; 
    
end