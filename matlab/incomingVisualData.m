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

function [visualData, timer] = incomingVisualData(params, dataPath, dataFormat)
    
    % shall we load the visual information and its' extracted variables?
    if params.visualData.load == true && exist('results/visualData.mat', 'file')    
        load('results/visualData.mat');  
        
    else       
        
        % list of the dataset's images
        images = dir([dataPath dataFormat]);
        % fields to be removed from images' structure
        fields = {'folder','date','bytes','isdir','datenum'};    
        images = rmfield(images, fields);
        % the total of the incomming visual sensory information
        visualData.imagesLoaded = int16(size(images, 1));
        
        % only for New College dataset
%         images(1 : 2 : size(images,1)) = []; % Extracting the left camera measurements
%         images = images(1 : 20 : size(images, 1));
%         visualData.imagesLoaded = int16(size(images,1));     
                
        % images' space pre-allocation
        visualData.inputImage = cell(1, visualData.imagesLoaded);
        % images' descriptors space pre-allocation
        visualData.featuresSURF = cell(1, visualData.imagesLoaded);
        % images' points space pre-allocation
        visualData.pointsSURF = cell(1, visualData.imagesLoaded);        
        
        % timer for feature detection pre-allocation
        timer.featuresDetection = zeros(visualData.imagesLoaded, 1,'single');
        % timer for feature description pre-allocation
        timer.featuresDescription = zeros(visualData.imagesLoaded, 1,'single');
        
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
            % SURF detection
            visualData.pointsSURF{It} = detectSURFFeatures(visualData.inputImage{It},  'MetricThreshold', params.featuresResponse);
            % stop the timer for the points' detection
            timer.featuresDetection(It, 1) = toc;
            
            % start the timer for the points' description
            tic
            % SURF description
            [visualData.featuresSURF{It}, ~] = extractFeatures(visualData.inputImage{It}, visualData.pointsSURF{It}, 'Method','SURF');
            % stop the timer for the points' description
            timer.featuresDescription(It, 1) = toc;
            
        end
        
        % save the variables if not they not allready exist
        if params.visualData.save
            save('results/visualData', 'visualData', 'timer', '-v7.3');
        end
        
    end
    
end