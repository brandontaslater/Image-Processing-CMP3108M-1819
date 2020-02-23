% Task 4: COMPLETED
% clears MatLab by resetting (save key strokes)
clear; close all; clc;

% Load input image
OriginalImage = imread('Starfish.jpg');

% Stores information about the original image.
[rows,cols,planes] = size(OriginalImage);

% Conversion of input image to greyscale
% Converts the intensity of the image to a double precision
% Used to provide accurate information
ConvDouble = im2double(OriginalImage);

% Converts the image from RGB to Gray
OrigImgGray = rgb2gray(ConvDouble);

% Noise RemoValue Matlab Code
% two mean filters are applied to reduce noise
% Average/Mean Filter:
% In build function uses a 3 by 3 neighborhood and assign the image the mean
MeanFilter = medfilt2(OrigImgGray);
MeanFilter = medfilt2(MeanFilter);

% This is the matlab code for image sharpening
% Sharpening images increases the contrast along the edges where DiffOfSigserent colors meet.
ImgSharp = imsharpen(MeanFilter);

% Binary Image Segmentation
% Creatation of a binary image through manual thresholding
% 0.910 is a scalar luminance Valueue
Binary = imbinarize(ImgSharp, 0.910);

% Invert the image such that black is the background
BinaryImg = ~Binary ;

% Morphological Processing
% Creates a square structuring element whose width is 4 pixels.
SqStructure = strel('square',4);
% Creates a disk-shaped structuring element, where r specifies the radius.
DiscStructure = strel('disk',3);
% Erosion of the image using the square structuring element.
ImgErode = imerode(BinaryImg, SqStructure);
% Dilates the image using the square structuring element.
ImgDilate = imdilate(ImgErode, DiscStructure);

% this removes smaller objects
% the smaller objects that are removed are less than 0.5%
BW2 = bwareaopen(ImgDilate, ceil((rows*cols)*0.005));

ThickenImg = BW2;

% The properties of the image are obtained through using RegionProps
% looks at the 1's of the image
% the output into ImgProp is Area, PixelList, Centroid and Perimeter
% Area; stores the areas of each object in the matrix
% Centroid; stores the center of each object by coordinates in the matrix
% PixelList; stores a list of each objects pixesl within this matrix
% Perimeter; stores the perimerter of each object in the matrix
ImgProp = regionprops(ThickenImg,'Area','PixelList','Centroid','Perimeter');

% creates an empty double to stores the average perimeter
AvgPmt = double(0);

% loops through all objects perimeters
% adds all perimeters together for the sum
for x = 1:length(ImgProp)
    AvgPmt = AvgPmt + ImgProp(x).Perimeter;
end

% works out the average of the objects perimeters
AvgPmt = AvgPmt / length(ImgProp);

% convert the average perimeter to a whole number (rounds down)
AvgPmt = floor(AvgPmt);

% Signatures will hold all the object signitures
Signatures = double(zeros(AvgPmt,length(ImgProp)));

% Stores the number of peaks found for each objects interpolated boundary
% to centroid difference. (identifies the number of legs for star
% recognition)
HighPoints = double(zeros(1,length(ImgProp)));

% Loop through all the objects in the image
for ObjNo=1:length(ImgProp)
    
    % Creates new image to the size of orginal image
    % this stores each object in the binary image for each interation
    ObjectImg = false(rows,cols);
    
    % For the current iterative object, for loop from 1 to the Area size of
    % the object
    for Pixel=1:ImgProp(ObjNo).Area
        
        % taking the object from the binary image and segmenting it by
        % itself, pixel list hold all pixels in x y coordinates which
        % is used to rebuild the object in the same place on a new
        % image for analysis.
        % Iteration through Pixel
        % Stores ObjectImg as the segmented object
        ObjectImg(ImgProp(ObjNo).PixelList(Pixel,2),ImgProp(ObjNo).PixelList(Pixel,1))=1;
        
    end
    
    %Find the center of the object
    ObjStats=regionprops(ObjectImg,'Centroid');
    
    %Find the ObjBoundary of the object
    ObjBoundary=bwboundaries(ObjectImg);
    
    % Stores the objects centroid as a x y coordinates
    ObjCentroid = ObjStats(1).Centroid;
    
    % Stores X Y coordinates for each pixel in the objects perimeter
    bound = ObjBoundary(1);
    
    % Access the bound struct through 1,1 which stores an 2d array
    % Stores all the X coordinates for each boundary
    Xaxis = bound{1,1}(:,1);
    
    % Access the bound struct through 1,1 which stores an 2d array
    % Stores all the Y coordinates for each boundary
    Yaxis = bound{1,1}(:,2);
    
    % Find the DistCentToBound from the center to the ObjBoundary
    DistCentToBound = sqrt((Yaxis-ObjCentroid(1)).^2+(Xaxis-ObjCentroid(2)).^2);
    
    % transpose the DistCentToBound
    DistCentToBound = DistCentToBound';
    
    % Stores the length of the distances array
    DistLength = length(DistCentToBound);
    
    % Stores the reconstructed distances
    % highest value in index is found
    % from that point till end is copied into reconstruction distances
    % the rest of old distances is copied underneath
    ReConDistances = double(zeros(1,DistLength));
    
    % used to reference the position in the reconstruction distances
    % arry to loop through the size of the distances
    Initialise = 1;
    
    % finds the value and the index of the highest value in the
    % distances to be used as the first value in ReConDistances
    [Value, MaxIndex] = max(DistCentToBound);
    
    % loops through index of highest value to the length of distances
    % Intialise goes from 1 to (distanceLength minus Index value)
    for L = MaxIndex:DistLength
        % adds distance to ReConDistances
        ReConDistances(Initialise) = DistCentToBound(L);
        % Increments value for ReConDistances
        Initialise = Initialise + 1;
    end
    
    % loops through 1 to index mins 1
    % Intialise is the last value, to the end of old distances
    for L = 1:MaxIndex-1
        % adds distance to ReConDistances
        ReConDistances(Initialise) = DistCentToBound(L);
        % Increments value for ReConDistances
        Initialise = Initialise +1;
    end
    
    % interplorate the DistCentToBound to ReConDistances
    InterpolDist = interp1(linspace(0,1,DistLength),ReConDistances,linspace(0,1,(AvgPmt)));
    
    % transpose the interpolation distances
    InterpolDist = InterpolDist';
    
    % Nomralize the data, used for Y axis
    InterpolDist = normalize(InterpolDist, 'Scale');
    
    % For the length of Signatures
    for h = 1:AvgPmt
        % copy the DistCentToBound to Signatures array,
        Signatures(h,ObjNo) = InterpolDist(h);
    end
    
    % Loops through all the plots for graphs
    t=1:1:AvgPmt;
    
    HighPoints(ObjNo) = length(findpeaks(InterpolDist,'MinPeakProminence',1)) + 1;
    
    [~,locs_Rwave] = findpeaks(InterpolDist,'MinPeakProminence',1);
    
    % Displays the object image
    subplot(2,1,1), imshow(ObjectImg), title('Object')
    % Plots the interpolation distances along the graph
    subplot(2,1,2),hold on, plot(t,InterpolDist),plot(locs_Rwave,InterpolDist(locs_Rwave),'rv','MarkerFaceColor','r');
    grid on
    legend('Objects interpolated Signatures','Points in the Object')
    xlabel('Samples')
    pause(2);
    close all;
    
end

% Create an SumSqDifferences matrix used to store 3 lists
% List 1: object 1
% List 2: object 2
% List 3: Sum Squared Difference
SumSqDifferences = double(zeros(3,length(ImgProp)*length(ImgProp)));

% interator used for SumSqDifferences matrix length
CompLength = 1;

% used to remove duplication is comparisions between objects
Reduce = 0;

% all objects compared agaist all objects
% loops through the list of objects = XObj
for XObj = 1:length(ImgProp)
    
    % loops through the list of objects = YObj
    for YObj = 1+Reduce:length(ImgProp)
        
        % Dont compare the same objects
        if YObj == XObj
            % if equal do nothing
        else
            
            % Stores the object in the XObj
            objx = false(size(ImgDilate));
            % Stores the object in the XObj
            objy = false(size(ImgDilate));
            
            % Loop through the Pixel List and map over the object onto the blank
            % canvas visible as white with black background
            for i=1:length(ImgProp(XObj).PixelList)
                objx(ImgProp(XObj).PixelList(i,2),ImgProp(XObj).PixelList(i,1))=1;
            end
            for i=1:length(ImgProp(YObj).PixelList)
                objy(ImgProp(YObj).PixelList(i,2),ImgProp(YObj).PixelList(i,1))=1;
            end
            
            
            % Displays the object image
            subplot(2,1,1), imshow(objx), title('Object')
            % Plots the interpolation distances along the graph
            subplot(2,1,2), imshow(objy), title('Object');
            pause(0.2);
            close all;
            
            % Difference of Object X and Y signatures
            DiffOfSigs = double(Signatures(:,XObj)) - double(Signatures(:,YObj));
            
            %stores single Sum Squared Difference of Object X and Y
            SumSqDiff = sum(DiffOfSigs(:).^2);
            
            %Store the first obj number used
            SumSqDifferences(1,CompLength) = XObj;
            
            %Store second obj number used
            SumSqDifferences(2,CompLength) = YObj;
            
            %Store the SumSqDiff calculated
            SumSqDifferences(3,CompLength) = SumSqDiff;
            
            %Increments the comparison Length
            CompLength = CompLength + 1;
        end
        
    end
    Reduce = Reduce+1;
end

% Create a black false image to store the final objects
StarsImage = false(rows,cols);

%For the length of the SumSqDifferences
for LoopVal = 1:length(SumSqDifferences)
    
    % value between 0 and 100 we have found similiar shapes = (stars)
    if SumSqDifferences(3,LoopVal) < 100 && SumSqDifferences(3,LoopVal) > 0
        
        % checks the object has 5 peaks on the graph
        % used to verify the object is a star
        if HighPoints(SumSqDifferences(1,LoopVal)) == 5 && HighPoints(SumSqDifferences(2,LoopVal)) == 5
            % Found object placed into final image
            % Loops through every pixel
            % finds the pix coordinates in the PixelList, uses these values to
            % set the value to = 1 for displaying white starts
            for p=1:ImgProp(SumSqDifferences(1,LoopVal)).Area
                StarsImage(ImgProp(SumSqDifferences(1,LoopVal)).PixelList(p,2),ImgProp(SumSqDifferences(1,LoopVal)).PixelList(p,1)) = 1;
            end
            for p=1:ImgProp(SumSqDifferences(2,LoopVal)).Area
                StarsImage(ImgProp(SumSqDifferences(2,LoopVal)).PixelList(p,2),ImgProp(SumSqDifferences(2,LoopVal)).PixelList(p,1)) = 1;
            end
        end
    end
    
end

% Final Image Display
figure;imshow(StarsImage);title('Starfish Recognition Using Shape Signatures and Graph Peak Analysis');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

% Dilation of the binary image
figure;imshow(ImgDilate);title('Dilation of Binary Image');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

% Erosion of the binary image
figure;imshow(ImgErode);title('Erosion of Binary Image');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

% Invert Binary Image so Black in Background
figure;imshow(BinaryImg);title('Inverted Binary Image');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

% Conversion to Binary
figure;imshow(Binary);title('Conversion to Binary Using Manual Thresholding 0.910');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

% Image Sharpening using ImSharpen
figure;imshow(ImgSharp);title('Image Sharpening for Shape Edge Contrast');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

% Noise Removal Using Mean Filter
figure;imshow(MeanFilter);title('Mean Filter for Noise Reduction');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

% Grayscale
figure;imshow(OrigImgGray);title('Grayscale Origninal');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

% Original Image Display
figure;imshow(OriginalImage);title('Original Image of Starfish');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

