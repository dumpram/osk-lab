function [ y ] = limiter( x, A )
%LIMITER Summary of this function goes here
%   Detailed explanation goes here

y = zeros(1, length(x));
for i=1:length(x)
   if (abs(x(i)) > A) 
       y(i) = sign(x(i)) * A;
   else
       y(i) = x(i);
   end
end

