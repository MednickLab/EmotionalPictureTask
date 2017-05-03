function [dPrime] = dprime(pHit,pFA)

%-- Convert to Z scores, no error checking
zHit = norminv(double(pHit));
zFA  = norminv(double(pFA));

%-- Calculate d-prime
dPrime = zHit - zFA ;