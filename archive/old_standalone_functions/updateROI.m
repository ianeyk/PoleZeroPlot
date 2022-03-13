function updateROI(src,evt)
    global deletingMode
    evname = evt.EventName;
    switch(evname)
        case{'MovingROI'}
            updatePoints(src, false);
            disp("moving ROI")
        case{'ROIMoved'}
            updatePoints(src, false);
            disp("moved ROI")
        case{'DeletingROI'}
            updatePoints(src, true);
        case{'ROIClicked'}
            disp("reached this point")
            if deletingMode
                updatePoints(src, true);
                delete(src);
            end
    end
end

function updatePoints(src, deletePoint)
    global zeroes poles zeroColor poleColor;
    % clf;
    equalityThresh = 1e-4;
    src.Color
    zeroColor
    if src.Color == zeroColor
        idx = findPoint(src.Position, zeroes);
        if deletePoint
            zeroes(idx) = [];
        else
            zeroes(idx) = toComplex(src.Position);
        end
    elseif src.Color == poleColor
        idx = findPoint(src.Position, poles);
        if deletePoint
            poles(idx) = [];
        else
            poles(idx) = toComplex(src.Position);
        end
    end
    plotTimeDomainResponseGui();
end