% Reset
close all

% Scale factor
scale = 20;

% Images
count = 60;
imagePath = "/Users/charlescarver/Google Drive/VLC - NYIT REU 2017/Images/Pictures of Florescent Light/1/";
imageNames = {};
for i = 1:count
    file = imagePath + i + "i.png";
    imageNames{i} = file;
end

% Concatenated intensity vector
intensity_vector = [];

% Loop through multiple images
for i = 1:count
    
    % Grayscale it
    I = imread(char(imageNames{i}));
    %converted = mat2gray(I);
    converted = rgb2gray(I);
    
    % Resize
    converted = imresize(converted, 1/scale);

    % Threshold
    %level = graythresh(converted);
    level = 0.5;
    converted = imbinarize(converted, level);
    %imshow(converted);

    % Open and close
    converted = bwareaopen(converted, 100);
    se = strel('disk', 100);
    converted = imclose(converted, se);
    %imshow(converted);
    
    % Find largest boundary 
    r = regionprops(converted, 'BoundingBox', 'Area');
    [maxArea, indexOfMax] = max([r.Area]);
    if indexOfMax
        rect = [r(indexOfMax).BoundingBox(1), r(indexOfMax).BoundingBox(2), r(indexOfMax).BoundingBox(3), r(indexOfMax).BoundingBox(4)];

        % Mask
        w = (rect(3) + rect(1)) * scale;
        x = (rect(1)) * scale;
        h = (rect(4) + rect(2)) * scale;
        y = (rect(2)) * scale;
        x = [w x x w];
        y = [y y h h];
        [rows, columns] = size(I);
        mask = poly2mask(x, y, rows, columns);
        maskedImage = I;
        maskedImage(~mask) = 0;
        imshow(maskedImage);

        % Sum intensities
        [a, b] = size(maskedImage);
        columns = min(a, b);
        rows = max(a, b);
        column_vector = zeros(1, rows);
        for row = 1:rows
            column_vector(row) = sum(maskedImage(1:end, row));
        end

        % Remove zero values
        column_vector(column_vector == 0) = [];

        % Add to intensities vector
        intensity_vector = horzcat(intensity_vector, column_vector);

        % Output conclusion
        fprintf("Finshed loop " + i + "\n");
    else
        fprintf("Skipping loop " + i + "\n");
    end
end

% Determine size
[~, rows] = size(intensity_vector);

% Plot
figure
plot(1:rows, intensity_vector, 'r');

% Remove gain
even_avg = mean(intensity_vector(1, 2:2:end));
odd_avg = mean(intensity_vector(1, 1:2:end));
intensity_vector(1, 2:2:end) = intensity_vector(1, 2:2:end)/even_avg;
intensity_vector(1, 1:2:end) = intensity_vector(1, 1:2:end)/odd_avg;

% Polynomial fit
[p, ~, mu] = polyfit(1:rows, intensity_vector, 6);
for x = 1:rows
    f = polyval(p, x, [], mu);
    intensity_vector(x) = intensity_vector(x)/f;
end

% Plot
figure
plot(1:rows, intensity_vector, 'g');

% FFT
Fs = 64800;%73,440;           % Sampling frequency (sps)                
T = 1/Fs;             % Sampling period     
L = rows;             % Length of signal (number of samples)
NFFT = 2^nextpow2(L);
% %f = Fs/2 * linspace(0, 1, NFFT/2 + 1);
% Y = fft(blackman(L).*intensity_vector')/L;
% Y = 2 * abs(Y(1:NFFT/2+1));
% Y = log(Y);
% % Remove discontinuities at zero
% % f(1:1) = [];
% % Y(1:1) = [];

[pxx, f] = periodogram(intensity_vector, blackman(L), NFFT, Fs);

% Plot FFT
figure
plot(f/1000, 10*log10(pxx));