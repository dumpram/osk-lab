%% FFT test

Nfft = 101;
N = 101;
fs = 100;
p = ones(1, Nfft);
f = 10;
t = tos(N, fs);
x = sin(2 * pi * f * t);
[X, f] = FFT(x, p, Nfft, fs); 
stem(f, abs(X));
