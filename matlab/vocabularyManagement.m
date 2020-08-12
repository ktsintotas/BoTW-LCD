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

function [BoTWnew, timer] = vocabularyManagement(BoTWnew, wordsToManage, It, properImage, matches, params, timer)
    
    wordsDist = zeros(length(wordsToManage), 1);
    wordsToDelete = single(zeros(1, length(wordsToManage)));
    
    for w = 1 : length(wordsToManage)        

        h = size(BoTWnew.trackedWordDescriptors{wordsToManage(w)}, 1);
        % find which descriptor is being tracked from the query points and subsequently is transformed into Tracked Word
        id = knnsearch(BoTWnew.queryDescriptors{It}, BoTWnew.trackedWordDescriptors{wordsToManage(w)}(end, :), 'K', 1);
        % indicate the correspondances between the generated tracked word and the database matches
        votedDatabaseWords = uint16(matches.knnIDx(id, It - h + 1: It));
        % highlight the maximum correspondance database word
        votedNonZeros = nonzeros(votedDatabaseWords)';
        [~, idx] = max(sum(votedNonZeros == votedNonZeros'));
        idx = find(votedDatabaseWords == votedNonZeros(idx));
        idx = idx(1);

        % comparison between the tracked words
        wordsDist(w) = norm(BoTWnew.bagOfTrackedWords(wordsToManage(w), :) - BoTWnew.bagOfTrackedWords(votedDatabaseWords(idx), :));
        
        if wordsDist(w) <= params.queryingDatabase.wordsDist && ...  
            BoTWnew.twLocationIndex(votedDatabaseWords(idx), properImage) == true 

            % renew the visual word
            BoTWnew.bagOfTrackedWords(votedDatabaseWords(idx), :) = median([BoTWnew.bagOfTrackedWords(votedDatabaseWords(idx), :) ; ... 
                BoTWnew.trackedWordDescriptors{wordsToManage(w)}], 1 );                           
            % renew indexing
            BoTWnew.twLocationIndex(votedDatabaseWords(idx), :) = ...
                or(BoTWnew.twLocationIndex(votedDatabaseWords(idx), :), BoTWnew.twLocationIndex(wordsToManage(w), :));
            % increase the number of merged words
            wordsToDelete(w) = wordsToManage(w);       
        end
        
    end 
        
    % deleting the generated words which are very similar and are merged
    wordsToDelete = wordsToDelete(wordsToDelete>0)';
    BoTWnew.bagOfTrackedWords(wordsToDelete, :) = [];
    BoTWnew.twIndex(wordsToDelete, :) = [];
    BoTWnew.twLocationIndex(wordsToDelete, :) = [];
    BoTWnew.trackedWordPoints(wordsToDelete) = [];
    BoTWnew.trackedWordDescriptors(wordsToDelete) = [];
    BoTWnew.deleted = [BoTWnew.deleted; wordsToDelete];    
    
end
