% RANDGAUSS(a,d,n)
%   This function creates a Gaussian random variable with mean 'a'
%   and variance 'd'.  If a second argument is used, a vector of
%   'n' Gaussian random variables is created.
%
% See also RAND, RANDN, RANDUNIFC, RANDEXPO, RANDPOIS, RANDGEO

function out = randgauss(a,d,n)

f = sqrt(d);

if nargin == 2
    out = f * randn + a;
end

if nargin == 3
    randvec = randn(1,n);
    out = f .* randvec + a;
end

