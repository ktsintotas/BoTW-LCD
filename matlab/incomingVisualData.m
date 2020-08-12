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

function [visualData, timer] = incomingVisualData(params, dataPath, dataFormat)
    
    % shall we load the visual information and its' extracted variables?
    if params.visualData.load == true && exist('results/visualData.mat', 'file')    
        load('results/visualData.mat'); 
    else       
        % list the dataset's images
        images = dir([dataPath dataFormat]);
        % fields to be removed from images' structure
        fields = {'folder','date','bytes','isdir','datenum'};    
        images = rmfield(images, fields);
        % the total number of the incomming visual sensory information
        visualData.imagesLoaded = uint16(size(images, 1));

%         % uncomment for downsampled New College dataset
%         images(1 : 2 : size(images,1)) = []; % Extracting the left camera measurements
%         images = images(1 : 20 : size(images, 1));
%         visualData.imagesLoaded = int16(size(images,1)); 

%         % uncomment for City Centre dataset
%         images(2 : 2 : size(images,1)) = []; % Extracting the left camera measurements
%         visualData.imagesLoaded = uint16(size(images,1));    

        % pre-allocation of images' space
        visualData.inputImage = cell(1, visualData.imagesLoaded);
        % pre-allocation of images' descriptors space
        visualData.features = cell(1, visualData.imagesLoaded);
        % pre-allocation of images' points space
        visualData.points = cell(1, visualData.imagesLoaded);        
        
        %  pre-allocation of timer for feature detection
        timer.featuresDetection = zeros(visualData.imagesLoaded, 1, 'single');
        % pre-allocation of timer for feature description 
        timer.featuresDescription = zeros(visualData.imagesLoaded, 1, 'single');
        
        for It = 1 : visualData.imagesLoaded            
            
            % display the current frame
            disp(It)
            % read the incoming camera measurement
            visualData.inputImage{It} = imread([dataPath images(It).name]);
            
            % if  the input data is RGB, then convert it to a grayscale one
            if size(visualData.inputImage{It}, 3) == 3
                visualData.inputImage{It} = rgb2gray(visualData.inputImage{It});
            end
            
            % start the timer for the points' detection
            tic
            % points detection
            visualData.points{It} = detectSURFFeatures(visualData.inputImage{It},  'MetricThreshold', params.incomingVisualData.featuresResponse);
            visualData.points{It} = visualData.points{It}.selectStrongest(params.incomingVisualData.strongest);
            % stop the timer for the points' detection
            timer.featuresDetection(It, 1) = toc;
            
            % start the timer for the points' description
            tic
            % Points' description
            [visualData.features{It}, visualData.points{It}] = ...
                extractFeatures(visualData.inputImage{It}, visualData.points{It}, 'Method', 'Auto', 'FeatureSize', params.incomingVisualData.descriptorDimension);
            % stop the timer for the points' description
            timer.featuresDescription(It, 1) = toc;            
        end
        
        % save the variables if not they not allready exist
        if params.visualData.save
            save('results/visualData', 'visualData', 'timer', '-v7.3');
        end
        
    end    
end
