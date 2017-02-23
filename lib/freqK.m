function [  ] = freqK( H, f )
%FREQK Summary of this function goes here
%   Detailed explanation goes here

subplot(2, 1, 1);
plot(f, 20 * log10(abs(H)));
grid on;
subplot(2, 1, 2);
plot(f, angle(H));
grid on;

end

