%% Generiranje radio signala
 
clear all;
close all;

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
uRX=sinc(8*pi*BRF*(t-tmax/4)).*sign(sin(2*pi*fRF*t));

%% Prikaz radio signala
close all;

N = length(t);

figure('name', 'Vremenski oblik radio signala');
plot(t, uRX);

figure('name', 'Spektar radio signala');
[URX, f] = FFT(uRX, blackman(N), 2*N, fs);
plot(f, 20 * log10(abs(URX)));

%% Parametri transpozicije frekvencije

fcMF = 5e6; %5 MHz
fMF = 45e6; %44 MHz
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
uRF = gain * conv(uRX, hRF) /fs;
uRF = uRF(1:N);

uIF = uMF .* uRF; 


uIF = gain * conv(uIF, hIF)/fs;
uIF = uIF(1:N);

[UIF, f] = FFT(uIF, blackman(N), 2 * N, fs);  

figure('name', 'Spektar nakon transpozicije');
plot(f, 20 * log10(abs(UIF)));


%% Analogno-digitalni pretvornik

tH = 0:1/fsH:tmax;
NH = length(tH);
fH = fos(N, fsH);
uAD = nth(uIF, ceil(length(t)/length(tH)));
figure('name', 'Ulaz u AD');
plot(t, uIF);

figure('name', 'Izlaz iz AD');
plot(tH, uAD);

figure('name', 'Spektar na izlazu AD');
[UAD, f] = FFT(uAD, blackman(NH), 2 * NH, fsH);
plot(f, 20 * log10(abs(UAD)));

%% Numerički upravljan oscilator

wNCO = 2 * pi * 5e6;
n = 0:1:NH -1;
uMIX = exp(1i * wNCO * tH);
uD = uAD' .* uMIX;

[UD, f] = FFT(uD, blackman(NH)', NH * 2, fsH);
figure('name', 'Spektar signala na izlazu mixera');
plot(f, 20 * log10(abs(UD)));


%% CIC decimator

close all;

Ncic = 6;
fsL = 2e6;
R = fsH/fsL;
M = 1;
fsL = fsH / R;
tL = 0:1/fsL:tmax;
NL = length(tL);
fL = fos(NL, fsL);
w = fos(NH, 2 * pi);

hCIC = 1/R * ones(1, R);
hCICn = hCIC;

for i=1:Ncic
     hCICn = conv(hCICn, hCIC);
end

%HCIC = ((1/R) * (sin (w./2) ./(sin (w./(2*R))))).^Ncic;
HCIC = freqz(hCICn, 1, w);
figure('name', 'Frekvencijska karakteristika CIC decimatora');
plot(fos(NH, fsH), 20 * log10(abs(HCIC)));

%% Filtriranje CIC decimatorom

yCIC = conv(uD, hCICn);
yCIC = yCIC(1:NH);
yCIC = nth(yCIC, R);
[YCIC, f] = FFT(yCIC, blackman(NL)', NL * 2, fsL);

figure('name', 'Spektar nakon CIC-a');
plot(f, 20 * log10(abs(YCIC)));


%% Dizajn CIC kompenzatora

w = fos(NL, 2 * pi);
Apass=0.1;
Astop=40;

Ap=1-10^(-Apass/2/20);
As=10^(-Astop/20);

B=500*10^3;
wg=B/fsL/2;
hCICK=firceqrip(60,wg,[Ap As],'invsinc',[1/2, Ncic],'passedge');
HCICK = freqz(hCICK,1,w);
figure('name','Frekvencijska karakterisitika kompenzatora');
plot(fL, 20*log10(abs(HCICK)));

%% Odziv CIC kompenzatora

close all;

yCICK = conv(yCIC, hCICK);
yCICK = yCICK(1:NL);
figure('name','Spektar nakon kompenzatora')
[YCICK, f] = FFT(yCICK, blackman(NL)', NL * 2, fsL);
plot(f, 20 * log10(abs(YCICK)));


%% Dizajn selektora kanala

Nsk = 100;
Bk = 500e3; %širina kanala
Tr = 0.05 * Bk;
fd = 0;
fg = Bk;
f1 = fd - Tr;
f2 = fg + Tr;
wp = [-1 f1/(fsL/2) fd/(fsL/2) fg/(fsL/2) f2/(fsL/2) 1];
hsk = cfirpm(Nsk - 1, wp, [0 0 2 2 0 0]);
w = fos(NL, 2 * pi);
Hsk = freqz(hsk, 1, w);
figure('name', 'Selektor kanala');
plot(fL, 20 * log10(abs(Hsk)));

%% Filtriranje selektorom kanala

ySK = conv(yCICK, hsk, 'same');

figure('name', 'Signal na izlazu selektora');
plot(tL, real(ySK)); 







%% 






% 
% figure('name', 'Frekvencijska karakteristika CIC decimatora');
% plot(w, 20 * log10(HCIC));
% 
% uCIC = conv(abs(uD), hCIC, 'same');
% uCIC = decimate(uCIC, R);
% 
% 
% 
% 
% 
% figure('name', 'Signal nakon CIC-a');
% plot(tL, uCIC);
% figure('name', 'Spektar nakon CIC-a');
% [UCIC, f] = FFT(uCIC, blackman(NL)', NL * 2, fsL);
% plot(f, 20 * log10(abs(UCIC)));







