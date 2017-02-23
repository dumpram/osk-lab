%% Generiranje radio signala

% parametri modela
fs = 200 * 10^6;
tmax = 50e-6; %50 us 
BK = 500e3; % 500 kHz
fAD = 20e6; % 20 MHz
fsH = fAD;

% vremenska os za analognu domenu
t=(0:1/fs:tmax);
t=t(:);
% komunikacijski kanal
fRF=50e6;   % centralna radio frekvencija
BRF=2e6;    % sirina radio podrucja
% radio signal
uRX=sinc(8*pi*BRF*(t-tmax/4)).*square(2*pi*fRF*t);

%% Prikaz radio signala

N = length(t);

figure('name', 'Vremenski oblik radio signala');
plot(t, uRX);

figure('name', 'Spektar radio signala');
[URX, f] = FFT(uRX, blackman(N), 2*N, fs);
plot(f, 20 * log10(abs(URX)));

%% Parametri transpozicije frekvencije

fcMF = 5e6; %5 MHz
fMF = 45e6; %45 MHz
uMF = cos(2 * pi * fMF * t);

%% Dizajn RF filtra

NRF = 4; % inače je red 2, ali 4 da bi se ostvarilo gušenje 80dB
fg = 51e6;
fd = 49e6;
w = 2 * pi * [fd,  fg];
[z, p, k] = cheby1(NRF, 0.5, w, 's'); 
H = freqs(k * poly(z), poly(p), 2 * pi * f);
figure('name', 'RF filtar');
freqK(H, f);

hRF = impulse(zpk(z,p,k), t);

%% Dizajn IF filtra

NIF = 6;
fg = fsH / 2; 

[z, p, k] = ellip(NIF, 0.5, 80, 2 * pi * fg, 's');
H = freqs(k * poly(z), poly(p), 2 * pi * f);
figure('name', 'IF filtar');
freqK(H, f);

hIF = impulse(zpk(z,p,k), t);

%% Transpozcija signala u nisko-frekvencijsko područje

gain = 10;
uRF = gain * conv(uRX, hRF, 'same') /fs;

uIF = uMF .* uRF; 

uIF = gain * conv(uIF, hIF, 'same')/fs;

[UIF, f] = FFT(uIF, blackman(N), 2 * N, fs);  

figure('name', 'Spektar nakon transpozicije');
plot(f, 20 * log10(abs(UIF)));


%% Analogno-digitalni pretvornik

tH = 0:1/fsH:tmax;
N = length(tH);
fH = fos(N, fsH);
uAD = decimate(uIF, ceil(length(t)/length(tH)));

figure('name', 'Ulaz u AD');
plot(t, uIF);

figure('name', 'Izlaz iz AD');
plot(tH, uAD);

%% 




