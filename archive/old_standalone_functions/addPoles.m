function addPoles();
global zeroes poles zeroColor poleColor userStopped poleZeroAxes bounds;
    userStopped = false;
    while ~userStopped
        pole = drawpoint(poleZeroAxes, "Color", "r", "DrawingArea", "unlimited");
        if ~isvalid(pole) || isempty(pole.Position) || outOfBounds(pole.Position)
            % End the loop
            userStopped = true;
        else
        poles(end + 1) = toComplex(pole.Position);

        % add event listeners to the new ROI point
        addlistener(pole,'MovingROI',@updateROI);
        addlistener(pole,'ROIMoved',@updateROI);
        addlistener(pole,'DeletingROI', @updateROI);
        addlistener(pole,'ROIClicked', @updateROI);
        plotTimeDomainResponseGui();
        end
    end
end