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

function [properImage, inliersTotal, timer] = locationDefinition(params, matches, candidateLocationsVotes, It, iBoTW, visualData, timer)

    inliersTotal = int16(0);
    properImage = int16(0);
    
    % geometrical check = OFF, temporal consistency = OFF
    if params.verification == false && (params.temporalConsistency == false || (params.temporalConsistency == true && matches.matches(It-1) == 0))
        [votes, ~] = max(candidateLocationsVotes);
        if votes ~= 0
            [~, properImage] = max(candidateLocationsVotes);
        end
    % geometrical check = OFF, temporal consistency = ON
    elseif params.verification == false && params.temporalConsistency == true && matches.matches(It-1) ~= 0
        firstImg = matches.matches(It-1) - params.locationRange;
        lastImg = matches.matches(It-1) + params.locationRange;
        if firstImg < length(candidateLocationsVotes)
            [votes, ~] = max(candidateLocationsVotes(max(1, firstImg) : min(length(candidateLocationsVotes), lastImg)));                        
            if votes ~= 0
                [~, properImage] = max(candidateLocationsVotes(max(1, firstImg) : min(length(candidateLocationsVotes), lastImg)));                        
                properImage = properImage + max(1, firstImg) -1;
            end
        end                            
    % geometrical check = ON, temporal consistency = OFF
    elseif params.verification == true && (params.temporalConsistency == false || (params.temporalConsistency == true && matches.matches(It-1) == 0))
        candidates = find(candidateLocationsVotes);
        [~,idxx] = sort(candidateLocationsVotes(candidates), 'descend');
        candidates = candidates(idxx);
        if sum(candidates) ~= 0
            tic % GEOMETRICAL VERIFICATION
            [properImage, inliersTotal] = geometricalCheck(It, iBoTW, params, candidates, visualData);
            timer.geometricalVerification(It, 1) = toc;
        end
    % geometrical check = ON, temporal consistency = ON
    elseif params.verification == true && params.temporalConsistency == true && matches.matches(It-1) ~= 0                                                       
        firstImg = matches.matches(It-1) - params.locationRange;
        lastImg = matches.matches(It-1) + params.locationRange;
        if firstImg < length(candidateLocationsVotes)
            candidates = find(candidateLocationsVotes(max(1, firstImg) : min(length(candidateLocationsVotes), lastImg)));
            candidates = int16(candidates) + max(1, firstImg) -1;
            [~,idxx] = sort(candidateLocationsVotes(candidates), 'descend');
            candidates = candidates(idxx);
            if sum(candidates) ~= 0
                tic % GEOMETRICAL VERIFICATION
                [properImage, inliersTotal] = geometricalCheck(It, iBoTW, params, candidates, visualData);
                timer.geometricalVerification(It, 1) = toc;
            end
        end                                                             
    end
end