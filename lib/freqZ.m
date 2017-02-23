function [ H ] = freqZ( h, N, fa, ws, title )
%FREQS Summary of this function goes here
%   Detailed explanation goes here
w = fos ( N, ws );
fcrt = fos ( N, fa );
H = freqz ( h, 1, w );
figure ('name', title );
plot ( fcrt, 20 * log10(abs(H)) );

end

