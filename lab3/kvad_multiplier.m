function [ y ] = kvad_multiplier( x, t, f0 )
%KVAD_MULTIPLIER Summary of this function goes here
%   Detailed explanation goes here

td = 1 / (4 * f0);
dlyN = length(find(td > t));
xd = [zeros(1, dlyN), x'];
xd = xd(1:length(x));
y = x .* xd';
y = y';

end

