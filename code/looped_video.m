% Variables
path = "/Users/charlescarver/Google Drive/VLC - NYIT REU 2017/Images/Pictures of Fluorescent Light/Experiments/";
filename = "S8, Front Camera, Tripod (Tallest Set-Up), Varying ISOs, Large Data Set/Light #2/Videos/ISO 2401 (25s).mp4"; 
threshold_scale = 0.2;
threshold = 0.88;
crop_percent_width = 0.25;
crop_percent_height = 0;
start_image_index = 1200;
end_image_index = 1200;
sampling_frequency = 64800;
is_video = true;

% Close all windows
close all;

% Setup video if it is one
if is_video == true
    v = VideoReader(char(path + filename));
end

% Intensitiy vectors 
intensities = {[], []};

% Loop over all the images
for i = start_image_index:end_image_index
    
    % Get the image
    if is_video == true
        v.CurrentTime = 1/v.FrameRate * i;
        image = readFrame(v);
    else
        image = imread(char(path + filename + i + "i.jpg"));
    end
    
    % Rotate, if needed, so that the short side of the image is aligned
    % with the long edge of the light
    [rows, columns, ~] = size(image);
    if columns > rows
        image = imrotate(image, 90);
    end
    
    % Convert to grayscale
    grayscale = rgb2gray(image);
    
    % Shrink
    resized = imresize(grayscale, threshold_scale);
    
    % Threshold
    if threshold > 0
        binary = imbinarize(resized, threshold);
    else
        binary = imbinarize(resized, 'adaptive');
    end
        
    % Open and close
    binary = bwareaopen(binary, 500 * threshold_scale);
    binary = imclose(binary, strel('line', 50 * threshold_scale, 0));
    
    % Find largest boundary
    B = bwboundaries(binary, 'noholes');
    max_area = 0;
    max_index = 1;
    for k = 1:length(B)
        boundary = B{k};
        area = (max(boundary(:, 1)) - min(boundary(:, 1))) * (max(boundary(:, 2)) - min(boundary(:, 2)));
        if area > max_area
            max_area = area;
            max_index = k;
        end
    end
    boundary = B{max_index};
    
    % Find boundaries
    y = boundary(:, 1);
    x = boundary(:, 2);
    max_x = max(boundary(:, 2));
    min_x = min(boundary(:, 2));
    max_y = max(boundary(:, 1));
    min_y = min(boundary(:, 1));
    height = max_y - min_y;
    width = max_x - min_x;
    
    % Find midpoint indices
    midpoint_indices_x = find((x == min_x + round(width/2)));
    midpoint_indices_y = find((y == min_y + round(height/2)));
    
    % Extract light shapes
    shapes = {};
    if length(midpoint_indices_x) == 2
        
        % 2 indices corresponds to one rectangle
        min_x = min_x + (width * crop_percent_width);
        width = width - (2 * width * crop_percent_width);
        min_y = min_y + (height * crop_percent_height);
        height = height - (2 * height * crop_percent_height);
        rect = [min_x * 1/threshold_scale, min_y * 1/threshold_scale, width * 1/threshold_scale, height * 1/threshold_scale];
        cropped = imcrop(image, rect); 
        shapes{end + 1} = cropped;
        
    elseif length(midpoint_indices_x) == 4
        
        % 4 indices corresponds to two parallel rectangles
        coordinates_y = sort(y(midpoint_indices_x), 'ascend');
        coordinates_x = sort(x(midpoint_indices_y), 'ascend');
        
        % Construct top rectangle
        top_min_y = coordinates_y(1);
        top_max_y = coordinates_y(2);
        top_min_x = min_x;
        top_max_x = max_x;
        top_width = top_max_x - top_min_x;
        top_height = top_max_y - top_min_y; 
        top_min_x = top_min_x + (top_width * crop_percent_width);
        top_width = top_width - (2 * top_width * crop_percent_width);
        top_min_y = top_min_y + (top_height * crop_percent_height);
        top_height = top_height - (2 * top_height * crop_percent_height);
        top_rect = [top_min_x * 1/threshold_scale, top_min_y * 1/threshold_scale, top_width * 1/threshold_scale, top_height * 1/threshold_scale];
        top_cropped = imcrop(image, top_rect);
        shapes{end + 1} = top_cropped;
        
        % Construct middle rectangle
        %middle_min_y = min_y;
        %middle_max_y = max_y;
        %middle_min_x = coordinates_x(1);
        %middle_max_x = coordinates_x(2);
        %middle_width = middle_max_ - middle_min_x;
        %middle_height = middle_max_y - middle_min_y;
        
        % Construct bottom rectangle
        bottom_min_y = coordinates_y(3);
        bottom_max_y = coordinates_y(4);
        bottom_min_x = min_x;
        bottom_max_x = max_x;
        bottom_width = bottom_max_x - bottom_min_x;
        bottom_height = bottom_max_y - bottom_min_y; 
        bottom_min_x = bottom_min_x + (bottom_width * crop_percent_width);
        bottom_width = bottom_width - (2 * bottom_width * crop_percent_width);
        bottom_min_y = bottom_min_y + (bottom_height * crop_percent_height);
        bottom_height = bottom_height - (2 * bottom_height * crop_percent_height);
        bottom_rect = [bottom_min_x * 1/threshold_scale, bottom_min_y * 1/threshold_scale, bottom_width * 1/threshold_scale, bottom_height * 1/threshold_scale];
        bottom_cropped = imcrop(image, bottom_rect);
        shapes{end + 1} = bottom_cropped;
    else
        
        % Unknown shape
        fprintf("Skipping image %i/%i, light shape not supported\n", i, end_image_index);
    end
    
    % Loop through all the shapes
    for j = 1:length(shapes)
        
        % Get shape
        shape = shapes{j};
%         [rows, columns, dimensions] = size(shape);
%         copy = zeros(rows, columns, dimensions, 'double');
%         
%         % Remove gain from odd rows
%         for row = 1:2:length(shape(:, 1, 1))
%             r = mean(shape(row, :, 1), 'double');
%             g = mean(shape(row, :, 2), 'double');
%             b = mean(shape(row, :, 3), 'double');
%             for column = 1:length(shape(1, :, 1))
%                 copy(row, column, 1) = double(shape(row, column, 1))/r;
%                 copy(row, column, 2) = double(shape(row, column, 2))/g;
%                 copy(row, column, 3) = double(shape(row, column, 3))/b;
%             end
%         end
%         
%         % Remove gain from even rows
%         for row = 2:2:length(shape(:, 1, 1))
%             r = mean(shape(row, :, 1), 'double');
%             g = mean(shape(row, :, 2), 'double');
%             b = mean(shape(row, :, 3), 'double');
%             for column = 1:length(shape(1, :, 1))
%                 copy(row, column, 1) = double(shape(row, column, 1))/r;
%                 copy(row, column, 2) = double(shape(row, column, 2))/g;
%                 copy(row, column, 3) = double(shape(row, column, 3))/b;
%             end
%         end
        
        % Convert back to grayscale
        shape = rgb2gray(shape);

        % Sum intensities
        temp_intensities = [];
        [rows, columns, ~] = size(shape);
        for column = 1:columns
            temp_intensities(end + 1) = sum(shape(:, column));
        end
        
        % Polynomial fit
        [p, ~, mu] = polyfit(1:columns, temp_intensities, 6);
        for x = 1:columns
            f = polyval(p, x, [], mu);
            temp_intensities(x) = temp_intensities(x)/f;
        end
        
        % Display
        imshow(shape);
        pause(3);
        
        % Save intensities
        intensities{j} = horzcat(intensities{j}, temp_intensities);
    end
    
    % Finish image
    fprintf("Finished image %i/%i\n", i, end_image_index);
end

% Calculate the average
if length(intensities) == 2
    avg = (intensities{1} + intensities{2})/2;
end

% Analyze with sptool
sptool

% % FFT over first
% [~, L] = size(intensities{1});
% NFFT = 2^nextpow2(L);
% [pxx, f] = periodogram(intensities{1}, blackman(L), NFFT, sampling_frequency);
% pxx = sgolayfilt(pxx, 5, 21);
% figure;
% plot(f/1000, 10*log10(pxx));
% title('RSS (dB) vs frequency (kHz) (periodogram)');
% xlabel('Frequency (kHz)');
% ylabel('RSS (dB)');
% 
% % FFT over second
% [~, L] = size(intensities{2});
% NFFT = 2^nextpow2(L);
% [pxx, f] = periodogram(intensities{2}, blackman(L), NFFT, sampling_frequency);
% pxx = sgolayfilt(pxx, 5, 21);
% figure;
% plot(f/1000, 10*log10(pxx));
% title('RSS (dB) vs frequency (kHz) (periodogram)');
% xlabel('Frequency (kHz)');
% ylabel('RSS (dB)');

% 
% 
% 
% % % Filtered
% % t = sgolayfilt(pxx, 3, 51);
% % figure
% % plot(f/1000, 10*log10(t))
% % title('Filtered average RSS (dB) vs frequency (kHz)')
% % xlabel('RSS (dB)')
% % ylabel('Frequency (kHz)')