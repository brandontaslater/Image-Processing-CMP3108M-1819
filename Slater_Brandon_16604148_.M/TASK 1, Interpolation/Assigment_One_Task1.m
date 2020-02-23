% Task 1:
% clears MatLab by resetting (save key strokes)
clear; close all; clc;


% Read me function
InputImage = imread('Zebra.jpg');
% Convert to Grayscale function
InputImageGray = rgb2gray(InputImage);
% Get image information
[Rows, Columns, size] = size(InputImageGray);





% Window Display 1:
% Original input image
f1 = figure(); % Creates a graphic object, used to open individual windows
movegui(f1,'northwest');
imshow(InputImage);
title('Step-1: Load input image');


% Window Display 2:
% Grayscale out put image
f2 = figure; % Creates a graphic object, used to open individual windows
movegui(f2,'northeast');
imshow(InputImageGray);
title('Step-2: Conversion of input image to greyscale');

% Resize of Images:
% Nearest Neighbour Interpolation Resize of Grayscale Image
NearNeighImage = NearestNeighbourInterpolation(InputImageGray, 3);
% Bilinear Interpolation Resize of Grayscal Image
BilenearImage = BilinearInterpolation(InputImageGray, 3);

% Window Display 3:
% Grayscale out put image
f3 = figure; % Creates a graphic object, used to open individual windows
imshow(NearNeighImage);
title('Step-3: Resize of the Grayscale Image by a factor of 3 using Nearest Neighbour Interpolation');

% Window Display 4:
% Grayscale out put image
f4 = figure; % Creates a graphic object, used to open individual windows
imshow(BilenearImage);
title('Step-4: Resize of the Grayscale Image by a factor of 3 using Bilinear Interpolation');

% Window Display 5:
% displays all 4 image in a grid in one window for viewing
f5 = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,1),imshow(InputImage); % subplot for original image
title('Original Image:'); % title for original image
subplot(2,2,2),imshow(InputImageGray); % subplot for grayscale of original image
title('Grayscale of Original Image'); % title for grayscale image
subplot(2,2,3),imshow(NearNeighImage); % subplot for nearest neighbour image
title('Nearest Neighbour Interpolation by 3x'); % title for nearest neighbour image
subplot(2,2,4),imshow(BilenearImage); % subplot for bilinear image
title('Bilinear Interpolation by 3x'); % title for bilinear image


% Nearest Neighbour Interpolation
function Img_zoomed = NearestNeighbourInterpolation(OriginalImage, factor)
[Height, Width] = size(OriginalImage); % gets the height and width of the image
NewHeight = Height*factor; % sets the new height
NewWidth = Width*factor; % sets the new width
Img_zoomed = uint8(ones(NewHeight, NewWidth)); % creates a new array to store the new image

% loops the new height
for NewH = 0:NewHeight-1
    % loops the width
    for NewW = 0:NewWidth-1
        y = floor(NewH/factor); % rounds down for old Height
        x = floor(NewW/factor); % rounds down for old Width
        Img_zoomed(NewH+1, NewW+1) = OriginalImage(y+1, x+1); % assigns pixel at height and width of original image
    end
end
end


% Bilinear Interpolation
function ScaledImage = BilinearInterpolation(OriginalImage, zoom)
[Height, Width, d] = size(OriginalImage); % Gets Image height, width and dimentions
NewHeight = floor(zoom*Height); % rounds down stop error
NewWidth = floor(zoom*Width); % rounds down stop error
NewImage = zeros(NewHeight,NewWidth,d); % creates the new image
% loops New image height
for NH = 1:NewHeight
    % gets x coordinates for 4 nearest pixels
    % converts NH into a unsigned 32 integer
    % X1 X2 represent old image size, 3 of the same value each time
    x1 = cast(floor(NH/zoom),'uint32'); % floor round down
    x2 = cast(ceil(NH/zoom),'uint32'); % Ceil round up
    % error handling to stop pixel from being 0
    if x1 == 0
        x1 = 1;
    end
    x = rem(NH/zoom,1); % Rem returns the remainder of the division
    % loops New image Width
    for NW = 1:NewWidth
        % gets y coordinates for 4 nearest pixels
        % converts NH into a unsigned 32 integer
        % Y1 Y2 represent old image size, 3 of the same value each time
        y1 = cast(floor(NW/zoom),'uint32'); % floor round down
        y2 = cast(ceil(NW/zoom),'uint32'); % Ceil round up
        % error handling to stop pixel from being 0
        if y1 == 0
            y1 = 1;
        end
        % 4 Nearest pixels
        PixTopleft = OriginalImage(x1,y1,:); %top left
        PixBottLeft = OriginalImage(x2,y1,:); %bottom left
        PixTopRight = OriginalImage(x1,y2,:); %top right
        PixBottRight = OriginalImage(x2,y2,:); %bottom right
        
        y = rem(NW/zoom,1); % Rem returns the remainder of the division
        % works out the two points between the upper and lower pixels
        TopRow = (PixTopRight*y)+(PixTopleft*(1-y));
        BottRow = (PixBottRight*y)+(PixBottLeft*(1-y));
        % new pixel assigned to aproximate intensity
        NewImage(NH,NW,:) = (BottRow*x)+(TopRow*(1-x));
    end
end
ScaledImage = cast(NewImage,'uint8');
end
