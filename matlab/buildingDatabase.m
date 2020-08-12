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

function [BoTW, timer] = buildingDatabase(visualData, params, timer)

    % shall we load the visual information and its' extracted variables?
    if params.buildingDatabase.load == true && exist('results/buildingDatabase.mat', 'file')    
        load('results/buildingDatabase.mat'); 
    
    else
        
        % tracked words' counter
        twCounter = single(0);
        % initializing the Bag of Tracked Words database
        BoTW = initializationBoTW(visualData, params);
        % initialization of points' tracking validity based on our conditions
        trackObservation = false(params.buildingDatabase.numPointsToTrack, 1);
        % initialization of points' representation along consecutive features
        pointRepeatability = ones(params.buildingDatabase.numPointsToTrack, 1, 'uint16');

        for It = uint16(1 : visualData.imagesLoaded)
            disp(It)
            
            % initialization of points and descriptors   
            if It == 1                               
                if size(visualData.points{It}, 1) > params.buildingDatabase.numPointsToTrack
                    % initial query points and initial points for the tracker
                    BoTW.queryPoints{It}= visualData.points{It}.Location(1 : params.buildingDatabase.numPointsToTrack, :);
                    % initial points, each one into a cell bag
                    trackedPointsBag = mat2cell(BoTW.queryPoints{It}, ones(1, params.buildingDatabase.numPointsToTrack));
                    % initial query descriptors
                    BoTW.queryDescriptors{It} = visualData.features{It}(1 : params.buildingDatabase.numPointsToTrack, :);
                    % initial descriptors, each one into a cell bag
                    trackedDescriptorsBag = mat2cell(BoTW.queryDescriptors{It}, ones(1, params.buildingDatabase.numPointsToTrack));
                else 
                    % initial query points and initial points for the tracker
                    BoTW.queryPoints{It}= visualData.points{It}.Location(1 : size(visualData.points{It}, 1), :);
                    % initial points, each one into a cell bag
                    trackedPointsBag = mat2cell(BoTW.queryPoints{It}, ones(1, size(visualData.points{It}, 1)));      
                     % initial query descriptors
                    BoTW.queryDescriptors{It} = visualData.features{It}(1 : size(visualData.features{It}, 1), :);
                    % initial descriptors, each one into a cell bag
                    trackedDescriptorsBag = mat2cell(BoTW.queryDescriptors{It}, ones(1, size(visualData.features{It}, 1)));
                end    

                % point tracker object generation that tracks a set of points
                pointTracker = vision.PointTracker('NumPyramidLevels', 3, 'MaxBidirectionalError', 3); 
                initialize(pointTracker, BoTW.queryPoints{It}, visualData.inputImage{It});
            end

            if It > 1
                previousIt = uint16(It-1);                
                if ~isempty(BoTW.queryPoints{previousIt}) && size(visualData.points{It}, 1) > params.queryingDatabase.inliersTheshold
            
                    if It > 2                
                        % objects lock when you call them and the release function unlocks them
                        release(pointTracker);
                        % initialize again the tracker with the new and more accurate points            
                        initialize(pointTracker, BoTW.queryPoints{previousIt}, visualData.inputImage{previousIt});
                    end
                    
                    % start the timer for the Kanade-Lucas-Tomase tracker
                    tic 
                    % tracked points in the incoming frame
                    [trackedPoints, trackedPointsValidity] = pointTracker(visualData.inputImage{It});
                    % stop the timer for the Kanade-Lucas-Tomase tracker
                    timer.trackingPoints(It, 1) = toc;

                    % GUIDED FEATURE SELECTION
                    [BoTW.queryPoints{It}, BoTW.queryDescriptors{It}, pointRepeatability, trackObservation, pointsToSearch, descriptorsToSearch, trackedPointsBag, trackedDescriptorsBag, timer] = ... 
                        guidedFeatureSelection(params, visualData, previousIt, It, BoTW.queryPoints{previousIt}, BoTW.queryDescriptors{previousIt}, trackedPoints, trackedPointsValidity, pointRepeatability, trackedPointsBag, trackedDescriptorsBag, trackObservation, timer);
                    
                    % TRACKED WORD GENERATION
                    newPointCounter = uint16(0);
                    deletion = false;
                    pointsToDelete = false(length(trackObservation), 1);                
               
                    
                    for td = uint16(1 : params.buildingDatabase.numPointsToTrack)
                        
                        % When the tracking of a certain point is discontinued, its total length measured in consecutive frames, determines whether a new word should be created
                        if trackObservation(td) == false && pointRepeatability(td) > params.buildingDatabase.trackLength 
                            twCounter =  twCounter + 1;
                            % Bag of Tracked Words generation from the median of the tracked descriptors the representative TW is computed
                            BoTW.bagOfTrackedWords(twCounter, :) = median(trackedDescriptorsBag{td}, 1 );
                            
                            if twCounter > 2
                                [id, dNN] = knnsearch(BoTW.bagOfTrackedWords(1 : twCounter-1, :), BoTW.bagOfTrackedWords(twCounter, :), 'K', 2);    
                                ratio = dNN(1)/dNN(2);                                  
                                if ratio < params.buildingDatabase.wordsRatio  
                                    % renew the visual word
                                    BoTW.bagOfTrackedWords(id(1), :) = median([BoTW.trackedWordDescriptors{id(1)} ; trackedDescriptorsBag{td}], 1 );    
                                    % how many tracked words each location generates
                                    locationsToAdd = uint16(BoTW.twLocationIndex(id(1), It - pointRepeatability(td) : previousIt ) ~= 1);
                                    BoTW.lamda(1, (It - pointRepeatability(td)) : previousIt) =  BoTW.lamda(1, (It - pointRepeatability(td)) : previousIt) + locationsToAdd;
                                    % track word to location binary indexing
                                    BoTW.twLocationIndex(id(1), It - pointRepeatability(td) : previousIt) = true;                                    
                                    % decrease the number of counter
                                    twCounter = twCounter-1;
                                    % increase the number of deleted words
                                    BoTW.deleted = BoTW.deleted + 1;
                                else                            
                                    % first image where the point is observed //BoTW.twIndex(twCounter, 1) = It - pointRepeatability(tw);
                                    % last image where the feature is observed // BoTW.twIndex(twCounter, 2) = previous;
                                    % tracked word's repeatability // BoTW.twIndex(twCounter, 3)
                                    BoTW.twIndex(twCounter, :) = [(It - pointRepeatability(td)), previousIt, pointRepeatability(td)];
                                    % track word to location binary indexing
                                    BoTW.twLocationIndex(twCounter, It - pointRepeatability(td) : previousIt) = true;
                                    % points correspond to the generated tracked word
                                    BoTW.trackedWordPoints{twCounter} = trackedPointsBag{td};
                                    % descriptors correspond to the generated tracked word
                                    BoTW.trackedWordDescriptors{twCounter} = trackedDescriptorsBag{td};                
                                    % how many tracked words each location generates
                                    BoTW.lamda(1, (It - pointRepeatability(td)) : previousIt) =  BoTW.lamda(1, (It - pointRepeatability(td)) : previousIt) + 1;
                                end
                            else
                                % first image where the point is observed //BoTW.twIndex(twCounter, 1) = It - pointRepeatability(tw);
                                % last image where the feature is observed // BoTW.twIndex(twCounter, 2) = previous;
                                % tracked word's repeatability // BoTW.twIndex(twCounter, 3)
                                BoTW.twIndex(twCounter, :) = [(It - pointRepeatability(td)), previousIt, pointRepeatability(td)];
                                % track word to location binary indexing
                                BoTW.twLocationIndex(twCounter, It - pointRepeatability(td) : previousIt) = true;
                                % points correspond to the generated tracked word
                                BoTW.trackedWordPoints{twCounter} = trackedPointsBag{td};
                                % descriptors correspond to the generated tracked word
                                BoTW.trackedWordDescriptors{twCounter} = trackedDescriptorsBag{td};                
                                % how many tracked words each location generates
                                BoTW.lamda(1, BoTW.twIndex(twCounter, 1) : BoTW.twIndex(twCounter, 2)) =  BoTW.lamda(1, BoTW.twIndex(twCounter, 1) : BoTW.twIndex(twCounter, 2)) + 1;                                    
                            end
                        end
                        
                        % replacement of point that either became TW or just lose its track
                        if trackObservation(td) == false && newPointCounter < size(pointsToSearch, 1)
                            newPointCounter = newPointCounter + 1;
                            % new point addition
                            BoTW.queryPoints{It}(td, :) = pointsToSearch(newPointCounter, : );
                            % new query descriptor addition
                            BoTW.queryDescriptors{It}(td, :) = descriptorsToSearch(newPointCounter, : );
                            % new point addition
                            trackedPointsBag{td} = pointsToSearch(newPointCounter, : );
                            % new descriptor addition
                            trackedDescriptorsBag{td} = descriptorsToSearch(newPointCounter, : );
                            % initialization new point representation
                            pointRepeatability(td) = 1;                        
                        % in cases where the plane is not textured enough                        
                        elseif trackObservation(td) == false && newPointCounter >= size(pointsToSearch, 1) && size(BoTW.queryPoints{It}, 1) >= td
                            deletion = true;
                            pointsToDelete(td) = true;                        
                        end
                    end
                    
                    if deletion == true
                        BoTW.queryPoints{It}((pointsToDelete == true), :) = [];
                        BoTW.queryDescriptors{It}((pointsToDelete == true), :) = [];
                        trackedPointsBag((pointsToDelete == true), :) = [];
                        trackedDescriptorsBag((pointsToDelete == true), :) = [];
                        pointRepeatability((pointsToDelete == true), :) = [];
                        pointRepeatability(length(pointRepeatability) + 1 : params.buildingDatabase.numPointsToTrack) = 1;
                    end           
                    
                    BoTW.maximumActivePoint(It) = max(pointRepeatability);            
                else
                    
                    % initialization process again                    
                    trackObservation = false(params.buildingDatabase.numPointsToTrack, 1);
                    pointRepeatability = ones(params.buildingDatabase.numPointsToTrack, 1, 'uint16');                          
                    
                    if size(visualData.points{It}, 1) > params.buildingDatabase.numPointsToTrack
                        BoTW.queryPoints{It}= visualData.points{It}.Location(1 : params.buildingDatabase.numPointsToTrack, :);                    
                        trackedPointsBag = mat2cell(BoTW.queryPoints{It}, ones(1, params.buildingDatabase.numPointsToTrack));                    
                        BoTW.queryDescriptors{It} = visualData.features{It}(1 : params.buildingDatabase.numPointsToTrack, :);                    
                        trackedDescriptorsBag = mat2cell(BoTW.queryDescriptors{It}, ones(1, params.buildingDatabase.numPointsToTrack));
                    % in case the image texture can not generate enough visual local features
                    elseif size(visualData.points{It}, 1) < params.buildingDatabase.numPointsToTrack ... 
                            && size(visualData.points{It}, 1) > params.queryingDatabase.inliersTheshold
                        BoTW.queryPoints{It}= visualData.points{It}.Location(1 : size(visualData.points{It}, 1), :);
                        trackedPointsBag = mat2cell(BoTW.queryPoints{It}, ones(1, size(visualData.points{It}, 1)));                   
                        BoTW.queryDescriptors{It} = visualData.features{It}(1 : size(visualData.features{It}, 1), :);
                        trackedDescriptorsBag = mat2cell(BoTW.queryDescriptors{It}, ones(1, size(visualData.features{It}, 1)));                        
                    end
                    
                end                
            end            
        end
        
        BoTW.bagOfTrackedWords = BoTW.bagOfTrackedWords(1:twCounter, :);
        BoTW.twIndex = BoTW.twIndex(1:twCounter, :);
        BoTW.twLocationIndex = BoTW.twLocationIndex(1:twCounter, :);
        BoTW.trackedWordPoints = BoTW.trackedWordPoints(1, 1 : twCounter);
        BoTW.trackedWordDescriptors = BoTW.trackedWordDescriptors(1, 1 : twCounter);
        
        % save the generated database if not a file exists
        if params.buildingDatabase.save
            save('results/buildingDatabase', 'BoTW', 'timer', '-v7.3');
        end
        
    end
end
