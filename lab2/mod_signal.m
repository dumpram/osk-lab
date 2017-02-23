function [ um ] = mod_signal( tmax, fs )
%MOD_SIGNAL Funkcija generira modulacijski signal
%   Detailed explanation goes here

t=0:1/fs:tmax;                      % Vremenska os od 0 do tmax s 
                                    % fs kao frekvencijom uzorkovanja. 
K=1e-3:2e-3:tmax;                   % Kasnjenje prvog pulsa = 1e-3 s, 
                                    % trajanje pulsa = 2e-3 s. 
A=rand(size(K));                    % Amplitude impulsa su uniformno 
                                    % razdijeljene od 0 do 1. 
P=[K; A]';                          % Parametri impulsa: 
                                    % 1.st. kasnjenja, 2.st. amplitude. 
um=pulstran(t,P,'gauspuls',2e3,1);  % Prvi puls moze se dobiti kao 
                                    % p1=A(1)*gauspuls(t-K(1),2e3,1); 
um=um-mean(um);                     % Uklanjanje DC komponente.

end

