close all;
path = "/Users/charlescarver/Google Drive/VLC - NYIT REU 2017/Images/Pictures of Fluorescent Light/Experiments/S8, Front Camera, Tripod (Tallest Set-Up), Varying ISOs, Large Data Set/Light #2/Photos/ISO 1201/";

threshold = 0.85;
cropPercentWidth = 0.3;
cropPercentHeight = 0.35;
Fs = 73440;
scale = 1;
topIntensities = [];
bottomIntensities = [];
frames = 50;

for i = 1:frames
    
    % Read
    frame = imread(char(path + i + "i.jpg"));
    frame = imrotate(frame, -90);
    
    % Grayscale
    grayscale = rgb2gray(frame);

    % Convert to binary
    if threshold > 0
        binary = imbinarize(grayscale, threshold);
    else
        binary = imbinarize(grayscale);
    end

    % Open and close
    binary = bwareaopen(binary, 5);
    binary = imclose(binary, strel('line', 100, 0));

    % Determine boundaries
    B = bwboundaries(binary, 'holes');

    % See if there are any boundaries
    if length(B) >= 1
        
        % Assume first boundary 
        boundary = B{1};

        % Find boundaries
        y = boundary(:, 1);
        x = boundary(:, 2);
        maxX = max(boundary(:, 2));
        minX = min(boundary(:, 2));
        maxY = max(boundary(:, 1));
        minY = min(boundary(:, 1));
        height = maxY - minY;
        width = maxX - minX;

        % Find midpoint indices
        midpointIndicesX = find((x == minX + round(width/2)));
        midpointIndicesY = find((y == minY + round(height/2)));

        % Find midpoint coordinates
        coordinatesY = sort(y(midpointIndicesX), 'ascend');
        coordinatesX = sort(x(midpointIndicesY), 'ascend');

        % Skip if one of the trials fails
        if length(coordinatesY) < 4 || length(coordinatesX) < 2
            fprintf("Skipping loop %i/~%i\n", i, frames);
        else
        
            % Construct bottom rectangle
            bottomMinY = coordinatesY(3);
            bottomMaxY = coordinatesY(4);
            bottomMinX = minX;
            bottomMaxX = maxX;
            bottomWidth = bottomMaxX - bottomMinX;
            bottomHeight = bottomMaxY - bottomMinY;
            
            bottomMinX = bottomMinX + (bottomWidth * cropPercentWidth);
            bottomWidth = bottomWidth - (2 * bottomWidth * cropPercentWidth);
            bottomMinY = bottomMinY + (bottomHeight * cropPercentHeight);
            bottomHeight = bottomHeight - (2 * bottomHeight * cropPercentHeight);
            
            bottomRect = [bottomMinX, bottomMinY, bottomWidth, bottomHeight];
            
            % Crop
            croppedBottom = imcrop(grayscale, bottomRect);
            %croppedBottom = croppedBottom(:, :, 3);
            %croppedBottom = rgb2gray(croppedBottom);
            
            % Sum intensities
            bottomIntensitiesTemp = [];
            [rows, columns, ~] = size(croppedBottom);
            for column = 1:columns
                bottomIntensitiesTemp(end+1) = sum(croppedBottom(:, column));
            end
            
            % Remove gain
            even_avg = mean(bottomIntensitiesTemp(1, 2:2:end));
            odd_avg = mean(bottomIntensitiesTemp(1, 1:2:end));
            bottomIntensitiesTemp(1, 2:2:end) = bottomIntensitiesTemp(1, 2:2:end)/even_avg;
            bottomIntensitiesTemp(1, 1:2:end) = bottomIntensitiesTemp(1, 1:2:end)/odd_avg;

            % Polynomial fit
            [p, ~, mu] = polyfit(1:columns, bottomIntensitiesTemp, 5);
            for x = 1:columns
                f = polyval(p, x, [], mu);
                bottomIntensitiesTemp(x) = bottomIntensitiesTemp(x)/f;
            end
            
            % Concat
            bottomIntensities = horzcat(bottomIntensities, bottomIntensitiesTemp); 
      
    %         % Construct middle rectangle
    %         if length(coordinatesX) == 2
    %             middleMinY = minY;
    %             middleMaxY = maxY;
    %             middleMinX = coordinatesX(1);
    %             middleMaxX = coordinatesX(2);
    %             middleWidth = middleMaxX - middleMinX;
    %             middleHeight = middleMaxY - middleMinY;
    %             middleMinY = middleMinY + (middleHeight * cropPercent);
    %             middleHeight = middleHeight - (2 * middleHeight * cropPercent);
    %             middleRect = [middleMinX, middleMinY, middleWidth, middleHeight];
    %             croppedMiddle = imcrop(frame, middleRect);
    %         end
        
            % Construct top rectangle
            topMinY = coordinatesY(1);
            topMaxY = coordinatesY(2);
            topMinX = minX;
            topMaxX = maxX;
            topWidth = topMaxX - topMinX;
            topHeight = topMaxY - topMinY;
            
            topMinX = topMinX + (topWidth * cropPercentWidth);
            topWidth = topWidth - (2 * topWidth * cropPercentWidth);
            topMinY = topMinY + (topHeight * cropPercentHeight);
            topHeight = topHeight - (2 * topHeight * cropPercentHeight);
            
            topRect = [topMinX, topMinY, topWidth, topHeight];
          
            % Crop images to rectangles
            croppedTop = imcrop(grayscale, topRect);
            %croppedTop = croppedTop(:, :, 3);
            %croppedTop = rgb2gray(croppedTop);
            
            % Sum intensities for top and bottom
            topIntensitiesTemp = [];
            [~, columns, ~] = size(croppedTop);
            for column = 1:columns
                topIntensitiesTemp(end+1) = sum(croppedTop(:, column));
            end
            
            % Remove gain
            even_avg = mean(topIntensitiesTemp(1, 2:2:end));
            odd_avg = mean(topIntensitiesTemp(1, 1:2:end));
            topIntensitiesTemp(1, 2:2:end) = topIntensitiesTemp(1, 2:2:end)/even_avg;
            topIntensitiesTemp(1, 1:2:end) = topIntensitiesTemp(1, 1:2:end)/odd_avg;

            % Polynomial fit
            [p, ~, mu] = polyfit(1:columns, topIntensitiesTemp, 5);
            for x = 1:columns
                f = polyval(p, x, [], mu);
                topIntensitiesTemp(x) = topIntensitiesTemp(x)/f;
            end
            
            % Concat
            topIntensities = horzcat(topIntensities, topIntensitiesTemp); 
            
            % Display
            %imshowpair(croppedTop, croppedBottom, 'montage');
            subplot(1,2,1);
            imshow(croppedTop);
            subplot(1,2,2);
            imshow(croppedBottom);
            pause(0.1);
        
            % Plot
            %{
            figure;
            imshow(frame);
            hold on;
            rectangle('Position', bottomRect, 'EdgeColor','r','LineWidth',2);
            rectangle('Position', topRect, 'EdgeColor','r','LineWidth',2);
            rectangle('Position', middleRect, 'EdgeColor','r','LineWidth',2);
            plot(x, y, 'r', 'LineWidth', 2);
            hold off;
            %}

            % Finish loop
            fprintf("Finshed loop %i/~%i\n", i, frames);
        end
    end
end

% Determine size
[~, topSamples] = size(topIntensities);
[~, bottomSamples] = size(bottomIntensities);

% Difference
dif = bottomIntensities - topIntensities;

% Average
avg = (bottomIntensities + topIntensities)/2;

% FFT over top
L = length(topIntensities);
NFFT = 2^nextpow2(L);
[pxx, f] = periodogram(topIntensities, blackman(L), NFFT, Fs);
figure;
pxx = sgolayfilt(pxx, 3, 21);
plot(f/1000, 10*log10(pxx));
title('RSS (dB) vs frequency (kHz) (periodogram)');
xlabel('Frequency (kHz)');
ylabel('RSS (dB)');

% FFT over bottom
L = length(bottomIntensities);
NFFT = 2^nextpow2(L);
[pxx, f] = periodogram(bottomIntensities, blackman(L), NFFT, Fs);
figure;
pxx = sgolayfilt(pxx, 3, 51);
plot(f/1000, 10*log10(pxx));
title('RSS (dB) vs frequency (kHz) (periodogram)');
xlabel('Frequency (kHz)');
ylabel('RSS (dB)');

% FFT over average
L = length(avg);
NFFT = 2^nextpow2(L);
[pxx, f] = periodogram(avg, blackman(L), NFFT, Fs);
figure;
pxx = sgolayfilt(pxx, 3, 21);
plot(f/1000, 10*log10(pxx));
title('RSS (dB) vs frequency (kHz) (periodogram)');
xlabel('Frequency (kHz)');
ylabel('RSS (dB)');