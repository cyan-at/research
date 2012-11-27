function n = learn_rate(t,t0,n0)
if nargin == 1
    t0 = .1;
    n0 = 1;
end
n = n0+(1/(1+t/t0));
end