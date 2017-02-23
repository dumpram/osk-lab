function [ bits ] = qam16decode( c )
%QAM16DECODE Summary of this function goes here
%   Detailed explanation goes here

    if real(c) > 2/3
        if imag(c) > 2/3
            bits = bin2dec('1000');
        elseif imag(c) <= 2/3 && imag(c) > 0
            bits = bin2dec('1001');
        elseif imag(c) <= 0 && imag(c) >= -2/3
            bits = bin2dec('1011');
        elseif imag(c) < -2/3   
            bits = bin2dec('1010');
        end
        
        
    elseif real(c) <= 2/3 && real(c) > 0
        if imag(c) > 2/3
            bits = bin2dec('1100');
        elseif imag(c) <= 2/3 && imag(c) > 0
            bits = bin2dec('1101');
        elseif imag(c) <= 0 && imag(c) >= -2/3
            bits = bin2dec('1111');
        elseif imag(c) < -2/3
            bits = bin2dec('1110');
        end
        
        
    elseif real(c) < 0 && real(c) >= -2/3
        if imag(c) > 2/3
            bits = bin2dec('0100');
        elseif imag(c) <= 2/3 && imag(c) > 0
            bits = bin2dec('0101');
        elseif imag(c) <= 0 && imag(c) >= -2/3
            bits = bin2dec('0111');
        elseif imag(c) < -2/3
            bits = bin2dec('0110');
        end
        
    elseif real(c) < -2/3
        if imag(c) > 2/3
            bits = bin2dec('0000');
        elseif imag(c) <= 2/3 && imag(c) > 0
            bits = bin2dec('0001');
        elseif imag(c) <= 0 && imag(c) >= -2/3
            bits = bin2dec('0011');
        elseif imag(c) < -2/3
            bits = bin2dec('0010');
        end
        
    end

end

