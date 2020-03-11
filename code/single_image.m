% Reset
close all

% Signal frequency (hz)
fSignal = 110000;   

% Sampling frequency (hz)
Fs = 50000; 

% Signal length (number of samples, image width * number of rows * trials)
L = 500 * 50;

% Create Image
T = 1/Fs;
t = (0:L-1)*T;
I = 0.5 * (1 + square(2*pi*fSignal*t));

% Process Image
converted = mat2gray(I);
[rows, columns, dimensions] = size(converted);
intensityVector = zeros(1, columns);
for column = 1:columns
    intensityVector(column) = sum(converted(:, column));
end

% Decompress image
[r, samples] = size(intensityVector);
figure
plot(1:samples, intensityVector, 'g');

% Periodogram
NFFT = 2^nextpow2(L);
[pxx, f] = periodogram(intensityVector, blackman(L), NFFT, Fs);
figure
plot(f/1000, pxx);

% Find dominant frequency
[M, I] = max(pxx(5:end));
fAliased = f(I);

% Determine encoded frequency
for n = 0:3
   fprintf("%i\n", round((n * Fs) - fAliased))
   fprintf("%i\n", round((n * Fs) + fAliased))
end