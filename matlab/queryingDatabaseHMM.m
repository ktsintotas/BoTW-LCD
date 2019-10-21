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

function [matches, HMMresults, iBoTW] = queryingDatabaseHMM(params, visualData, BoTW)

    if params.queryingDatabaseHMM.load == true && exist('results/queryingDatabaseHMM.mat', 'file')    
        load('results/queryingDatabaseHMM.mat');

    else

        iBoTW = initializationBoTWimproved(BoTW, visualData);
        matches = matchesInitialization(visualData, params);
        HMMresults = HMMinitialization(visualData);

        for It = int16(1 : visualData.imagesLoaded)    
disp(It)
            % B.1 MAP VOTING
            % excluding the vocabulary area which would be avoided  
            if iBoTW.maximumActivePoint(It) < visualData.frameRate
                lastDatabaseLocation = It - ceil(3 * visualData.frameRate);
            else
                lastDatabaseLocation = It - ceil( 3 * iBoTW.maximumActivePoint(It) );
            end
            if lastDatabaseLocation > 0
                databaseIndexTemp = single(find(iBoTW.twIndex(:, 2) <= lastDatabaseLocation));                
                if ~isempty(databaseIndexTemp)                    
                    databaseIndexTemp = databaseIndexTemp(end);
                    % visual vocabulary to be searched
                    database = iBoTW.bagOfTrackedWords(1 : databaseIndexTemp, :);                     
                else
                     database = single([]);
                end
            else
                database = single([]);
            end

            % vote aggregation
            if ~isempty(database) && size(iBoTW.queryDescriptors{It}, 1) > params.inliersTheshold
                if parallel.gpu.GPUDevice.isAvailable                    
                    % k-NN search using the GPU if available
                    queryIdxNN = gather(single(knnsearch(gpuArray(database), gpuArray(iBoTW.queryDescriptors{It}), 'K', 1 )));                    
                else
                    % k-NN search
                    queryIdxNN = single(knnsearch(database, iBoTW.queryDescriptors{It}, 'K', 1, 'NSMethod', 'exhaustive'));
                end
                % knn Indexing for the correspondance at visual vocabulary management
                matches.knnIDx(1 : length(queryIdxNN), It) = queryIdxNN;                    
                
                % votes distribution through the Nearest Neighbor procedure
                for v = int16(1 : length(queryIdxNN))                    
                    votedLocations = int16(find(iBoTW.twLocationIndex(queryIdxNN(v), 1 : lastDatabaseLocation) == true));
                    matches.votesMatrix(It, votedLocations) = matches.votesMatrix(It, votedLocations) + 1;                    
                end
              
                % B.2 PROBABILISTIC BELIEF GENERATOR
                % high-voted locations for binomial probability computation process
                imagesForBinomial = int16(find(matches.votesMatrix(It, 1 : lastDatabaseLocation) >= 0.02 * size(iBoTW.queryDescriptors{It}, 1)));
                % locations which pass the two conditions
                candidateLocationsObservation2 = zeros(1, lastDatabaseLocation, 'int16');
                candidateLocationsObservation3 = zeros(1, lastDatabaseLocation, 'int16');
                % number of Tracked Words within the searching area 
                LAMDA = databaseIndexTemp;
                % number of query�s Tracked Points (number of points after the guided feature-detection)
                N = size(iBoTW.queryDescriptors{It}, 1);                
                % number of accumulated votes of database location l
                xl = matches.votesMatrix(It, imagesForBinomial);
                % number of TWs members in l over the size of the BoTW list (without the rejected locations)
                p = single(iBoTW.lamda(imagesForBinomial)) / LAMDA;
                % distribution�s expected value 
                expectedValue = N*p;
                % probability computation for the selected images in the database
                %locationProbability = gather(binopdf(gpuArray(xl), gpuArray(N), gpuArray(p)));
                locationProbability = binopdf(xl, N , p);
                % binomial Matrix completion
                matches.binomialMatrix(It, imagesForBinomial) = locationProbability;
                % the binomial expected value on each location has to
                % satisfy two conditions, (1) loop closure threshold and (2) over expected value xl(t) > E [Xi(t)]
                Condition2Locations = int16(find(xl > expectedValue));
                % locations which satisfy condition 2 and condition 1 - observation 3
                if ~isempty(Condition2Locations) ... 
                        && ~isempty(find(locationProbability(Condition2Locations) < params.observation3threshold, 1))
                    HMMresults.observations(It) = 3;
                    candidateLocations = imagesForBinomial(Condition2Locations(find(locationProbability(Condition2Locations) < params.observation3threshold)));
                    candidateLocationsObservation3(candidateLocations) = matches.votesMatrix(It, candidateLocations);
                % locations which satisfy condition 2 and condition 1 - observation 2
                elseif ~isempty(Condition2Locations) && sum(candidateLocationsObservation3) == 0 ...
                        && ~isempty(find(locationProbability(Condition2Locations) < params.observation2threshold, 1))
                    HMMresults.observations(It) = 2;
                    candidateLocations = imagesForBinomial(Condition2Locations(find(locationProbability(Condition2Locations) < params.observation2threshold)));
                    candidateLocationsObservation2(candidateLocations) = matches.votesMatrix(It, candidateLocations);                
                end
                
                % MATCHING PROCEDURE
                % the original approach
                if params.filtering == false && sum(candidateLocationsObservation3) ~= 0 && params.verification == false                
                    [~, properImage] = max(candidateLocationsObservation3);
                    matches.loopClosureMatrix(It, properImage) = true;
                    matches.matches(It) = properImage;                    
                % using the geometrical check in the original version by searching to every location in cases of votes' equality, 
                % also "no" temporal consistency is included
                elseif params.filtering == false && sum(candidateLocationsObservation3) ~= 0 && params.verification == true          
                    [votes, ~] = max(candidateLocationsObservation3);
                    candidates = find(candidateLocationsObservation3 == votes);
                    properImage = geometricalCheck(It, iBoTW, params, candidates);
                    if properImage ~= 0
                        matches.loopClosureMatrix(It, properImage) = true; 
                        matches.matches(It) = properImage;                                  
                    end              
                    
                % filter the binomial state-result through HMM forward algorithm 
                elseif params.filtering == true
                    % Hidden Markov Model process
                    [HMMresults] = forwardHMM(HMMresults, params, It);                
                    
                    % observation 3 and loop closure detection
                    if HMMresults.loopStates(It) == 2 && HMMresults.observations(It) == 3         
                        % define the appropriate high-voted loop closure image from the candidate ones
                        [properImage, inliersTotal] = locationDefinition(params, matches, candidateLocationsObservation3, It, iBoTW, visualData);                   
                        if properImage ~= 0
                            matches.loopClosureMatrix(It, properImage) = true;
                            matches.matches(It) = properImage;
                            matches.inliers(It) = inliersTotal;
                        end                        
                        % vocabulary management
                        if  params.vocabularyManagement == true && properImage ~= 0 && matches.loopClosureMatrix(It, properImage) == true
                            wordsToManage = single(find(iBoTW.twIndex(:, 2) == It));                    
                            if ~isempty(wordsToManage)                        
                                iBoTW = vocabularyManagement(iBoTW, wordsToManage, It, properImage, matches, visualData, params);                        
                            end
                        end

                    % observation 2 and loop closure detection
                    elseif HMMresults.loopStates(It) == 2 && HMMresults.observations(It) == 2
                        % define the appropriate high-voted loop closure image from the candidate ones
                        [properImage, inliersTotal] = locationDefinition(params, matches, candidateLocationsObservation2, It, iBoTW, visualData);
                        if properImage ~= 0
                            matches.loopClosureMatrix(It, properImage) = true;
                            matches.matches(It) = properImage;            
                            matches.inliers(It) = inliersTotal;
                        end        
                        % vocabulary management
                        if  params.vocabularyManagement == true && properImage ~= 0 && matches.loopClosureMatrix(It, properImage) == true
                            wordsToManage = single(find(iBoTW.twIndex(:, 2) == It));                    
                            if ~isempty(wordsToManage)                        
                                iBoTW = vocabularyManagement(iBoTW, wordsToManage, It, properImage, matches, visualData, params);                        
                            end
                        end
                    end
                end
            end
        end
        
        if params.queryingDatabaseHMM.save
            save('results/queryingDatabaseHMM', 'matches', 'HMMresults', 'iBoTW'); 
        end
        
    end    
end