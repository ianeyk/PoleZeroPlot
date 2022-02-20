classdef PoleZeroApp
    % Class for storing data related to running the PoleZeroTool app
    %   Used as a container instead of passing a bunch of global variables

    properties
        poles
        zeroes
        timeAxes
        poleZeroAxes
        timeSpan
        bounds
        zeroColor
        poleColor
        userStopped
        deletingMode
    end

    methods
        function obj = PoleZeroApp(poleZeroAxes, timeAxes)
            obj.bounds = [-2, 2; -3, 3];
            obj.timeSpan = [0, 5];
            obj.poles = [];
            obj.zeroes = [];
            obj.zeroColor = [0, 0, 1];
            obj.poleColor = [1, 0, 0];
            obj.timeAxes = timeAxes;
            obj.poleZeroAxes = poleZeroAxes;
            obj.userStopped = false;
            obj.deletingMode = false;
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end