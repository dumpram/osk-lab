clear all;
close all;

%% Definiranje parametara modela

N = 1024;
Nz = 176;
ref_carrier = 0.2;

load vjezba6_zadatak1.mat;

%% Kompleksna ovojnica signala

figure ('name', 'Amplituda kompleksne ovojnica signala');
plot ( abs( ofdm_rx ) );

%% Autokorelacija OFDM signala

ofdm_corr = conv ( (fliplr(abs(ofdm_rx))), (abs(ofdm_rx)) );
ofdm_corr = abs(ofdm_corr ( 1 : length (ofdm_rx) ));

figure ('name', 'Autokorelacija apsolutne vrijednosti ofdm signala');
plot ( ofdm_corr );


%% Izdvajanje indeksa početka simbola

N_sym = floor(length(ofdm_corr)/(N + Nz));

sym_start_idx = zeros(1, N_sym);
ofdm_sym = zeros(N_sym, N);
clear max idx
k = 1;
for i=1:N+Nz:length(ofdm_corr)-(N + Nz)
    [max, idx] = max(abs(ofdm_corr ( i:(i + (N - Nz) - 1) )));
    sym_start_idx(k)= i + idx;
    ofdm_sym(k,:) = ofdm_rx(sym_start_idx(k) + Nz:sym_start_idx(k) + N + Nz - 1);
    k = k + 1;
    clear max idx
end

%% Demoduliranje i kompenzacija simbola

close all;

demod_ofdm_sym = zeros(N_sym, N);
demod_komp_sym = zeros(N_sym, N);
for i=1:N_sym
    demod_ofdm_sym(i,:) = fftshift(fft(ofdm_sym(i,:))); 
    for j=2:2:N
        demod_komp_sym(i, j - 1) = demod_ofdm_sym(i, j - 1);        
        demod_komp_sym(i, j) = (ref_carrier / demod_ofdm_sym(i,j-1)) * demod_ofdm_sym(i,j);        
    end
end


figure('name', 'Nekompenzirani simbol');
stem(abs(demod_ofdm_sym(4, :)));
figure('name', 'Kompenzirani simbol');
stem(abs(demod_komp_sym(4, :)));


%% Konstelacija prije kompenzacije
close all;


figure('name', 'Konstelacija simbola prije kompenzacije');
hold on;
for i=1:N_sym
    scatter(real(demod_ofdm_sym(i,2:2:end)), imag(demod_ofdm_sym(i,2:2:end)));
end;


%% Konstelacija simbola poslije kompenzacije
close all;


figure('name', 'Konstelacija simbola poslije kompenzacije');
hold on;
for i=1:N_sym
    scatter(real(demod_komp_sym(i,2:2:end)), imag(demod_komp_sym(i,2:2:end)));
end;

%% Povezivanje bitova

sym = demod_komp_sym(:, 2:2:end); % uklonimo pilote
sym = reshape(sym.', 1, N_sym * N / 2);

out = int16(length(sym) / 4);
k = 1;
for i=1:4:length(sym)
   temp = int16(0);
   for j=i:i+3
       temp = bitshift(temp, 4);
       temp = bitor(temp, qam16decode(sym(j)));
   end
   out(k) = temp;
   k = k + 1;
end
out_real = double ( double(out) / 2^15 );

figure ('name', 'Dekodirani signal');
plot (out_real);
axis ( [0  900 -2 2] );

