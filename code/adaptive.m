% RAW
% I = imread('images/test.dng');
% I = mat2gray(I);

%Compressed
I = imread('images/test3.jpg');
I = rgb2gray(I);

% Resize
I = imresize(I, 1);

% Threshold and remove intense region
% level = graythresh(I);
% BW = imbinarize(I, level);
% BW = imcomplement(BW);
% I(BW == 0) = 0;

% Adaptively threshold
converted = I;
converted = imbinarize(converted, 'adaptive');
imshow(converted);