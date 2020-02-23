% Task 3: COMPLETED
% clears MatLab by resetting (save key strokes)
clear; close all; clc;

% Load input image
OriginalImage = imread('Starfish.jpg');

% Conversion of input image to greyscale
% Converts the intensity of the image to a double precision
% Used to provide accurate information
ConvDouble = im2double(OriginalImage);

% Converts the image from RGB to Gray
OrigImgGray = rgb2gray(ConvDouble);

% Noise Removal Matlab Code
% two mean filters are applied to reduce noise
% Average/Mean Filter:
% In build function uses a 3 by 3 neighborhood and assign the image the mean
MeanFilter = medfilt2(OrigImgGray);
MeanFilter = medfilt2(MeanFilter);

% This is the matlab code for image sharpening
% Sharpening images increases the contrast along the edges where different colors meet.
ImgSharp = imsharpen(MeanFilter);

% Binary Image Segmentation
% Creatation of a binary image through manual thresholding
% 0.910 is a scalar luminance value
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

% Used to return structure about each object in the image
% Connectivity, ImageSize, NumObjects and PixelIdxList
ImgConCom = bwconncomp(ImgDilate);

% S holds the area and PixelList for each object in the CC struct
% PixelList is x,y coordinates of each pixel in each object
ImgProp = regionprops(ImgConCom,'Area','PixelList');

% read areas from the CC struct to the vector
for i=1:ImgConCom.NumObjects
    areas(i) = ImgProp(i).Area;
end

% transpose to make it vertical
areas=areas';

%structuring elements for post-processing skeleton
% Endpoints stucture
StrucEp = strel('disk',6);
% Branchpoints structure
StrucBp = strel('disk',20);

% Creatation of a new black blank image to store only found stars.
binaryCombined = false(size(ImgDilate));

% Loop through all objects found in the image
for ObjNo=1:ImgConCom.NumObjects
    
    % Creatation of empty binary image for storing each object individualy
    % using the size of the orignal image.
    obj = false(size(ImgDilate));
    
    % Loop through the Pixel List and map over the object onto the blank
    % canvas visible as white with black background
    for i=1:length(ImgProp(ObjNo).PixelList)
        obj(ImgProp(ObjNo).PixelList(i,2),ImgProp(ObjNo).PixelList(i,1))=1;
    end
    
    % Reduces the object into a 1 pixel wide curved lines without changing
    % the structure of the image.
    Skel = bwskel(obj);
    
    %calculate morphological skeleton of the object
    SkelProp = bwmorph(Skel,'Skel','Inf');
    
    figure;imshow(obj);title('Individual Object');
    pause(0.25);
    figure;imshow(SkelProp);title('Skeleton of Object');
    pause(0.25);
    close all
    
    %calculate end points of the object and use imdilate to remove extra
    %points. Calculate the number of points using bwconncomp
    ObjEp = bwmorph(SkelProp,'Endpoints');
    % Dilates the image using the larger disk structuring element.
    LrgObjEp = imdilate(ObjEp,StrucEp);
    % Creates another struct holding properties of the image
    Dilated_Ep = bwconncomp(LrgObjEp);
    
    %calculate branches of the object and use imdilate to remove extra
    %branches. Calculate the number of branches using bwconncomp
    ObjBp = bwmorph(SkelProp,'Branchpoints');
    % Dilates the image using the larger disk structuring element.
    LrgObjBp = imdilate(ObjBp,StrucBp);
    % Creates another struct holding properties of the image
    Dilated_Bp = bwconncomp(LrgObjBp);
    
    
    % Checks to see if the objec is the same as a star shape
    % Stars have 5 ends/points and 1 branchpoint
    if (Dilated_Ep.NumObjects == 5) && (Dilated_Bp.NumObjects == 1)
        figure;imshow(obj);
        pause(2);
        close all
        % loop over all rows and columns for the binary canvas
        for ii=1:size(obj,1)
            for jj=1:size(obj,2)
                % get pixel value
                pixel=obj(ii,jj);
                % if the pixel is equal to 1 on the object image, transfer
                % that pixel to the same location on the binary canvas
                if pixel == 1
                    % Asignment of true to the binary canavs to add the
                    % star
                    binaryCombined(ii,jj) = true;
                end
            end
        end
    end
end

% Used to return structure about each object in the image
% Connectivity, ImageSize, NumObjects and PixelIdxList
ImgConCom = bwconncomp(binaryCombined);

% Starfish recognition
BiImg = binaryCombined;
% Stores all shapes/objects into a vector containg only white objects.
ImgLabel = bwlabel(BiImg);
% Obtains the area and perimeter of each objects logical value
S = regionprops(logical(BiImg), 'Area', 'Perimeter');
% Creates an empty
metrics = zeros(1,ImgConCom.NumObjects);

% Stores all the areas from objects
% The total number of pixels that an object occupie
area = [S.Area];

% Stores all the perimeters from objects
% The distance around the outside edge of the object
perimeter = [S.Perimeter];

% Loops through the length of the metric (25) and applies a roundness
% equation to determine the shape factor of the object
for i = 1 : length(metrics)
    % This gives indication as to the object shape. Circles have the greates
    % areras to permiter ration and this formula will approach a vlaue of 1 for
    % a perfect circle.
    % Squares are aroudn 0.78
    metrics(i) = 4*pi*area(i)/perimeter(i).^2;
end

% Show all metric values to inspect them
disp(metrics);

% Find all starfish obejcts based on roundness metric range
Starfish = find(( metrics > 0.21)  & (metrics < 0.27));

% new image containing only starfish
StarfishImg = ismember(ImgLabel, Starfish);


% Making the Skeleton and border Pretty
BW1 = bwskel(ImgDilate);
BW2 = bwperim(ImgDilate,8);
skeleton = bwmorph(BW1, 'skel', 'inf');
BW3 = imfuse(skeleton, BW2);

% Recognised Starfish through skeleton end points and branches Display
figure;imshow(StarfishImg);title('Starfish Recognition Using a Skeleton Structural Descriptor and shape factor');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

% Seperated Shapes with Skeletons with Borders
figure;imshow(BW3);title('All Objects with Skeletons and Borders');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.5);

% Seperated Shapes with skeletons
figure;imshow(skeleton);title('All Objects Skeletons');
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


