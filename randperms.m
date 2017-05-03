function x = randperms(n,k)
%function dublicates randperm(n,k) in 2012+ matlab
%returns a row vector containing k unique integers selected randomly from 1
%to n inclusive
x=randperm(n);
x=x(1:k);
end