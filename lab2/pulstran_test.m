close all;

T = 0 : 1/50E3 : 10E-3;
D = [0 : 1/1E3 : 10E-3]';
Y = pulstran(T,D,@gauspuls,10E3,.5); plot(T,Y)

%%

close all;
% Example 1: Generate an asymmetric sawtooth waveform with a
       % repetition frequency of 3 Hz and a sawtooth width of 0.1 sec.
       % The signal is to be 1 second long with a sample rate of 1kHz.
 
T = 0 : 1/1E3 : 1;  % 1 kHz sample freq for 1 sec
D = 0 : 1/3 : 1;    % 3 Hz repetition freq
Y = pulstran(T,D,'tripuls',0.1,-1); plot(T,Y)