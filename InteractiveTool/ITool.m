function Itool()
    load("warningId.mat");
    warning('off',warningId);

    figure(1);
    clf
    global bounds
    bounds = [-2, 2; -3, 3];
    xlim(bounds(1, :))
    ylim(bounds(2, :))

    xline(0)
    yline(0)

    %% create arbitrary number of points
    global zeroes poles zeroColor poleColor;
    poles = [];
    zeroes = [];
    zeroColor = [0, 0, 1];
    poleColor = [1, 0, 0];

    userStopped = false;
    while ~userStopped
        zero = drawpoint("Color", "b");
        if ~isvalid(zero) || isempty(zero.Position)
            % End the loop
            userStopped = true;
        else
        zeroes(end + 1) = toComplex(zero.Position);
        
        % add event listeners to the new ROI point
        addlistener(zero,'MovingROI',@updateROI);
        addlistener(zero,'ROIMoved',@updateROI);
%         notify(zero, images.roi.ROIClickedEventData)
        end
    end

    userStopped = false;
    while ~userStopped
        pole = drawpoint("Color", "r");
        if ~isvalid(pole) || isempty(pole.Position)
            % End the loop
            userStopped = true;
        else
        poles(end + 1) = toComplex(pole.Position);

        % add event listeners to the new ROI point
        addlistener(pole,'MovingROI', @updateROI);
        addlistener(pole,'ROIMoved', @updateROI);
        addlistener(pole,'DeletingROI', @updateROI);
        addlistener(pole,'ROIClicked', @updateROI);
        end
    end
    figure(2);
    clf;
    plotTimeDomainResponse(zeroes, poles);
    save("prev_poles_zeroes", "poles", "zeroes");
end