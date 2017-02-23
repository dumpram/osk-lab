%% Uzorkovanje modulacijskog signala

close all;

clear all;

% Parametri modulacijskog signala
tmax = 25e-3; %25 ms
fs = 1.2 * 10^6; % 1.2 MHz 
fsL = 12 * 10^3; % frekvencija uzorkovanja modulacijskog signala
t=0:1/fs:tmax; 

% Modulacijski signal
um = mod_signal(tmax, fsL);
figure('name', 'Uzorkovani modulacijski signal'), plot(0:1/fsL:tmax, um);

%% Određivanje graničnih frekvencija modulacijskog signala

N = length(um);

UM = FFT(um', blackman(N), N, fsL);
figure('name', '|UM(om)|'), plot(fos(N, fsL), 20 * log10(abs(UM)));

fd = 400;
fg = 3700; 

%% Projektiranje pozitivno propusnog filtra

close all;

n = 99; % 99. red filtra, 100 koeficijenata
f1 = fd/fsL * 2;
f2 = fg/fsL * 2;
wp = 50/fsL * 2; % prijelazno podrucje 50 Hz
h = cfirpm(n, [-1, 0, f1, f2, f2 + f1, 1], [0, 0, 2, 2, 0, 0]);
figure('name', 'PP filtar'); freqz(h, 1, fos(N, fsL) * 2 * pi / fsL);



%% Generiranje diskretnog analitčkog signala

close all;

z = conv(um, h, 'same');
[Z, f] = FFT(z, blackman(N)', N, fsL);
figure('name', '|Z(om)|'), plot(f, 20*log10(abs(Z)));


%% Interpolacija x20 analitičkog signala
% Interpolacija olakšava posao pozitivno propusnom filtru. Da je signal
% odmah bio otipkan visokom frekvencijom filtar bi morao filtrirati puno
% "manji dio frekvencijskog podrucja" i stoga bi gusenje u podrucju gusenja
% bilo manje. Manji dio frekvencijskog područja znači zapravo uže 
% prijelazno područje i strmiji nagib filtra što zapravo u procesu 
% optimizacije uzrokuje manje gušenje neželjenih komponenti. Netko bi se
% mogao dovinuti i reći pa dobro uzmimo veće područje propuštanja pri 
% većoj frekvenciji otipkavanja. To nije dobro jer želimo propustiti samo
% komponente koje su od interesa.

close all;

zi = interp(z, 20);
zi = zi(1:length(zi)-19);
fsH = 20 * fsL;
tH = (0:1/fsH:tmax);

figure('name', 'Realni i imaginarni dio signala');
plot(tH, real(zi), 'r');
hold;
plot(tH, imag(zi), 'g');
legend('real', 'imag');

%% Generiranje USB signala

close all;

Nh = length(zi);
f0 = 10^5; % 100 kHz
u_usb = real(zi .* exp(1i * 2 * pi * f0 * tH)); % mixer
[U_usb, f] = FFT(u_usb, blackman(Nh)', Nh, fsH);
figure('name', 'Amplitudni spektar U_usb');
plot(f, 20 * log10(abs(U_usb)));
