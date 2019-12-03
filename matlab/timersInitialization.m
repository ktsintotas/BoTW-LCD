function timer = timersInitialization(params)

    timer.featuresDetection = zeros(visualData.imagesLoaded, 1,'single');
    timer.featuresDescription = zeros(visualData.imagesLoaded, 1,'single');
    timer.trackingPoints = zeros(visualData.imagesLoaded, 1,'single');
    timer.guidedFeatureSelection = zeros(visualData.imagesLoaded, params.numPointsToTrack,'single');
    timer.databaseSearch = zeros(visualData.imagesLoaded, 1,'single');
    timer.votesDistribution = zeros(visualData.imagesLoaded, 1,'single');
    timer.bayesianFiltering = zeros(visualData.imagesLoaded, 1,'single');
    timer.geometricalVerification = zeros(visualData.imagesLoaded, 1,'single');

end
