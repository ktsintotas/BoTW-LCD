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

function [HMMresults] = forwardHMM(HMMresults, params, It)
       
    % observation along the trajectory
    Y = HMMresults.observations(It);
    Y = [length(Y) + 1, Y];
    fs = zeros(params.queryingDatabase.numStates, length(Y));    

    % apriori state S_t-1
    if sum(HMMresults.forwardProb(:, It - 1)) == 0
        fs(1, 1) = 1;     
    else
        fs(:, 1) = HMMresults.forwardProb(:, It - 1);
    end    

    % FILTERING based on the forward algorithm
    for i = 2 : length(Y)
        for state = 1 : params.queryingDatabase.numStates
            fs(state, i) = params.queryingDatabase.HMM.EMIS(state, Y(i)) .* (sum(fs(:, i-1) .* params.queryingDatabase.HMM.TRANS(:, state)));
        end
        fs(:, i) =  fs(:, i)./sum(fs(:, i));        
    end
    
    % probabilities registration
    HMMresults.forwardProb(:, It) = fs(:, length(Y));
    % loop closure state
    [~, HMMresults.loopStates(It)] = max(HMMresults.forwardProb(: , It));   
    
end
