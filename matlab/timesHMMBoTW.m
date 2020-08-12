sumTiming = zeros(visualData.imagesLoaded, 1,'single');

for It = 1 : visualData.imagesLoaded
    
    sumTiming(It, 1) = timer.featuresDetection(It, 1) + timer.featuresDescription(It, 1) + timer.trackingPoints(It, 1) + timer.guidedFeatureSelection(It, 1) + timer.databaseSearch(It, 1) + ...
         timer.binomialScoring(It, 1) + timer.geometricalVerification(It, 1);
    
end

% average time for feature detection            %%%%%%%%
candidatesFeaturesDetection = single(find(timer.featuresDetection(:, 1) >= 0));
avgFeaturesDetection = mean(timer.featuresDetection(candidatesFeaturesDetection, 1));
standardDeviationFeaturesDetection = std(timer.featuresDetection(candidatesFeaturesDetection, 1));
% clear vars candidatesFeaturesDetection avgFeaturesDetection standardDeviationFeaturesDetection

% average time for feature description            %%%%%%%%
candidatesFeaturesDescription = single(find(timer.featuresDescription(:, 1) >= 0));
avgFeaturesDescription = mean(timer.featuresDescription(candidatesFeaturesDescription, 1));
standardDeviationFeaturesDescription = std(timer.featuresDescription(candidatesFeaturesDescription, 1));
% clear vars candidatesFeaturesDescription avgFeaturesDescription standardDeviationFeaturesDescription

% average time for feature tracking            %%%%%%%%
candidatesTrackingPoints = single(find(timer.trackingPoints(:, 1) >= 0));
avgTrackingPoints = mean(timer.trackingPoints(candidatesTrackingPoints, 1));
standardDeviationTrackingPoints = std(timer.trackingPoints(candidatesTrackingPoints, 1));
% clear vars candidatesTrackingPoints avgTrackingPoints standardDeviationTrackingPoints

% average time for guided feature selection            %%%%%%%%
candidatesGuidedFeatureSelection = single(find(timer.guidedFeatureSelection(:, 1) >= 0));
avgGuidedFeatureSelection = mean(timer.guidedFeatureSelection(candidatesGuidedFeatureSelection, 1));
standardDeviationGuidedFeatureSelection = std(timer.guidedFeatureSelection(candidatesGuidedFeatureSelection, 1));
% clear vars candidatesGuidedFeatureSelection avgGuidedFeatureSelection standardDeviationGuidedFeatureSelection

% average time for database search            %%%%%%%%
candidatesDatabaseSearch = single(find(timer.databaseSearch(:, 1) >= 0));
avgDatabaseSearch = mean(timer.databaseSearch(candidatesDatabaseSearch, 1));
standardDeviationDatabaseSearch = std(timer.databaseSearch(candidatesDatabaseSearch, 1));
% clear vars candidatesDatabaseSearch avgDatabaseSearch standardDeviationDatabaseSearch

% average time for binomial scoring            %%%%%%%%
candidatesBinomialScoring = single(find(timer.binomialScoring(:, 1)>= 0));
avgBinomialScoring = mean(timer.binomialScoring(candidatesBinomialScoring, 1));
standardDeviation = std(timer.binomialScoring(candidatesBinomialScoring, 1));
% clear vars candidatesBinomialScoring avgBinomialScoring standardDeviation

% average time for geometrical verification            %%%%%%%% 
candidatesGeometricalVerification = single(find(timer.geometricalVerification(:, 1) >= 0));
avgGeometricalVerification = mean(timer.geometricalVerification(candidatesGeometricalVerification, 1));
standardDeviationGeometricalVerification = std(timer.geometricalVerification(candidatesGeometricalVerification, 1));
% clear vars candidatesGeometricalVerification avgGeometricalVerification standardDeviationGeometricalVerification

sumAvg = avgFeaturesDetection + avgFeaturesDescription + avgTrackingPoints + avgGuidedFeatureSelection +...
    avgDatabaseSearch + avgBinomialScoring + avgGeometricalVerification + avgWordsUpdate;
