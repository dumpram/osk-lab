function [ U, f ] = spektar( u, fs, N, name  )
%SPEKTAR Summary of this function goes here
%   Detailed explanation goes here

U = FFT(u, blackman(length(u))', N, fs);
figure('name', name);
plot(fos(N, fs), 20 * log10(abs(U)));

end

