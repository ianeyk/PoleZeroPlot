function plotTimeDomainResponse(zeroes, poles)

syms s t
numerator = prod(s - zeroes);
denominator = prod(s - poles);
% two_zeros_three_poles=((s-z1).*(s-z2))./((s-p1).*(s-p2).*(s-p3));
laplaceEquation = numerator ./ denominator;

ts=linspace(0,10,200);
timeResponse_sym = ilaplace(laplaceEquation);
timeResponse_numeric = subs(timeResponse_sym, t, ts);
plot(ts, timeResponse_numeric);

end