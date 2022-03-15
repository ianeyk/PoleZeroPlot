classdef SnapModeStaticData < handle
    % STATICDATA Class for creating static variables.
    % See https://stackoverflow.com/a/30526042
    properties
        mode(1, 1) logical     % boolean flag for whether points should snap to the real axis.
        tolerance(1, 1) double % distance from the real axis at which snapping should occur
                                % snapMode is controlled directly by the poleZeroTool app.
    end
end