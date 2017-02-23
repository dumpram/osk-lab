%% Parametri modela
close all;
clear all;

B = 100e3; 
fc = 10e6;

fsH = 24e6;
fsL = 187.5e3;
tmax = 5e-3;
tH = (0:1/fsH:tmax);
tL = (0:1/fsL:tmax);
Nfreq = 5000;



R = fsH / fsL;

%% Generiranje signala
fm = 10.05e6;
A = 1;
Um = A * sin ( 2 * pi * fm * tH );
spektar(Um, fsH, Nfreq, 'Spektar na ulazu u mješalo');

%% Kompleksno mješalo

Umix = Um .* exp ( -1j * 2 * pi * fc * tH );
spektar(Umix, fsH, Nfreq, 'Spektar na izlazu mješala');
%% Cic decimator ( Ncic = 1, M = 1, R = fsH / fsL )
Ncic = 5;

% AF filtar
hcic = 1/R * ones ( 1, R );
hcicn = 1;
for i=1:Ncic
    hcicn = conv(hcicn, hcic);
end
hcic = hcicn;
Ucic = conv ( Umix, hcic );
% Decimator
Ucic = Ucic ( 1 : length(Umix) );
Ucic = Ucic ( 1 : R : end );
freqZ (hcic, Nfreq, fsH, 2 * pi, 'CIC decimator na visokoj frekvenciji');
Hcicl = freqZ (hcic, Nfreq, fsL, 2 * pi / R, 'CIC decimator na niskoj frekvenciji');



%% CIC kompenzator 

close all;

ApassdB = 0.01;
AstopdB = 40;
Nkomp = 20;
wg = 7e4 / (fsL/2);
Apass=1-10^(-(ApassdB/2)/20);
Astop=10^(-AstopdB/20);
a = 1 / 2;

% Impulsni odziv CIC kompenzatora 
hCICK=firceqrip(... 
         Nkomp,...  % red FIR filtra 
         wg,...                % granica propustanja ili gusenja 
         [Apass, Astop],...    % maksimalna apsolutna odstupanja 
         'invsinc', [a, Ncic],... % aproksimira se [aw/sin(aw)]^N 
         'passedge'...         % wg odreduje podrucje propustanja 
                );
freqZ(hCICK, Nfreq, fsL, 2 * pi , 'CIC kompenzator');
          

%% Projektiranje selektora kanala
% s aspketa modulacijskog signala sinus je USB
Nsk = 165;
Bk = 0.8 * B;
k = 0.1; % 10 posto
wsk = [-(fsL/2), -Bk * k, 0, Bk, Bk * (1 + k), fsL/2] / (fsL/2);
hsk = cfirpm(Nsk, wsk, [0 0 2 2 0 0]); 
freqZ(hsk, Nfreq, fsL, 2 * pi, 'Selektor kanala');


%% Kaskada CIC kompenzatora i selektora kanala

hkask = conv(hsk, hCICK);
Hkask = freqZ(hkask, Nfreq, fsL, 2 * pi, 'Kaskada kompenzatora i selektora');

%% Filtarski lanac
close all;

Hfiltk = Hkask .* Hcicl;
figure('name', 'Karakteristika filtarskog lanca');
plot(fos(Nfreq, fsL), 20 * log10(abs(Hfiltk)));



%% Odziv lanca

close all;

Uiz = conv(Ucic, hkask);
Uiz = Uiz(1:length(Ucic));
figure('name', 'Odziv lanca');
plot(tL, real(Uiz));
spektar(Uiz, fsL, Nfreq, 'Spektar izlaznog signala');

%% 
