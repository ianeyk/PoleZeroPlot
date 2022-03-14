classdef PointTracker < handle
    % POINTTRACKER Class that implements storing and tracking of poles and zeroes.
    %   Three pieces of information need to be kept track of for each point.
    %   1) Whether it is a pole or a zero.
    %   2) Whether it is a conjugate or not.
    %   3) The ROI associated with the pole or zero's location.
    %   POINTTRACKER stores a two Points objects, which are basically lists of poles and zeroes --
    %   one list for non-conjugates (called points), and one for conjugates (called conjugates).
    %   POINTTRACKER ensures that everything that is done to points is also done to conjugates,
    %   flipping the sign where needed. POINTTRACKER methods also take in string inputs for the
    %   type parameter ("zero" or "pole") and breaks them out into separate methods on Points.

    properties
        points % Points object for keeping track of the list of non-conjugate poles and zeroes
        conjugates % Points object for keeping track of the list of conjugate poles and zeroes
        zeroCount % id of next zero to be added
        poleCount % id of next pole to be added
    end

    methods
        function obj = PointTracker()
            % POINTTRACKER init function. Establishes Points objects for holding conjugate and non-conjugate points.
            obj.points = Points();
            obj.conjugates = Points();
            obj.zeroCount = 1;
            obj.poleCount = 1;
        end

        function incrementCount(obj, type)
            % INCREMENTCOUNT Increments the id of the next zero or pole. The id is used by the Points object to identify
            % specific poles and zeroes. The id of the conjugates and non-conjugates is the same.
            % type is either "zero" or "pole"
            if type == "zero"
                obj.zeroCount = obj.zeroCount + 1;
            elseif type == "pole"
                obj.poleCount = obj.poleCount + 1;
            else
                error("type must be either 'zero' or 'pole', not '%s'", type)
            end
        end

        function id = getCount(obj, type)
            % GETCOUNT Returns the id of the next zero or pole. type is either "zero" or "pole"
            if type == "zero"
                id = obj.zeroCount;
            elseif type == "pole"
                id = obj.poleCount;
            else
                error("type must be either 'zero' or 'pole', not '%s'", type)
            end
        end

        function poles = getPoles(obj)
            % GETPOLES Returns a 1 x n vector of all poles for conjugates and non-conjugates,
            % after removing NaN and duplicate values. This prevents double poles on the real axis due to
            % conjugate pairs, especially during snapping.
            poles = [obj.points.poles, obj.conjugates.poles];
            poles(isnan(poles)) = [];
            poles = unique(poles);
        end

        function zeroes = getZeroes(obj)
            % GETZEROES Returns a 1 x n vector of all zeroes for conjugates and non-conjugates,
            % after removing NaN and duplicate values. This prevents double zeroes on the real axis due to
            % conjugate pairs, especially during snapping.
            zeroes = [obj.points.zeroes, obj.conjugates.zeroes];
            zeroes(isnan(zeroes)) = [];
            zeroes = unique(zeroes);
        end

        function addPoint(obj, roi)
            % ADDPOINT Accepts an ROI object that was created using the gui input (or programatically) from drawpoint
            % in PoleZeroApp.m. Adds this new point to the conjugates or non-conjugates Points list, using data stored in
            % the ROI object itself (added by PoleZeroApp.m)
            if roi.UserData.isConjugate
                if roi.UserData.type == "zero"
                    obj.conjugates.addZero(roi);
                elseif roi.UserData.type == "pole"
                    obj.conjugates.addPole(roi);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            else
                if roi.UserData.type == "zero"
                    obj.points.addZero(roi);
                elseif roi.UserData.type == "pole"
                    obj.points.addPole(roi);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            end
        end

        function deletePoint(obj, src, evt, conjugate, type, id)
            % DELETEPOINT Called by the ROI deletion handler. Calls the appropriate method on the
            % points or conjugates object, based on conjugate and type. type must be passed in, because it is not
            % available for the other point in the conjugate pair after the first point is deleted.
            % conjugate is a boolean for whether to operate on conjugates (true) or points (false).
            % type is either "zero" or "pole".
            if conjugate
                if type == "zero"
                    obj.conjugates.deleteZero(id);
                elseif type == "pole"
                    obj.conjugates.deletePole(id);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            else
                if type == "zero"
                    obj.points.deleteZero(id);
                elseif type == "pole"
                    obj.points.deletePole(id);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            end
        end

        function movePoint(obj, src, evt, conjugate, flipSign, snap)
            % MOVEPOINT Called by the ROI movement handler. Calls the appropriate method on the
            % points or conjugates object, based on conjugate and type.
            % conjugate is a boolean for whether to operate on conjugates (true) or points (false).
            % type is determined from the UserData of the ROI.
            % flipsign is either [1, 1] or [1, -1] and determines whether a conjugate needs to have its sign flipped.
            % snap is passed through to the Points object and determines the snapping behavior on movement.
            if conjugate
                if src.UserData.type == "zero"
                    idx = src.UserData.id;
                    obj.conjugates.updateZero(idx, toComplex(src.Position .* flipSign), snap);
                elseif src.UserData.type == "pole"
                    idx = src.UserData.id;
                    obj.conjugates.updatePole(idx, toComplex(src.Position .* flipSign), snap);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            else
                if src.UserData.type == "zero"
                    idx = src.UserData.id;
                    obj.points.updateZero(idx, toComplex(src.Position .* flipSign), snap);
                elseif src.UserData.type == "pole"
                    idx = src.UserData.id;
                    obj.points.updatePole(idx, toComplex(src.Position .* flipSign), snap);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            end
        end

    end
end