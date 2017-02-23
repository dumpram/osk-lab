%% Parametri i generiranje modulacijskog signala

close all;
clear all;

tmax = 16e-3; % 16ms
fs = 1e6; % 1 MHz
t = 0:1/fs:tmax;
N = length(t);
fm = 250; % 250 Hz
U0sq = 4 / pi; % amplituda prvog harmonika pravokutnog nosioca
U0cs = 1;

um = mod_signal( tmax, fs );
figure('name', 'Modulacijski signal');
plot(t, um);

[UM, f] = FFT(um, blackman(N)', N, fs);
figure('name', 'Spektar modulacijskog signala');
plot(f, 20 * log10(abs(UM)));
axis([-4000 4000 -50 -4]);

%% Generiranje frekvencijski moduliranog signala

f0 = 300e3; % 300 kHz

Kw = 2 * pi * 5e3; % 5 kHz/V

uFM = cos(2 * pi * f0 * t + Kw * cumsum(um)/fs);

figure('name', 'FM modulirani signal');
plot(t, uFM);

[UFM, f] = FFT(uFM, blackman(N)', N, fs);
figure('name', 'Spektar FM moduliranog signala');
plot(f, 20 * log10(abs(UFM)));

%% Dizajn filtara za spektralno ograničavanje FM signala

rp = 1; % 1dB valovitost
n = 4; % red filtra
%fm = 5000;

B_2 = 2 * Kw / (2 * pi) + 2 * fm * 2;
[z, p, k] = cheby1(n, rp, 2 * pi * [f0 - B_2/2, f0 + B_2/2], 's');
h_2 = impulse(zpk(z, p, k), t);

B_4 = 2 * Kw / (2 * pi) + 2 * fm * 4;
[z, p, k] = cheby1(n, rp, 2 * pi * [f0 - B_4/2, f0 + B_4/2], 's');
h_4 = impulse(zpk(z, p, k), t);

B_10 = 2 * Kw / (2 * pi) + 2 * fm * 10;
[z, p, k] = cheby1(n, rp, 2 * pi * [f0 - B_10/2, f0 + B_10/2], 's');
h_10 = impulse(zpk(z, p, k), t);


%% Prikaz spektralno ograničenih FM signala

%close all;

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
%% Simulacija rada kvadraturnog demodulatora (zadatak 2.)

%close all;

ypp_2 = kvad_multiplier(uFM_filt_2, t, f0);
ypp_4 = kvad_multiplier(uFM_filt_4, t, f0);
ypp_10 = kvad_multiplier(uFM_filt_10, t, f0);

figure('name', 'Spektri nakon množenja');
hold;
Ypp_2 = FFT(ypp_2, blackman(N)', N, fs);
Ypp_4 = FFT(ypp_4, blackman(N)', N, fs);
Ypp_10 = FFT(ypp_10, blackman(N)', N, fs);

plot(f, 20*log10(abs(Ypp_2)), 'r');
plot(f, 20*log10(abs(Ypp_4)), 'g');
plot(f, 20*log10(abs(Ypp_10)),'b');
legend('2fm', '4fm', '10fm');


% [Y, f] = FFT(y, blackman(N)', N, fs);
% figure('name', 'Spektar nakon mnozenja');
% plot(f, 20 * log10(abs(Y)));


%% Projektiranje NP Butterworthovog filtra i filtriranje

%close all;

n = 3;

% Konstanta za kompenziranje
c = -8 * f0 / (Kw * U0cs^2);
ypp_2 = ypp_2 * c;
ypp_4 = ypp_4 * c;
ypp_10 = ypp_10 * c;

% Limiter 
ypp_2 = limiter(ypp_2, 1);
ypp_4 = limiter(ypp_4, 1);
ypp_10 = limiter(ypp_10, 1);

figure('name', 'Spektri nakon limitera');
hold;
Ypp_2 = FFT(ypp_2, blackman(N)', N, fs);
Ypp_4 = FFT(ypp_4, blackman(N)', N, fs);
Ypp_10 = FFT(ypp_10, blackman(N)', N, fs);

plot(f, 20*log10(abs(Ypp_2)), 'r');
plot(f, 20*log10(abs(Ypp_4)), 'g');
plot(f, 20*log10(abs(Ypp_10)),'b');
legend('2fm', '4fm', '10fm');

[z, p, k] = butter(n, 2 * pi * 2 * fm, 's');
hnp_2 = impulse(zpk(z, p, k), t);
ynp_2 = conv(ypp_2, hnp_2) / fs;
ynp_2 = ynp_2(1:N)';

[z, p, k] = butter(n, 2 * pi * 4 * fm, 's');
hnp_4 = impulse(zpk(z, p, k), t);
ynp_4 = conv(ypp_4, hnp_4) / fs;
ynp_4 = ynp_4(1:N)';

[z, p, k] = butter(n, 2 * pi * 10 * fm, 's');
hnp_10 = impulse(zpk(z, p, k), t);
ynp_10 = conv(ypp_10, hnp_10) / fs;
ynp_10 = ynp_10(1:N)';

ynp_2 = ynp_2 - mean(ynp_2);
ynp_4 = ynp_4 - mean(ynp_4);
ynp_10 = ynp_10 - mean(ynp_10);

figure('name', 'Spektri nakon filtriranja');
Ynp_2 = FFT(ynp_2, blackman(N)', N, fs);
Ynp_4  = FFT(ynp_4, blackman(N)', N, fs);
Ynp_10 = FFT(ynp_10, blackman(N)', N, fs);
hold;
plot(f, 20 * log10(abs(Ynp_2)), 'r');
plot(f, 20 * log10(abs(Ynp_4)), 'g');
plot(f, 20 * log10(abs(Ynp_10)),'b');
legend('2fm', '4fm', '10fm');

% Konstanta za kompenziranje square nosioca
c = 8 * f0 / (Kw * U0sq^2);

figure('name', 'Signali nakon filtriranja');
hold;
plot(t, diff(ynp_2) * c, 'r');
plot(t, ynp_4 * c, 'g');
plot(t, ynp_10 * c,'b');
plot(t, um, 'y');
legend('2fm', '4fm', '10fm');

%% Uklanjanje parazitne amplitudne modulacije limiterom
% 
% ynp_2 = limiter(ynp_2, 1);
% ynp_4 = limiter(ynp_4, 1);
% ynp_10 = limiter(ynp_10, 1);
% figure('name', 'Signali nakon limitera');
% hold;
% plot(t, ynp_2, 'r');
% plot(t, ynp_4, 'g');
% plot(t, ynp_10, 'b');
% legend('2fm', '4fm', '10fm');