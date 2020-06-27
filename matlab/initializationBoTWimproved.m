% 

% Copyright 2019, Konstantinos A. Tsintotas
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

function iBoTW = initializationBoTWimproved(BoTW, visualData)
        
        % creating the new Bag of Tracked Words which would subjected into management
        iBoTW = BoTW;
        % the deteled words
        iBoTW.deleted = [];
        % Tracked Word merge Counter
        iBoTW.twMergerCounter = int16(ones(size(iBoTW.bagOfTrackedWords, 1), 1));
        % Tracked Word indexing
        iBoTW.twLocationIndex = false(size(BoTW.bagOfTrackedWords, 1), visualData.imagesLoaded);
        for i = 1 : size(iBoTW.twIndex, 1)
            iBoTW.twLocationIndex(i, iBoTW.twIndex(i, 1) : iBoTW.twIndex(i, 2)) = true;
        end

end