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

function [properImage, inliersTotal, HMMresults, timer] = locationDefinition(params, HMMresults, matches, candidateLocationsScores, It, iBoTW, visualData, timer)

    
    properImage = uint16(0);
    inliersTotal = uint16(0);    

    % HMM observation == 2
    if HMMresults.observations(It) == 2     
        candidates = find(candidateLocationsScores);
        if length(candidates) < 10
            [~,idxx] = sort(candidateLocationsScores(candidates), 'ascend');
            candidates = candidates(idxx(1)); 
            firstImg = max(1, candidates - params.queryingDatabase.locationRange);
            lastImg = candidates + params.queryingDatabase.locationRange;
            candidateLocationsScores = matches.binomialMatrix(It, firstImg : lastImg);            
            [~,idxx] = sort(candidateLocationsScores, 'ascend');
            candidates = firstImg : lastImg;
            candidates = candidates(idxx);
            c = matches.binomialMatrix(It, (candidates))>0;
            candidates = candidates(c ==true);           
        else
            [~,idxx] = sort(candidateLocationsScores(candidates), 'ascend');
            candidates = candidates(idxx); 
        end
        if ~isempty(candidates)
            % start the timer for the geometrical verification
            tic            
            [properImage, inliersTotal] = geometricalCheck(It, iBoTW, params, candidates, visualData);            
            % stop the timer for the geometrical verification
            timer.geometricalVerification(It, 1) = toc;
        end
        
    % HMM observation == 1
    elseif HMMresults.observations(It) == 1 && matches.matches(It-1) ~= 0
        firstImg = max(1, matches.matches(It-1) - params.queryingDatabase.locationRange);
        lastImg = matches.matches(It-1) + params.queryingDatabase.locationRange;        
        candidateLocationsScores = matches.binomialMatrix(It, firstImg : lastImg);   
        [~,idxx] = sort(candidateLocationsScores, 'ascend');
        candidates = firstImg : lastImg;
        candidates = candidates(idxx);        
        c = matches.binomialMatrix(It, (candidates))>0;
        candidates = candidates(c ==true);          
        % start the timer for the geometrical verification
        if ~isempty(candidates)
            tic
            [properImage, inliersTotal] = geometricalCheck(It, iBoTW, params, candidates, visualData);            
            % stop the timer for the geometrical verification
            timer.geometricalVerification(It, 1) = toc;
        end
    end
end
