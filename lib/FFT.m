function [ X, f ] = FFT( x, p, Nfft, fs )
%FFT Summary of this function goes here
%   Detailed explanation goes here
X = 1/sum(p) * fftshift(fft(x.*p, Nfft));
f = fos(Nfft, fs);
end

