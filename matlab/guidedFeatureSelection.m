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

function [pointsFedtoTracker, pointsDescriptors, pointRepeatability, trackObservation, pointsToSearch, descriptorsToSearch, trackedPointsBag, trackedDescriptorsBag, timer] = ...
    guidedFeatureSelection(params, visualData, previousImg, It, pointsFedtoTracker, pointsDescriptors, trackedPoints, trackedPointsValidity, pointRepeatability, trackedPointsBag, trackedDescriptorsBag, trackObservation, timer)
    
    pointsToSearch = single(visualData.pointsSURF{It}.Location);        
    descriptorsToSearch = visualData.featuresSURF{It};
    excludedPoint = int16([]);
    % allocate the timer
    guidedFeatureSelectionTiming = zeros(1, params.numPointsToTrack,'single');
    
    for j = 1 : params.numPointsToTrack
        
        % exclusion of point that used before from guided point detection in order a duplicate to be avoided
        pointsToSearch(excludedPoint, :) = [];
        % exclusion of descriptor that used before from guided feature detection in order a duplicate to be avoided
        descriptorsToSearch(excludedPoint, :) = [];
        
        % check if point of the previous image is tracked in the current and if the number of points are lower the desired            
        if j <= size(trackedPointsValidity, 1) && trackedPointsValidity(j) == 1 && ~isempty(pointsToSearch)
            % start the timer for the guided feature selection
            tic 
            % nearest neighbor index and points' distance between the tracked point "tp" and SURF points "SP" in I(t)
            [IdxNN, pointsDist] = knnsearch(pointsToSearch, trackedPoints(j, :), 'K', 1, 'NSMethod', 'kdtree');
            % SURF Points nearest neighbor in order to find the appropriate descriptor in previous image
            [p, ~] = knnsearch(visualData.pointsSURF{previousImg}.Location, pointsFedtoTracker(j, :), 'K', 1, 'NSMethod', 'kdtree' );
            % descriptors' distance
            descriptorsDist= norm(visualData.featuresSURF{previousImg}(p, :) - descriptorsToSearch(IdxNN, :));
            % stop the timer for the guided feature selection
            guidedFeatureSelectionTiming(1, j) = toc;

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
    
    guidedFeatureSelectionTiming = mean(guidedFeatureSelectionTiming);
    timer.guidedFeatureSelection(It, 1) = guidedFeatureSelectionTiming;
    
    % exclusion of points and descriptors that used before from guided tracking device for avoidance of duplicate at the new points addition
    pointsToSearch(excludedPoint, :) = [];    
    descriptorsToSearch(excludedPoint, :) = []; 
    
end