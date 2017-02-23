function [ um ] = mod_signal( tmax, fs )
%MOD_SIGNAL Funkcija generira pravokutni signal frekvencije 250 Hz. 
%   Rubovi signala oblikovani su Gaussovim impulsom. 

% Modulacijski signal 
t=0:1/fs:tmax;                % vremenska os 
fm=250;                       % osnovna frekvencija 
up=square(2*pi*fm*t);         % pravokutni signal 
hG=exp(-((t-4e-4)/2e-4).^2);  % Gaussova funkcija 
um=conv(up,hG);               % Gaussovo oblikovanje brida 
um=um(1:length(up));          % skracivanje na simulacijsko vrijeme 
um=um/max(abs(um));           % normiranje na jedinicnu amplitudu 


end

