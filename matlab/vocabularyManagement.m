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

function BoTWnew = vocabularyManagement(BoTWnew, wordsToManage, It, properImage, matches, visualData, params)

    wordsDist = zeros(length(wordsToManage), 1);
    wordsToDelete = [];
    
     if params.visualizationMerging == true
         close all;
     end
    
    for w = 1 : length(wordsToManage)        
              
        h = size(BoTWnew.trackedWordDescriptors{wordsToManage(w)}, 1);
        % find which descriptor is being tracked from the query points which subsequently is transformed into Tracked Word
        id = knnsearch(BoTWnew.queryDescriptors{It}, BoTWnew.trackedWordDescriptors{wordsToManage(w)}(end, :), 'K', 1);
        % indicate the correspondances between the generated tracked word and the database matches
        votedDatabaseWords = int16(matches.knnIDx(id, It - h + 1: It));
        % highlight the maximum correspondance database word
        votedNonZeros = nonzeros(votedDatabaseWords)';
        [occurences, idx] = max(sum(votedNonZeros == votedNonZeros'));
        idx = find(votedDatabaseWords == votedNonZeros(idx));
        idx = idx(1);

        % comparison between the tracked words
        wordsDist(w) = norm(BoTWnew.bagOfTrackedWords(wordsToManage(w), :) - BoTWnew.bagOfTrackedWords(votedDatabaseWords(idx), :));
                
        if wordsDist(w) <= params.wordsDist && (occurences/h) > params.wordsCorrespondence && ...  
                BoTWnew.twLocationIndex(votedDatabaseWords(idx), properImage) == true                
            
            if params.visualizationMerging == true && wordsDist(w) <= params.wordsDist
                
                figure(w);
            
                subplot(1, 2, 1);
                imshow(visualData.inputImage{It}, 'Border','tight');
                hold on
                plot(BoTWnew.queryPoints{It}(id, 1), BoTWnew.queryPoints{It}(id, 2), 'g*');
                title('Query image')  
            
                subplot(1, 2, 2);
                % chosen is the selected tracked word
                chosen = votedDatabaseWords(idx);
                % because of the merging procedure the plotting would be lean on the original words points and descriptors
                id2 = knnsearch(BoTWnew.trackedWordDescriptors{chosen}, BoTWnew.queryDescriptors{It}(id, :), 'K', 1);            
                imshow(visualData.inputImage{BoTWnew.twIndex(chosen) + id2 - 1}, 'Border','tight');            
                hold on            
                plot(BoTWnew.trackedWordPoints{chosen}(id2, 1), BoTWnew.trackedWordPoints{chosen}(id2, 2), 'g*');
                title('Database image')  
            
               pause;
            end
            
            wordsToDelete = [wordsToDelete ; wordsToManage(w)];
            
            % renew the index of the existing word            
            BoTWnew.twLocationIndex(votedDatabaseWords(idx), ...
                  BoTWnew.twIndex(wordsToManage(w), 1) : BoTWnew.twIndex(wordsToManage(w), 2)) = true;
            % hold a counter about how many times a word is merged
            BoTWnew.twMergerCounter(votedDatabaseWords(idx)) = BoTWnew.twMergerCounter(votedDatabaseWords(idx)) + 1;
                
        end
    end
    
    % deleting the generated words which are very similar and are merged
    BoTWnew.bagOfTrackedWords(wordsToDelete, :) = [];
    BoTWnew.twIndex(wordsToDelete, :) = [];
    BoTWnew.twLocationIndex(wordsToDelete, :) = [];
    BoTWnew.twMergerCounter(wordsToDelete, :) = [];
    BoTWnew.trackedWordPoints(wordsToDelete) = [];
    BoTWnew.trackedWordDescriptors(wordsToDelete) = [];
    BoTWnew.deleted = [BoTWnew.deleted; wordsToDelete];    
    
end