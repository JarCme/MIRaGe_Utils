function [g, G] = Dummy_RTF_est(x_ref,x_tar,N,input_struct)
%[g, G] = Dummy_RTF_est(x_ref,x_tar,N,input_struct)
%   inputs: x_ref,x_tar ... signals from microphones
%           N ... length of the estimated impulse response          
%           input_struct.dummy_arg1 ... first dummy parameter
%           input_struct.dummy_arg2 ... second dummy parameter
%   outputs:
%           g ... estimated impulse response
%           G ... estimated RTF

g = rand(N,1);
G = fft(g);
end

