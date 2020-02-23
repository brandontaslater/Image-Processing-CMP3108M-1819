% Task 2:
% clears MatLab by resetting (save key strokes)
clear; close all; clc;


% Read me function
InputImage = imread('Noisy.png');
% Convert to Grayscale function
InputImageGray = rgb2gray(InputImage);
% Get image information
[Rows, Columns, size] = size(InputImageGray);


% Filtering:

MedianFilterImage = MedianFilter(InputImageGray, Rows, Columns);
MedianFilterImage = MedianFilterImage(2+1:end-2,2+1:end-2);
AverageFilterImage = AverageFilter(InputImageGray, Rows, Columns);
AverageFilterImage = AverageFilterImage(2+1:end-2,2+1:end-2);

% Window Display 1:
% Original input image
f1 = figure(); % Creates a graphic object, used to open individual windows
movegui(f1,'northwest');
imshow(InputImage);
title('Image: Original');

% Window Display 2:
% Grayscale out put image
f2 = figure; % Creates a graphic object, used to open individual windows
movegui(f2,'northeast');
imshow(InputImageGray);
title('Image: Original Converted to Grayscale');

% Window Display 3:
% Mean Filtering out put image
f2 = figure; % Creates a graphic object, used to open individual windows
movegui(f2,'northwest');
imshow(AverageFilterImage);
title('Image: Original with Mean Filter');

% Window Display 4:
% Median Filtering out put image
f2 = figure; % Creates a graphic object, used to open individual windows
movegui(f2,'northeast');
imshow(MedianFilterImage);
title('Image: Original with Median Filter');

% Window Display 5:
% displays all 4 image in a grid in one window for viewing
f5 = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,1),imshow(InputImage); % subplot for original image
title('Original Image:'); % title for original image
subplot(2,2,2),imshow(InputImageGray); % subplot for grayscale of original image
title('Grayscale of Original Image'); % title for grayscale image
subplot(2,2,3),imshow(AverageFilterImage); % subplot for Mean filter image
title('Mean Filter on Original Image'); % title for Mean filter image
subplot(2,2,4),imshow(MedianFilterImage); % subplot for Median filter image
title('Median Interpolation on Original Image'); % title for Median filter image

% Functions for Filtering
% Mean Filtering
function AvgImage = AverageFilter(OriginalImage, Height, Width) % passes parameters
AvgImage2 = padarray(OriginalImage, [2 2]); % Adds a padding layer around the image x2
% loops through the height and width of the image, minus 2 for boundaries
for HCycle = 3:Height-2
    for WCycle = 3:Width-2
        avg = uint32(0); % converts the avg to variable able of holding 32 bit numbers
        % loops for getting the 5 by 5 neighbourhood
        for HRan = -2:+1:2
            for WRan = -2:+1:2
                avg = avg + uint32(OriginalImage(HCycle-WRan, WCycle-HRan)); % gets value from original image
            end
        end
        AvgImage2(HCycle, WCycle) = avg/25; %creats median from neighbourhood
    end
end
AvgImage = cast(AvgImage2,'uint8'); % cast the image to the return variable in unit8 image size
end

% Median Filtering
function MedImage = MedianFilter(OriginalImage, Height, Width) % passes parameters
AvgImage2 = padarray(OriginalImage, [2 2]); % Adds a padding layer around the image x2
% loops through the height and width of the image, minus 2 for boundaries
for HCycle = 3:Height-2
    for WCycle = 3:Width-2
        avg = uint32(ones(25)); % converts the avg to variable able of holding 32 bit numbers
        count = 1; % used to count 25 for number of pixels in neighbour
        % loops for getting the 5 by 5 neighbourhood
        for HRan = -2:+1:2
            for WRan = -2:+1:2
                avg(count) = uint32(OriginalImage(HCycle-WRan, WCycle-HRan)); % gets value from original image
                count = count + 1; % increments count until 25
            end
        end
        Avg1 = sort(avg); % sorts the avg in asending order
        AvgImage2(HCycle, WCycle) = Avg1(13); % selects the median from the neighbourhood
    end
end
MedImage = cast(AvgImage2,'uint8'); % cast the image to the return variable in unit8 image size
end


