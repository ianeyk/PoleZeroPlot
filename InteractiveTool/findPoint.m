function idx = findPoint(position, points)
    equalityThresh = 1e-4;
    for idx = 1:length(points)
        if (position(1) - real(points(idx)) < equalityThresh) & (position(2) - imag(points(idx)) < equalityThresh)
            return
        end
    end
end