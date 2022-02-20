function plotTimeDomainResponseGui()
    global zeroes poles timeAxes timeSpan;
    syms s t
    numerator = prod(s - zeroes);
    denominator = prod(s - poles);
    % two_zeros_three_poles=((s-z1).*(s-z2))./((s-p1).*(s-p2).*(s-p3));
    laplaceEquation = numerator ./ denominator;

    ts = linspace(timeSpan(1), timeSpan(2), 100);
    timeResponse_sym = ilaplace(laplaceEquation);
    timeResponse_numeric = subs(timeResponse_sym, t, ts);
    plot(timeAxes, ts, real(timeResponse_numeric), 'b-');
    hold(timeAxes, "on");
    plot(timeAxes, ts, imag(timeResponse_numeric), 'r-');
    legend(timeAxes, "Real", "Imaginary");
    hold(timeAxes, "off");


end