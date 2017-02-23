%% Parametri i generiranje modulacijskog signala

close all;
clear all;

tmax = 16e-3; % 16ms
fs = 1e6; % 1 MHz
t = 0:1/fs:tmax;
N = length(t);
fm = 250; % 250 Hz

um = mod_signal( tmax, fs );
figure('name', 'Modulacijski signal');
plot(t, um);

[UM, f] = FFT(um, blackman(N)', N, fs);
figure('name', 'Spektar modulacijskog signala');
plot(f, 20 * log10(abs(UM)));
axis([-4000 4000 -50 -4]);

%% Generiranje frekvencijski moduliranog signala

f0 = 250e3; % 250 kHz

Kw = 2 * pi * 5e3; % 5 kHz/V

uFM = cos(2 * pi * f0 * t + Kw * cumsum(um));

figure('name', 'FM modulirani signal');
plot(t, uFM);

[UFM, f] = FFT(uFM, blackman(N)', N, fs);
figure('name', 'Spektar FM moduliranog signala');
plot(f, 20 * log10(abs(UFM)));

%% Dizajn filtara za spektralno ograničavanje FM signala

rp = 1; % 1dB valovitost
n = 4; % red filtra

[z, p, k] = cheby1(n, rp, 2 * pi * [f0 - 2*fm, f0 + 2*fm], 's');
h_2 = impulse(zpk(z, p, k), t);

[z, p, k] = cheby1(n, rp, 2 * pi * [f0 - 4*fm, f0 + 4*fm], 's');
h_4 = impulse(zpk(z, p, k), t);

[z, p, k] = cheby1(n, rp, 2 * pi * [f0 - 10*fm, f0 + 10*fm], 's');
h_10 = impulse(zpk(z, p, k), t);


%% Prikaz spektralno ograničenih FM signala

close all;

f = fos(N, fs);

uFM_filt_2 = conv(uFM, h_2) / fs;
uFM_filt_2 = uFM_filt_2(1:N);
UFM_filt_2 = FFT(uFM_filt_2, blackman(N), N, fs);

uFM_filt_4 = conv(uFM, h_4) / fs;
uFM_filt_4 = uFM_filt_4(1:N);
UFM_filt_4 = FFT(uFM_filt_4, blackman(N), N, fs);

uFM_filt_10 = conv(uFM, h_10) / fs;
uFM_filt_10 = uFM_filt_10(1:N);
UFM_filt_10 = FFT(uFM_filt_10, blackman(N), N, fs);

figure('name', 'Spektri FM signala');
hold;
plot(f, 20 * log10(abs(UFM)));
plot(f, 20 * log10(abs(UFM_filt_2)), 'r');
plot(f, 20 * log10(abs(UFM_filt_4)), 'g');
plot(f, 20 * log10(abs(UFM_filt_10)), 'y');
legend('Izvorni', '2fm', '4fm', '10fm');

figure('name', 'Prikaz valnih oblika signala');
hold;
plot(t, uFM);
plot(t, uFM_filt_2, 'r');
plot(t, uFM_filt_4, 'g');
plot(t, uFM_filt_10, 'y');
legend('Izvorni', '2fm', '4fm', '10fm');



