% 

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

function [matches, HMMresults, BoTWnew, timer] = queryingDatabaseProposed(params, visualData, BoTW, timer)

    if params.queryingDatabase.load == true && exist('results/queryingDatabaseHMM.mat', 'file')
        load('results/queryingDatabaseHMM.mat');  
        
    else
        
        % copy the visual dictionary in order a comparison to be permitted
        BoTWnew = BoTW;        
        % memory allocation for system's outputs
        matches = matchesInitialization(visualData, params);
        % memory allocation for system's results
        HMMresults = HMMinitialization(visualData);
        
        for It = uint16(1 : visualData.imagesLoaded)    
        
            disp(It);
            
            % SEARCHING THE DATABASE
            % excluding the vocabulary area which would be avoided  
            if BoTWnew.maximumActivePoint(It) < visualData.frameRate
                lastDatabaseLocation = It - ceil(4 * visualData.frameRate);
            else
                lastDatabaseLocation = It - ceil(4 * BoTWnew.maximumActivePoint(It) );
            end
            if lastDatabaseLocation > 0
                databaseIndexTemp = find(BoTWnew.twIndex(:, 2) <= lastDatabaseLocation);                
                if ~isempty(databaseIndexTemp)                    
                    databaseIndexTemp = databaseIndexTemp(end);
                    % visual vocabulary to be searched
                    database = BoTWnew.bagOfTrackedWords(1 : databaseIndexTemp, :);                     
                else
                     database = single([]);
                end
            else
                database = single([]);
            end

            % vote aggregation
            if ~isempty(database) && size(BoTWnew.queryDescriptors{It}, 1) > params.queryingDatabase.inliersTheshold                
                % k-NN search using only the CPU
                
                % start the timer for the database search
                tic
                queryIdxNN = single(knnsearch(database, BoTWnew.queryDescriptors{It}, 'K', 1, 'NSMethod', 'exhaustive'));
                % stop the timer for the database search
                timer.databaseSearch(It, 1) = toc;      
                
                % knn Indexing for the correspondance at visual vocabulary management
                matches.knnIDx(1 : length(queryIdxNN), It) = queryIdxNN;
                         
                % start the timer for the votes' distribution
                tic 
                % votes distribution through the Nearest Neighbor procedure
                for v = uint16(1 : length(queryIdxNN))                    
                    votedLocations = uint16(find(BoTWnew.twLocationIndex(queryIdxNN(v), 1 : lastDatabaseLocation) == true));
                    matches.votesMatrix(It, votedLocations) = matches.votesMatrix(It, votedLocations) + 1;                    
                end
                % stop the timer for the votes' distribution
                timer.votesDistribution(It, 1) = toc;
                                
                % NAVIGATION USING PROBABILISTIC SCORING
                % images which gather votes
                imagesForBinomial = uint16(find(matches.votesMatrix(It, 1 : lastDatabaseLocation) >= 0.01 * size(BoTWnew.queryDescriptors{It}, 1)));
                % start the timer for the binomial scoring
                tic
                % locations which pass the two conditions
                candidateLocationsObservation = zeros(1, lastDatabaseLocation, 'double');
                % number of Tracked Words within the searching area 
                LAMDA = databaseIndexTemp;
                % number of query’s Tracked Points (number of points after the guided feature-detection)
                N = size(BoTWnew.queryDescriptors{It}, 1);                
                % number of accumulated votes of database location l
                xl = double(matches.votesMatrix(It, imagesForBinomial));
                % number of TWs members in l over the size of the BoTW list (without the rejected locations)
                p = double(BoTWnew.lamda(imagesForBinomial)) / LAMDA;
                % distribution’s expected value 
                expectedValue = N*p;
                % probability computation for the selected images in the database
                locationProbability = binopdf(xl, N , p);
                % binomial Matrix completion
                matches.binomialMatrix(It, imagesForBinomial) = locationProbability;
                % the binomial expected value on each location has to
                % satisfy two conditions, (1) loop closure threshold and (2) over expected value xl(t) > E [Xi(t)]
                Condition2Locations = uint16(find(xl > expectedValue));                
                % locations which satisfy condition 2 and condition 1 - observation 3
                if ~isempty(Condition2Locations) ... 
                        && ~isempty(find(locationProbability(Condition2Locations) < params.queryingDatabase.observationThreshold, 1))                    
                    candidateLocations = imagesForBinomial(Condition2Locations(locationProbability(Condition2Locations) < params.queryingDatabase.observationThreshold));
                    candidateLocationsObservation(candidateLocations) = matches.binomialMatrix(It, candidateLocations);
                    HMMresults.observations(It) = 2;
                end
                % stop the timer for the binomial scoring
                timer.binomialScoring(It, 1) = toc;
                
                % MATCHING PROCEDURE       
                % filtering the binomial through Bayes estimation
                
                % start the timer for the Bayesian filtering
                tic
                [HMMresults] = forwardHMM(HMMresults, params, It);
                % stop the timer for the binomial scoring
                timer.bayesianFiltering(It, 1) = toc;
                    
                % observation 2 and loop closure detection
                if HMMresults.loopStates(It) == 2
                    [properImage, inliersTotal, HMMresults, timer] = ...
                        locationDefinition(params, HMMresults, matches, candidateLocationsObservation, It, BoTWnew, visualData, timer);                
                    if properImage ~= 0
                        matches.loopClosureMatrix(It, properImage) = true;
                        matches.matches(It, 1) = properImage;                            
                        matches.matches(It, 2) = matches.binomialMatrix(It, properImage);
                        matches.inliers(It) = inliersTotal;
                    end        
                    % vocabulary management
                    if properImage ~= 0 && matches.loopClosureMatrix(It, properImage) == true
                        wordsToManage = single(find(BoTWnew.twIndex(:, 2) == It));                    
                        if ~isempty(wordsToManage)
                            [BoTWnew, timer] = vocabularyManagement(BoTWnew, wordsToManage, It, properImage, matches, params, timer);
                        end
                    end
                end                
            end
        end
        
        if params.queryingDatabase.save
            % save variables with real valued mapping and no GPU for searching
            save('results/queryingDatabaseHMM', 'matches', 'HMMresults', 'BoTWnew','timer');
        end
        
    end    
end
