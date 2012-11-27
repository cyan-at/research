function [W1, W2, hbias, vbias] = unroll_pars(theta,num_ch,num_hid)

if length(theta) == 2*num_ch*num_hid + num_ch + num_hid,
    W1 = reshape(theta(1:num_ch*num_hid),num_ch,num_hid);
    W2 = reshape(theta(num_ch*num_hid+1:2*num_ch*num_hid),num_ch,num_hid);
    hbias = theta(2*num_ch*num_hid+1:(2*num_ch+1)*num_hid);
    vbias = theta((2*num_ch+1)*num_hid+1:end);
elseif length(theta) == num_ch*num_hid + num_ch + num_hid,
    W1 = reshape(theta(1:num_ch*num_hid),num_ch,num_hid);
    W2 = [];
    hbias = theta(num_ch*num_hid+1:(num_ch+1)*num_hid);
    vbias = theta((num_ch+1)*num_hid+1:end);
else
    error('length is not correct!');
end
