function setupAxes()
    global bounds poleZeroAxes timeAxes;
    xlim(poleZeroAxes, bounds(1, :));
    ylim(poleZeroAxes, bounds(2, :));
    xline(poleZeroAxes, 0, 'k-');
    yline(poleZeroAxes, 0, 'k-');
end