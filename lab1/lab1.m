%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%   LAB1 - LERI2 - OBRADA SIGNALA U KOMUNIKACIJAMA                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 2.3.2.

% vrijeme trajanja signala
tmax = 10;
[x,tmax] = izvor01(tmax);
k = 1/(length(x));
w = 1/k * ones(1, length(x) - 1);

%% 2.4.2.
close all;

N = 51;
fs = 100; %100Hz

freq = fos(N, fs);
t = (-(N-1)/(2 * fs):1/fs:(N-1)/(2 * fs));

% signal u vremenskoj domeni
x = exp(1i * 2 * pi * 10 * t);
figure('name', 'Trenutna amplituda i faza');
subplot(2, 1, 1);
stem(t, abs(x));
subplot(2, 1, 2);
stem(t, angle(x));

% vremenski otvor
w = 1/N * ones(1, N);

% signal u frekvencijskoj domeni
xw = x .* w;
X = fftshift(fft(xw, N));

figure('name', 'Realni i imaginarni dio');
subplot(2, 1, 1);
stem(freq, real(X));
subplot(2, 1, 2);
stem(freq, imag(X));

figure('name', 'Amplitudni spektar');
stem(freq, abs(X));

%% 2.4.2. N paran N = 50;

close all;

N = 50;
fs = 100; %100Hz

freq = fos(N, fs);
t = (-(N-1)/(2 * fs):1/fs:N/(2 * fs));

% signal u vremenskoj domeni
x = exp(1i * 2 * pi * 10 * t);
figure('name', 'Trenutna amplituda i faza');
subplot(2, 1, 1);
stem(t, abs(x));
subplot(2, 1, 2);
stem(t, angle(x));

w = 1/N * ones(1, N);
xw = x .* w;
X = fftshift(fft(xw, N));

figure('name', 'Realni i imaginarni dio');
subplot(2, 1, 1);
stem(freq, real(X));
subplot(2, 1, 2);
stem(freq, imag(X));

figure('name', 'Amplitudni spektar');
subplot(2, 1, 1);
stem(freq, abs(X));
subplot(2, 1, 2);
stem(freq, angle(X));

%% 2.4.3. 

% za drugi dio zadatka povećati broj točaka 5 puta

close all;

N = 101;
fs = 10; %10Hz
Np = N * 5;

freq = fos(N, fs);
t = (-(N-1)/(2 * fs):1/fs:(N-1)/(2 * fs));

x = exp(-t.^2) + 1i * exp(-abs(t)) .* (1 - cos(10*t))./t;
x(t==0) = 1;

% signal u vremenskoj domeni
figure('name', 'Trenutna amplituda i faza');
subplot(2, 1, 1);
stem(t, abs(x));
subplot(2, 1, 2);
stem(t, angle(x));

w = 1/N * ones(1, N);
xw = x .* w;
X = fftshift(fft(xw, N));

figure('name', 'Amplitudni spektar');
stem(fos(Np, fs), abs(fftshift(fft(xw, Np))), 'red');
hold;
stem(freq, abs(X), 'blue');

E = 1/fs * sum(abs(x).^2);

%% 2.5.1

clear all;
close all;
n = (0:79);
x = square(0.1 * pi * n);
xa_org = hilbert(x); % mjerimo periodicni signal
xa_10 = hilbert(x, length(x) + 10); % dodavanje nula -> mjerimo puls
xa_1000 = hilbert(x, length(x) + 1000);
figure('name', 'Izvorni realni signal');
plot(n, x);
figure('name', 'Hilbertovi transformati');
hold on;
plot(n, imag(xa_org));
plot((0:89), imag(xa_10), 'red');
plot((0:1079), imag(xa_1000), 'green');
axis([0 100 -3 3]);
legend('xa-org', 'xa-10', 'xa-1000');

%HILBERTOV TRANSFORMATOR DOBRO REAGIRA NA SKOKOVE U SIGNALU


%% 2.6.1
close all;

n = (-200:200);
x = 1./(pi * n) .* (sin(0.6 * pi * n) - sin(0.2 * pi * n));
x(n==0) = 0.4;
figure('name', 'x[n]');
stem(n, x);
figure('name', '|X(k)|');
Nfft = length(n);
p = ones(1, Nfft);
fs = 1;
[X, f] = FFT(x, p, Nfft, 2 * pi);
stem(f, abs(X));



%% Dizajniranje Hilbertovog transformatora Parks-Mclellan algoritmom

close all;

N = 99; %100 koeficijenata
h = firpm(N, [0.1 0.9] , [1 1], 'Hilbert');
p = ones(1, N + 1);
[H, f] = FFT(h, p, N, 1);
figure('name', 'Spektar transformatora');
plot(f, abs(H));
hdly = firpm(N, [0.1 0.9], [1 1]);
xd = conv(x, hdly, 'same');
xh = conv(x, h, 'same'); % hilbertov transformat
figure('name', 'Hilbertov transformat');
plot(tos(length(xh), 1), xh);

z = xd + 1i * xh; % analiticki signal
p = ones(1, length(z));
[Z, f] = FFT(z, p, length(z), 1);
figure('name', 'Analiticki signal');
plot(f, abs(Z));

%% Dizajniranje filtra s kompleksnim koeficijentima
close all;

N = 100; %100 koeficijenata
%h = cfirpm(N, [0.1 0.9], 'hilbfilt'); ekvivalentno onom gore
h = cfirpm(N, [-1 0 0.1 0.9], [0 0 1 1]);
p = ones(1, N + 1);
[H, f] = FFT(h, p, N, 1);
figure('name', 'AF-filtra');
plot(f, abs(H));
[X, f] = FFT(x, ones(1, length(x)), length(x), 1);
figure('name', 'Spektar realnog signala');
plot(f, abs(X));

z = conv(x, h, 'same'); % analitcki signal

%z = x + 1i * xh; % analiticki signal
p = ones(1, length(z));
[Z, f] = FFT(z, p, length(z), 1);
figure('name', 'Spektar analitičkog signala');
plot(f, abs(Z));


