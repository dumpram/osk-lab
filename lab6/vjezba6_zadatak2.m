%% Parametri dizajna

Ts = 1e-3;
fd = 1/Ts;
N = 100;
fs = N * fd;
d = 5; % 5 ms
r = 0;
th = (0:1/fs:2 * d * Ts);

%% Projektiranje raised cosine filtra

[B, A] = rcosine(fd, fs, 'fir/sqrt', r, d);

h = impz(B, A);
figure('name', 'Impulsni odziv raised cosine filtra');
plot(th, h);

%% Generiranje niza impulsa
S = 20;
t = (0 : 1/fs : Ts * S);
M = 10;
um = randi([0, M - 1], 1, S);
um = 2 / (M - 1) .* um - 1;
um = upsample(um, N);
um = [um 0];
%% 
figure('name', 'Niz impulsa');
plot (t, um);

%% Generiranje MASK signala
uMASK = conv(um, h);
uMASK = uMASK(1 : length(t));

figure('name', 'MASK signal');
plot(t, uMASK);

%% Dodavanje šuma
SNR = 15; %15 dB
uAWGN = awgn(uMASK, SNR);

figure('name', 'AWGN signal');
plot(t, uAWGN);

%% Prijemni filtar jednak odašiljačkom
% detekcija simbola

uRECV = conv(uAWGN, h, 'same');
figure('name', 'RECV signal');
plot(t, uRECV);

%% Uzorkovanje primljenog signala

uDOWN = downsample(uRECV, N);
uDOWN = uDOWN(1:end-1);
uIMP = upsample(uDOWN, N);
uIMP = [uIMP 0];
figure('name', 'Niz impulsa na prijamnoj strani');
plot(t, uIMP);




