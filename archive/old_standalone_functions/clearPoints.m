function clearPoints()
    global zeroes poles poleZeroAxes;
    oldPoints = findobj(poleZeroAxes,'Type','images.roi.point');
    delete(oldPoints);
    zeroes = [];
    poles = [];
    plotTimeDomainResponseGui();
end