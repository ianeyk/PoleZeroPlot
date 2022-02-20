function addZeroes();
global zeroes poles zeroColor poleColor userStopped poleZeroAxes;
    userStopped = false;
    while ~userStopped
        zero = drawpoint(poleZeroAxes, "Color", "b", "DrawingArea", "unlimited");
        if ~isvalid(zero) || isempty(zero.Position) || outOfBounds(zero.Position)
            % End the loop
            userStopped = true;
        else
        zeroes(end + 1) = toComplex(zero.Position);

        % add event listeners to the new ROI point
        addlistener(zero,'MovingROI', @updateROI);
        addlistener(zero,'ROIMoved', @updateROI);
        addlistener(zero,'DeletingROI', @updateROI);
        addlistener(zero,'ROIClicked', @updateROI);
        plotTimeDomainResponseGui();
        end
    end
end