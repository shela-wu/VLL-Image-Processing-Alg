close all;

max = 200;
x_original = linspace(0,4*pi,max);
y_original = abs(sin(x_original));
[p,~,mu] = polyfit(x_original,y_original,6);
f = polyval(p,x_original,[],mu);
hold on
plot(x_original,f)
plot(x_original,y_original)
hold off

% 
% y_new = 1:max;
% for x = 1:max
%     f = x^6 * p(1) + x^5 * p(2) + x^4 * p(3) + x^3 * p(4) + x^2 * p(5) + x * p(6) + p(7);
%     y_new(x) = y_original(x)/f;
%     disp(y_original(x)/f);
% end
% 
% x_fit = linspace(0,4*pi);
% y_fit = polyval(p,x_fit);
% 