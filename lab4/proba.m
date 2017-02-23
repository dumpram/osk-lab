close all;
N = 2;
w = 1/N * ones(1, N);
W = fftshift(fft(w, N * 10000000));
f = fos(N * 10000000, 2 * pi);
plot(f, 20 * log10(abs(W)));