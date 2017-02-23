%% Odredjivanje gornje i donje granične frekvencije modulacijskog signala

close all;

% Parametri modulacijskog signala
tmax = 25e-3; %25 ms
fs = 1.2 * 10^6; % 1.2 MHz 
t=0:1/fs:tmax;  

% Modulacijski signal
um=mod_signal(tmax, fs);

figure('name', 'Modulacijski signal'), plot(t, um);

N = length(um);
Nfft = 2 * N;
UM = FFT(um', blackman(N), Nfft, fs);

figure('name', '|U_m(f)|'), plot(fos(Nfft, fs), 20 * log10(abs(UM)));

fd = 250; fg = 4000;
figure('name', '|U_m(f)|[fd,fg]'), plot(fos(Nfft, fs), 20 * log10(abs(UM)));
axis([fd fg, -100, 0]);

%% Generiranje DSB-SC-AM signala korištenjem prstenastog modulatora
U0 = 1;
f0 = 100000; %100kHz
deltafi = pi/100;
u_nos = sign(U0 * cos(2 * pi * f0 * t));
u_nos = square(2 * pi * f0 * t + deltafi);
u_dbm = u_nos .* um;
U_dbm = FFT(u_dbm', blackman(N), N, fs);
figure('name', '|U_dbm(f)|'), plot(fos(N, fs), 20 * log10(abs(U_dbm)));

%% Dizajn analognog Chebyshevljevog PP filtra
%close all;

red = 4;
Rp = 1; %1dBpp u passbandu
wd = 2 * pi * 540;
wg = 2 * pi * 3540;
w0 = 2 * pi * f0;
ws = 2 * pi * fs;
Wp = [(w0-wd), (w0+wg)];

[z, p, k] = cheby1(red, Rp, Wp, 'bandpass', 's');
H = freqs(k * poly(z), poly(p), fos(N, fs) * 2 * pi); % [-ws/2, ws/2]
freqK(H, fos(N, fs));


%% Filtriranje moduliranog signala dizajniranim filtrom
%close all;

h = impulse(zpk(z, p, k), t);
u_dbm_filt = 1/fs * conv(u_dbm, h, 'same');
U_dbm_filt = FFT(u_dbm_filt', blackman(N), N, fs);
figure('name', '|U_dbm_filt(f)|');
plot(fos(N, fs), 20 * log10(abs(U_dbm_filt)));
figure('name', 'u_dbm_filt(t)'), plot(t, u_dbm_filt);


