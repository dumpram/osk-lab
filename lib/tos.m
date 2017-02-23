function [ t ] = tos(N, fs)
%TOS Samples signal with given frequency symmetric time axis points in N 
% points. 

%
if (mod(N,2)) 
    t = (-(N-1)/(2 * fs):1/fs:N/(2 * fs));
else
    t = (-(N-1)/(2 * fs):1/fs:(N-1)/(2 * fs));
end

end

