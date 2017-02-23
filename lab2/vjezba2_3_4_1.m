%% Prikaz moduliranog signala

clear all;
close all;

load vjezba2_zadatak3.mat;

figure('name', 'Modulirani signal'), plot(t, uAM);

%% Spektar moduliranog signala

Nfft = 2 * length(uAM);
Ts = t(2) - t(1);
fs = 1/Ts;
N = length(uAM);
[UAM, f] = FFT(uAM, blackman(N), Nfft, fs); 
figure('name', 'Spektar moduliranog signala');
plot(f, 20 * log10(abs(UAM)));

%% Kompleksna produktna demodulacija

f0 = 10^5; % 100kHz
um = uAM .* exp(1i * 2 * pi * f0 * t); % produktna demodulacija
figure('name', 'Signal nakon mnozenja');
plot(t, abs(um));
figure('name', 'Spektar nakon mnozenja');
[UM, f] = FFT(um, blackman(N), Nfft, fs);
plot(f, 20 * log10(abs(UM)));

%% Projektiranje Butterworth filtra 

n = 2;
fg = 4500; % 4 kHz
[z, p, k] = butter(n, 2 * pi * fg ,'low','s');
H = freqs(k * poly(z), poly(p), fos(N, fs) * 2 * pi);
figure('name', 'Karakteristika filtra');
freqK(H, fos(N, fs));

%% Filtriranje signala na izlazu iz mnozila 

h = impulse(zpk(z, p, k), t);
%yi = 1/fs * conv(imag(um), h, 'same');
%yr = 1/fs * conv(real(um), h, 'same');
yi = 1/fs * conv(imag(um), h);
yi = yi(1:N);
yr = 1/fs * conv(real(um), h);
yr = yr(1:N);
y = yr + 1i * yi;
figure('name', 'Filtrirani realni i imaginarni');
plot(t, yr);
hold;
plot(t, yi, 'r');
legend('real', 'imag');
figure('name', 'Signal na izlazu iz filtra');
plot(t, 2 * abs(y));
figure('name', 'Spektar na izlazu iz filtra');
[Y, f] = FFT(y, blackman(N), N, fs);
plot(f, 20 * log10(abs(Y)));


