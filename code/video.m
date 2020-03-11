% Parameters
videoPath = "/Users/charlescarver/Google Drive/VLC - NYIT REU 2017/Images/Pictures of Florescent Light/";
videoName = "monday july 10/S8/Light 1/Front Video/S8 ISO 319.mp4";
scale = 1;
threshold = 0.3;
startFrame = 150;
endFrame = 200;

% Close annoying windows
close all;

% Set up variables
v = VideoReader(char(videoPath + videoName));
intensityVector = [];
i = 1;
frames = ceil(floor(v.FrameRate * v.Duration));

% Loop through frames
while hasFrame(v)
    
    % Skip any initial frames
    frame = readFrame(v, i);
    if i >= startFrame
        
        % Rotate frame
        %frame = imrotate(frame, 90);
        
        % Convert image
        converted = rgb2gray(frame);
        converted = imresize(converted, 1/scale);
        converted = imbinarize(converted, threshold);
        converted = bwareaopen(converted, 5);
        converted = imclose(converted, strel('line', 100, 0));

        % Find intense region of light
        r = regionprops(converted, 'BoundingBox', 'Area');
        [maxArea, indexOfMax] = max([r.Area]);
    
        % Check to see if it exists
        if indexOfMax
           
            % Crop image to this region
            crop = [r(indexOfMax).BoundingBox(1)*scale, r(indexOfMax).BoundingBox(2)*scale, r(indexOfMax).BoundingBox(3)*scale, r(indexOfMax).BoundingBox(4)*scale];
            maskedImage = imcrop(frame, crop);
            maskedImage = rgb2gray(maskedImage);
            imshow(maskedImage);

            % Loop through all the column
            [rows, columns, dimensions] = size(maskedImage);
            for column = 1:columns
                
                % Sum the pixel intensities across each column
                % r = sum(maskedImage(:, column, 1));
                % g = sum(maskedImage(:, column, 2));
                % b = sum(maskedImage(:, column, 3));
                % gray = (0.2989 * r + 0.5870 * g + 0.1140 * b);
                % columnVector(column) = gray;
                % columnVector(column) = sum(maskedImage(:, column));
                % columnVector(column) = (b + r) - (g);
                intensityVector(end+1) = sum(maskedImage(:, column));
            end

            % Loop finished
            fprintf("Finshed loop %i/~%i\n", i, frames);
            
        % Region did not exist
        else
            
            % Loop failed
            fprintf("Skipped loop %i/~%i\n", i, frames);
        end
    end
    
    % Skip any end frames
    if endFrame >= 0 && i >= endFrame
        break;
    end
    
    % Increment counter
    i = i + 1;
end



% Determine size
[~, samples] = size(intensityVector);

figure
plot(1:samples, intensityVector, 'r');


even_avg = mean(intensityVector(1, 2:2:end));
odd_avg = mean(intensityVector(1, 1:2:end));
intensityVector(1, 2:2:end) = intensityVector(1, 2:2:end)/even_avg;
intensityVector(1, 1:2:end) = intensityVector(1, 1:2:end)/odd_avg;

% Polynomial fit
[p, ~, mu] = polyfit(1:samples, intensityVector, 5);
for x = 1:samples
    f = polyval(p, x, [], mu);
    intensityVector(x) = intensityVector(x)/f;
end

% Plot
figure
plot(1:samples, intensityVector, 'g');




% FFT
Fs = 64800;%73,440;           % Sampling frequency (sps)                
T = 1/Fs;             % Sampling period     
L = samples;             % Length of signal (number of samples)
NFFT = 2^nextpow2(L);

[pxx, f] = periodogram(intensityVector, hamming(L), NFFT, Fs);

% Plot FFT

figure
plot(f/1000, 10*log10(pxx)); % x-axis: frequency (kHz), y-axis: power (DCBs) 
% 
% 

% t = sgolayfilt(pxx, 2, 17);
% figure
% plot(f/1000, 10*log10(t));

