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