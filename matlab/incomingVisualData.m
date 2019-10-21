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

function visualData = incomingVisualData(params, dataPath, dataFormat)
    
    % shall we load the visual information and its' extracted variables?
    if params.visualData.load == true && exist('results/visualData.mat', 'file')    
        load('results/visualData.mat');  
        
    else       
        
        % list images
        images = dir([dataPath dataFormat]);
        % fields to be removed from images' structure
        fields = {'folder','date','bytes','isdir','datenum'};    
        images = rmfield(images, fields);
        % local points extraction and description through SURF method
        visualData.imagesLoaded = int16(size(images,1));
                
        % images' space pre-allocation
        visualData.inputImage = cell(1, visualData.imagesLoaded);
        % images descriptors' space pre-allocation
        visualData.featuresSURF = cell(1, visualData.imagesLoaded);
        % images points' space pre-allocation
        visualData.pointsSURF = cell(1, visualData.imagesLoaded);
        
        for i = 1 : visualData.imagesLoaded
            disp(i)
            visualData.inputImage{i} = imread([dataPath images(i).name]);
            % if input data is RGB convert it to grayscale
            if size(visualData.inputImage{i}, 3) == 3
                visualData.inputImage{i} = rgb2gray(visualData.inputImage{i});
            end
            % SURF points' detection
            visualData.pointsSURF{i} = detectSURFFeatures(visualData.inputImage{i},  'MetricThreshold', 400.0);
            % SURF points' description
            [visualData.featuresSURF{i}, ~] = extractFeatures(visualData.inputImage{i}, visualData.pointsSURF{i}, 'Method','SURF');      
        end
        
        % save the variables if not a file allready exists
        if params.visualData.save
            save('results/visualData', 'visualData', '-v7.3');
        end
    end
end