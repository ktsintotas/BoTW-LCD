function timer = timersInitialization(visualData, timer)

    % timer for feature tracking pre-allocation
    timer.trackingPoints = zeros(visualData.imagesLoaded, 1,'single');
    % timer for guided feature selection pre-allocation
    timer.guidedFeatureSelection = zeros(visualData.imagesLoaded, 1,'single');
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
