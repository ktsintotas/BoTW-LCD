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

function HMM = HMMinitialization(visualData)
    
    % observation presented along the procedure
    HMM.observations = int8(ones(1, visualData.imagesLoaded));
    % loop states presented along the procedure
    HMM.loopStates = int8(ones(1, visualData.imagesLoaded));
    % forward probabilities generated along the procedure
    HMM.forwardProb = double(zeros(2, visualData.imagesLoaded));
    
end