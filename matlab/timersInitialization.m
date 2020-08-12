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

function timer = timersInitialization(visualData, timer)

    %  memory allocation for timer for feature tracking
    timer.trackingPoints = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for guided feature selection
    timer.guidedFeatureSelection = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for brute force database search
    timer.wordMerging = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for brute force database search
    timer.databaseSearch = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for votes distribution
    timer.votesDistribution = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for binomial scoring
    timer.binomialScoring = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for Bayesian filtering
    timer.bayesianFiltering = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for geometrical verification 
    timer.geometricalVerification = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for geometrical verification 
    timer.wordsUpdate = zeros(visualData.imagesLoaded, 1,'single');
    
end
