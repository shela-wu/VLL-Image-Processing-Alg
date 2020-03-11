I = imread('images/test.dng');
%I = imread('images/test2.dng');
%I = imresize(I, 1/10);
%I = rgb2gray(I);
BW = imbinarize(I, 0.0030);


BW = bwareaopen(BW, 100, 26);
[B,L] = bwboundaries(BW,'noholes');
imshow(BW);
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end
st = regionprops(BW, 'BoundingBox', 'Area');
[maxArea, indexOfMax] = max([st.Area]);
rectangle('Position', [st(indexOfMax).BoundingBox(1), st(indexOfMax).BoundingBox(2), st(indexOfMax).BoundingBox(3), st(indexOfMax).BoundingBox(4)], 'EdgeColor','r','LineWidth',2);

crop = imcrop(I, [st(indexOfMax).BoundingBox(1), st(indexOfMax).BoundingBox(2), st(indexOfMax).BoundingBox(3), st(indexOfMax).BoundingBox(4)]);
[rows, columns] = size(crop);
column_vector = [1 columns];
for row = 1:rows
    intensity = sum(crop(row, 1:columns));
    column_vector(row) = intensity;
end


x = rows;
y = column_vector
p = polyfit(x,y,6);
x1 = linspace(0,4*pi);
y1 = polyval(p,x1);
figure
plot(x,y,'o')
hold on
plot(x1,y1)
hold off


figure
plot(1:rows, column_vector);