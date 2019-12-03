%% Algorithm initialization 

clear all; close all; clc;
loadImages = true;

%% Method's Functions Paths

addpath('C:\Users\tsiid\OneDrive - Democritus University of Thrace\PhD Documents\11-Paper Implementation\4-Bag of Tracked Words\Method\Method Functions');
addpath('C:\Users\tsiid\OneDrive - Democritus University of Thrace\PhD Documents\11-Paper Implementation\0-Datasets Attachments\Ground Truth Functions');
addpath('C:\Users\tsiid\OneDrive - Democritus University of Thrace\PhD Documents\11-Paper Implementation\4-Bag of Tracked Words\Method\Timing');

%% Load variables

if loadImages == true
    load('imagesKITTI00');
    clear var loadImages
else
   %% Loading directories 
    pngImagesPath = ('C:\Users\tsiid\OneDrive - Democritus University of Thrace\PhD Documents\13-Datasets\KITTI\data_odometry_gray\sequences\00\image_1\');
    pngImages = dir([pngImagesPath '*.png']);  % Load images from directory
    fields = {'folder','date','bytes','isdir','datenum'}; % Fields to be removed from pngImages structure
    pngImages = rmfield(pngImages, fields); % Images to be fed at the algorithm
    clearvars fields % Clear variable "fields from memory"
   %% Loading images and point extraction and description   
    imagesLoaded = size(pngImages,1);
    for j = 1 : imagesLoaded
        inputImage{j} = imread([pngImagesPath pngImages(j).name]);
        %inputImage{j} = rgb2gray(inputImage{j});
    end
    clear var j loadImages
    save('imagesKITTI00', 'inputImage', 'imagesLoaded');
end

%% Variables initialization

trackLength = 4; % above this number a new visual word is created
numPointsToTrack = 200; % Declare the number of points which would be tracked  
% Point tracker Variables
bagTrackedFeatures = cell(200,1); % Declare the Bag of Tracked Features
pointsFedtoTracker = cell(4541,1); % Declare the variable where the points which are going to be fed to tracker would be saved
% Points' tracking  Variables
trackObservation = cell(4541,1); % Checks the tracking validity by our conditions
trackedPoints = cell(1,4541); 
trackedPointsValidity = cell(1,4541); 
pointRepresentation = cell(4541,1);
timeFeaturesDetection = zeros(imagesLoaded, 1,'single');
timeFeaturesDescription = zeros(imagesLoaded, 1,'single');
timeTrackingPoints = zeros(imagesLoaded, 1,'single');
timeGuidedFeatureDetection = zeros(imagesLoaded, 1,'single');
timeGuidedFeatureDetection2 = [];
% On - Line Visual Vocabulary
visualVocabulary = []; % generation of visual vocabulary matrix
invertIndex = single([]);
vwCounter = 0;  
timeVisualVocabularyGeneration= zeros(imagesLoaded, 1,'single');
% Query procedure
queryFeatures = cell(4541,1);
threshold = 2e-11;
Bin = zeros(imagesLoaded, imagesLoaded, 'double');
expectedValue= zeros(imagesLoaded, imagesLoaded, 'double'); 
loopClosureMatrixSequences = zeros(imagesLoaded, imagesLoaded, 'logical');
loopClosureMatrixImages = zeros(imagesLoaded, imagesLoaded, 'logical');
loopClosureMatrix = zeros(imagesLoaded, 2, 'single');
imgVotes = cell(imagesLoaded,1);
searchVocabulary = single([]);
searchInvertIndex = single([]);
% Voting Scheme
timeVotingScheme = zeros(imagesLoaded, 1,'single');
% Binomial
timeBinomial = zeros(imagesLoaded, 1,'single');
timeImagePairing = zeros(imagesLoaded, 1,'single');
% RANSAC
geometricalCheck = true;
ransacInfo = zeros(imagesLoaded, 4,'single');
F = cell(1, imagesLoaded);
inliersIndex = cell(1, imagesLoaded);
status = cell(1, imagesLoaded);
numInliers = cell(1, imagesLoaded);
loopClosureMatrixRansac = zeros(imagesLoaded, 2, 'single');
timeGeometricalCheck = zeros(imagesLoaded, 1,'single');

%% Start of our method
for j =1 : imagesLoaded
% for j =1 : imagesLoaded
    disp(j);
    if j == 1
        firstImg = 1;
        tic
        points_img{j} = detectSURFFeatures(inputImage{j}, 'MetricThreshold', 400.0); % Detect features SURF
        timeFeaturesDetection(j, 1) = toc;
        [imgFeatures{j}, imgPoints{j}] = extractFeatures(inputImage{j}, points_img{j}, 'Method','SURF'); % Extract SURF descriptors
        tic
        timeFeaturesDescription(j, 1) = toc;
        
        % Initialization of tracked features bag
        if size(imgFeatures{firstImg}, 1) > numPointsToTrack
            for t = 1 : numPointsToTrack 
                bagTrackedFeatures{t, 1} = imgFeatures{firstImg}(t, :); % Putting SURF Local Features into Bag
            end
        else
            for t = 1 : size(imgFeatures{firstImg}, 1)
                bagTrackedFeatures{t, 1} = imgFeatures{firstImg}(t, :); % Putting SURF Local Features into Bag
            end
            for i = t+1 : numPointsToTrack
                bagTrackedFeatures{i, 1} = [];
            end
        end
        clear var t i
       
        % Point tracker  
        if size(imgPoints{firstImg}, 1) > numPointsToTrack
            pointsFedtoTracker{firstImg, 1} = imgPoints{firstImg}.Location(1:numPointsToTrack , :); % Declaration of initial points to tracker
        else
            pointsFedtoTracker{firstImg, 1} = imgPoints{firstImg}.Location(1:size(imgFeatures{firstImg}) , :); % Declaration of initial points to tracker
        end
        pointTracker = vision.PointTracker('NumPyramidLevels',3,'MaxBidirectionalError',3); % Returns a point tracker object that tracks a set of points in a video.
        initialize(pointTracker,  pointsFedtoTracker{firstImg, 1} , inputImage{firstImg} );

        % Points' tracking 
        if size(pointsFedtoTracker{firstImg}, 1) < numPointsToTrack
            for t = 1 : size(pointsFedtoTracker{firstImg}, 1) % Initialization of point representation
                pointRepresentation{firstImg, 1}(t, 1) = single(1);
                trackObservation{firstImg , 1}(t , 1) = true;
            end
            pointRepresentation{firstImg, 1}(t+1:numPointsToTrack , 1) = 0;
            trackObservation{firstImg , 1}(t+1:numPointsToTrack , 1) = false;
        else
            for t = 1 : numPointsToTrack % Initialization of point representation
                pointRepresentation{firstImg, 1}(t, 1) = single(1);
                trackObservation{firstImg , 1}(t , 1) = true;
            end
        end    
        clear var t
        l = zeros(size(inputImage,2), 1, 'single'); % variable for counting the number of tracked features in each image for binomial
    end
    
    if j > 1
        followingImg = j;
        tic
        points_img{j} = detectSURFFeatures(inputImage{j}, 'MetricThreshold', 400.0); % Detect features SURF
        timeFeaturesDetection(j, 1) = toc; % Time for feature extraction and description
        tic
        [imgFeatures{j}, imgPoints{j}] = extractFeatures(inputImage{j}, points_img{j}, 'Method','SURF'); % Extract SURF descriptors
        timeFeaturesDescription(j, 1) = toc; % Time for feature extraction and description
        
        if followingImg > 2
            firstImg = followingImg - 1; % After the first image the following has to be the previous one as firstImage
            release(pointTracker); % Objects lock when you call them and the release function unlocks them
            initialize(pointTracker, pointsFedtoTracker{firstImg, 1} , inputImage{firstImg}  ); % Initialize again the tracker with the new, more accurate, points
        end
       
        tic
        [trackedPoints{followingImg}, trackedPointsValidity{followingImg}] = pointTracker(inputImage{followingImg}); % Tracked points in the incoming frame 
        timeTrackingPoints(j,1) = toc; % Time for point tracking
        
       % Descriptor selection for bag of tracked features

        % Guided points detection through Nearest Neighbor between three descriptors
        tempnewPoint = single(0);
        preservedPoints = {};
        IdxNN = single([]);
        Dist = single([]);
        D = single([]);
        excludedPoint = single([]); 
        pointsToSearch = single([]);
        pointsToSearch = imgPoints{followingImg}.Location;
        featuresToSearch = imgFeatures{followingImg};
        excludedPoint = true(size(pointsToSearch,1),1);
       % tic
        for t = 1 : numPointsToTrack
            pointsToSearch2 = pointsToSearch(excludedPoint,:); % Exclusion of point that used before from tracking device for avoidance of duplicate
            featuresToSearch2 = featuresToSearch(excludedPoint, :); % Exclusion of descriptor that used before from tracking device for avoidance of duplicate
         %   Mdl = KDTreeSearcher(pointsToSearch); % Creation of KD-Tree on detected point space of incomming image    
                tic
            if t <= size(trackedPointsValidity{followingImg}, 1) && trackedPointsValidity{followingImg}(t) == 1 % Check if point of the first image is tracked and if the number of features are lower the desired continue
         %    [IdxNN(t, 1), D(t,1)] = knnsearch( Mdl, trackedPoints{followingImg}(t, :), 'K', 1 ); % kNN would identify which SURF DETECTED Points are associated to the tracked one          
                [IdxNN(t, 1), D(t,1)] = knnsearch( pointsToSearch2, trackedPoints{followingImg}(t, :), 'K', 1 ); % kNN would identify which SURF DETECTED Points are associated to the tracked one          
                [p, ~] = knnsearch(imgPoints{firstImg}.Location, pointsFedtoTracker{firstImg}(t, :),'K', 1 );
         %    [~, Dist(t ,1)] = featureComparison( imgFeatures{firstImg}(p,:) , featuresToSearch(IdxNN(t,1) , :) );  
                Dist(t ,1)= norm( imgFeatures{firstImg}(p,:) - featuresToSearch2(IdxNN(t,1) , :) );
                timeGuidedFeatureDetection2(j,t) = toc; % Time for point tracking

                if   ( D(t,1) > 5 && Dist(t,1) > 0.60 ) % Two conditions for acceptance of tracking feature
                    trackObservation{followingImg , 1}(t , 1) = false; % Respectively with points_validity but now under conditions
                    pointRepresentation{followingImg, 1}(t , 1) = pointRepresentation{firstImg, 1}(t, 1);
                    preservedPoints{t, 1} = [];
                    %preservedFeatures{t, 1} = [];
%                     excludedPoint = [];
                else
                    bagTrackedFeatures{t} = [ bagTrackedFeatures{t}; featuresToSearch2(IdxNN(t,1) , :) ]; % Adding features to be transformed into VWs
                    trackObservation{followingImg , 1}(t , 1) = true ; % Respectively with points_validity but now under conditions
                    pointRepresentation{followingImg, 1}(t , 1) = pointRepresentation{firstImg, 1}(t , 1) + 1 ; % Track representance
                    tempnewPoint = IdxNN(t,1); % IndexPair determines the nearest descriptor, so this point we would be held for new points
                    preservedPoints{t, 1} = pointsToSearch2(tempnewPoint, :); % To maintain the correct points - detected points in following image                   
                    %preservedFeatures{t, 1} = featuresToSearch(tempnewPoint, :); % To maintain the correct features in following image                   
                    excludedPoint(tempnewPoint) = false;
                end
            else
                trackObservation{followingImg , 1}(t , 1) = false;        
                preservedPoints{t, 1} = [];
                %preservedFeatures{t, 1} = [];
                pointRepresentation{followingImg , 1}(t , 1) = pointRepresentation{firstImg, 1}(t, 1);      
%                 excludedPoint = [];
            end
        end    
        pointsToSearch(excludedPoint, :) = []; % Exclusion of point that used before from tracking device for avoidance of duplicate
        featuresToSearch(excludedPoint, :) = []; % Exclusion of descriptor that used before from tracking device for avoidance of duplicate
  %     timeGuidedFeatureDetection(j,1) = toc; % Time for point tracking
        clear var t Mdl IdxNN D p Dist tempnewPoint excludedPoint
        % On - Line Visual Vocabulary
        tic
        for vw = 1 : numPointsToTrack % vw is the counter for visual words
            if ( trackObservation{followingImg , 1} (vw , 1) == false && pointRepresentation{followingImg, 1}(vw , 1) > trackLength )...
                    && ~isempty( bagTrackedFeatures{vw,1} )
                visualWord = mean( bagTrackedFeatures{vw,1} , 1 );            
                visualVocabulary = [visualVocabulary ; visualWord];
                vwCounter =  vwCounter + 1;            
                invertIndex(vwCounter, 1) = followingImg - pointRepresentation{followingImg, 1}(vw,1); % first image where the feature is observed
                invertIndex(vwCounter, 2) = followingImg - 1; % last image where the feature is observed 
                invertIndex(vwCounter, 3) = pointRepresentation{followingImg, 1}(vw,1);
                bagTrackedFeatures{vw,1} = {};
                for g = invertIndex(vwCounter, 1) : invertIndex(vwCounter, 2)
                    l(g, 1) = l(g, 1) + 1;
                end
            end
        end
        timeVisualVocabularyGeneration(j,1) = toc;
        clear vars vw visualWord 
        
        % Creating new points for Tracker by adding new points to general points
        newPointCounter = 0;
        for np = 1 : numPointsToTrack % trackingPoints
            if trackObservation{followingImg , 1} (np , 1) == false && newPointCounter < size(pointsToSearch, 1)
                newPointCounter = newPointCounter + 1;
                preservedPoints{np} = pointsToSearch(newPointCounter, : );
                %preservedFeatures{np} = featuresToSearch(newPointCounter, : );  % Filling out with new descriptors for the query process
                bagTrackedFeatures{np} = featuresToSearch(newPointCounter, : ) ; % Adding features to be transformed into VWs
                trackObservation{followingImg , 1}(np , 1) = true ; % Respectively with points_validity but now under conditions
                pointRepresentation{followingImg,1}(np , 1) = 1 ; % Track representance               
            elseif trackObservation{followingImg , 1} (np , 1) == false && newPointCounter >= size(pointsToSearch, 1) % When there are not enough point to cover the gap
                preservedPoints{np} = single([1 1]);
                %preservedFeatures{np} = single(1:1:64);
            end
        end
        pointsFedtoTracker{followingImg, 1} = cell2mat(preservedPoints);
 %       queryFeatures{followingImg,1} = cell2mat(preservedFeatures);
        clear vars np newPointCounter pointsToSearch featuresToSearch preservedPoints

        % Query procedure
        
        %Visual search area definition           
        if size(imgPoints{j}.Location, 1) > numPointsToTrack
            queryFeatures{j,1} = imgFeatures{j}(1:numPointsToTrack, :); % hold the defined strongest
            queryPoints{j,1} = imgPoints{j}(1:numPointsToTrack, :); % hold the defined strongest
       else
            queryFeatures{j,1} = imgFeatures{j}(1:size(imgPoints{j}.Location, 1), :); % hold as more as possible features
            queryPoints{j,1} = imgPoints{j}(1:size(imgPoints{j}.Location, 1), :); % hold the defined strongest
        end
        
        tempSearchIndex = j - 2 * max(pointRepresentation{j, 1}); % indicating the vocabulary area wich would not searched  
        if  tempSearchIndex  > 0
            searchIndex = find(invertIndex(:,2) <= tempSearchIndex);
           if ~isempty(searchIndex) 
                searchIndex = searchIndex(end);
                searchVocabulary = visualVocabulary(1:searchIndex, :); % visual vocabulary to be searched
                searchInvertIndex = invertIndex(1:searchIndex, :); % invertIndex of visual vocabulary to be searched     
           else
                searchVocabulary = [];   
           end     
        end

       % Vote aggregation
       
        if ~isempty(searchVocabulary)
            lastImgToSearch = searchInvertIndex(searchIndex , 2);
            imgScore = zeros(1, lastImgToSearch, 'single'); % column vector for vote aggregation
            
            tic
            queryMdl = ExhaustiveSearcher(searchVocabulary); % preparing visual vocabulary for kNN search
            queryIdxNN = knnsearch( queryMdl, queryFeatures{j,1} , 'K', 1 ); % kNN search procedure  at visual vocabulary            
            for v = 1 : length(queryIdxNN)
                imgFirst = searchInvertIndex(queryIdxNN(v) , 1);
                imgLast = searchInvertIndex(queryIdxNN(v) , 2);
                for d = imgFirst : imgLast
                    imgScore(d) = imgScore(d) + 1;  
                end        
            end
            timeVotingScheme(j,1) = toc;
            imgVotes{j,1} = imgScore;
            clear vars v imgFirst  imgLast d queryIdxNN
            
           % Binomial probability for each image
            L = size(searchVocabulary, 1); % Number of descriptors within the searching area (Visual Vocabulary - search)   
            N = size(queryFeatures{j}, 1);
            
            Bin = Bin';
            expectedValue = expectedValue';
            
            tic
            for t = 1 : lastImgToSearch
                li = l(t, 1) ;  % ë number of points which are tracked and are part of vocabulary
                xi = imgScore(t); % number of votes for img t     
                p = li/L;
                E_x = N*p;
                imgBinProbability = binopdf(xi, N , p);
                Bin(t, j) = imgBinProbability; 
                expectedValue(t, j) = E_x; % for a loop closure to be accepted xi(t) > E [Xi(t)]
                % identify loop closing candidate images
                if Bin(t, j) < threshold && xi > expectedValue(t, j) 
                    loopClosureMatrixSequences(t, j) = true;
                else
                    loopClosureMatrixSequences(t, j) = false;
                end
            end
            timeBinomial(j,1) = toc;
            
            Bin = Bin';
            expectedValue = expectedValue';
            % define the appropriate loop closing image for the system
           
            [~, indexOfMaximum] = max(imgVotes{j, 1});  % max number of votes aggregated to an image and its position
            if loopClosureMatrixSequences(j, indexOfMaximum) == true
                tic
                loopClosureMatrixImages(j, indexOfMaximum) = true; 
                loopClosureMatrix = [loopClosureMatrix ; j indexOfMaximum];
                timeImagePairing(j,1) = toc;
                if geometricalCheck == true
                    % RANSAC procedure
                    tic
                    indexPairs = matchFeatures(queryFeatures{j}, imgFeatures{indexOfMaximum}, 'Unique', true);
                    matchedPoints1 =  queryPoints{j}(indexPairs(:,1),:);
                    matchedPoints2 = imgPoints{indexOfMaximum}(indexPairs(:,2),:);
                    try
                    [F{j}, inliersIndex{j}, status{j}] = estimateFundamentalMatrix(matchedPoints1,matchedPoints2, 'Method', 'RANSAC', 'DistanceThreshold', 1);
                    numInliers{j} = sum(inliersIndex{j});
                    ransacInfo(j, 1) = j; 
                    ransacInfo(j, 2) = indexOfMaximum;
                    if ~isempty(numInliers{j})
                        ransacInfo(j, 3) = numInliers{j};
                    else
                        ransacInfo(j, 3) = 0;
                    end
                    catch
                        ransacInfo(j, 1) = j;
                        ransacInfo(j, 2) = indexOfMaximum;
                        ransacInfo(j, 3) = 0;
                    end
                    timeGeometricalCheck(j,1) = toc;
                    if ransacInfo(j, 3) < 9
                        ransacInfo(j, 4) = false;
                    else
                    ransacInfo(j, 4) = true;
                    loopClosureMatrixRansac = [loopClosureMatrixRansac ; j indexOfMaximum];
                    end
                end                
            else
                loopClosureMatrixImages(j, indexOfMaximum) = false;
            end       
        end     
    end
end

save('resultsTimesKITTI00Lucas');