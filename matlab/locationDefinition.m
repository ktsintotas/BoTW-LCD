% 

% Copyright 2019, Konstantinos A. Tsintotas
% ktsintot@pme.duth.gr
%
% This file is part of iBoTW framework for visual loop closure detection
%
% iBoTW framework is free software: you can redistribute 
% it and/or modify it under the terms of the MIT License as 
% published by the corresponding authors.
%  
% iBoTW pipeline is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% MIT License for more details. <https://opensource.org/licenses/MIT>

function [properImage, inliersTotal, timer] = locationDefinition(params, matches, candidateLocationsScores, It, iBoTW, visualData, timer)

    inliersTotal = int16(0);
    properImage = int16(0);
    
    % geometrical check = OFF, temporal consistency = OFF
    if params.verification == false && (params.temporalConsistency == false || (params.temporalConsistency == true && matches.matches(It-1) == 0))
        [value, ~] = min(candidateLocationsScores(candidateLocationsScores>0));
        if value ~= 0                       
            properImage = max(find(candidateLocationsScores == value));
        end
    % geometrical check = OFF, temporal consistency = ON
    elseif params.verification == false && params.temporalConsistency == true && matches.matches(It-1) ~= 0
        firstImg = matches.matches(It-1) - params.locationRange;
        lastImg = matches.matches(It-1) + params.locationRange;
        if firstImg < length(candidateLocationsScores)
            scores = candidateLocationsScores(max(1, firstImg) : min(length(candidateLocationsScores), lastImg));
            [value, ~] = min(scores(scores>0));
            if value ~= 0
                properImage = max(find(candidateLocationsScores == value));
            end
        end                            
    % geometrical check = ON, temporal consistency = OFF
    elseif params.verification == true && (params.temporalConsistency == false || (params.temporalConsistency == true && matches.matches(It-1) == 0))       
        candidates = find(candidateLocationsScores);
        [~,idxx] = sort(candidateLocationsScores(candidates), 'ascend');
        candidates = candidates(idxx);
        if sum(candidates) ~= 0
            % start the timer for the geometrical verification
            tic            
            [properImage, inliersTotal] = geometricalCheck(It, iBoTW, params, candidates, visualData);            
            % stop the timer for the geometrical verification
            timer.geometricalVerification(It, 1) = toc;
        end
    % geometrical check = ON, temporal consistency = ON
    elseif params.verification == true && params.temporalConsistency == true && matches.matches(It-1) ~= 0                                                       
        firstImg = matches.matches(It-1) - params.locationRange;
        lastImg = matches.matches(It-1) + params.locationRange;
        if firstImg < length(candidateLocationsScores)
            candidates = find(candidateLocationsScores(max(1, firstImg) : min(length(candidateLocationsScores), lastImg)));
            candidates = int16(candidates) + max(1, firstImg) -1;
            [~,idxx] = sort(candidateLocationsScores(candidates), 'ascend');
            candidates = candidates(idxx);
            if sum(candidates) ~= 0
                % start the timer for the geometrical verification
                tic
                [properImage, inliersTotal] = geometricalCheck(It, iBoTW, params, candidates, visualData);
                % stop the timer for the geometrical verification
                timer.geometricalVerification(It, 1) = toc;
            end
        end                                                             
    end
end