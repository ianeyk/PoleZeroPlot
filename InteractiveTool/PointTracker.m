classdef PointTracker < handle
    % POINTTRACKER Class that implements storing and tracking of poles and zeroes.
    %   Three pieces of information need to be kept track of for each point.
    %   1) Whether it is a pole or a zero.
    %   2) Whether it is a conjugate or not.
    %   3) The ROI associated with the pole or zero's location.
    %   POINTTRACKER stores four Points objects, which are basically lists of points coupled with ROI objects --
    %   one list each for primary (non-conjugate) poles, primary zeroes, conjugate poles, and conjugate zeroes.
    %   POINTTRACKER ensures that everything that is done to primary points is also done to conjugates,
    %   flipping the sign where needed. POINTTRACKER methods take in string inputs for the type parameter
    % ("zero" or "pole") and boolean inputs for the conjugate parameter, and operate on the appropriate Points object.

    properties
        primary  (1, 1) struct % Struct with two Points objects for keeping track of non-conjugate poles and zeroes
        conjugate(1, 1) struct % Struct with two Points objects for keeping track of non-conjugate poles and zeroes
        zeroCount(1, 1) int8   % id of next zero to be added
        poleCount(1, 1) int8   % id of next pole to be added
    end

    methods
        function obj = PointTracker()
            % POINTTRACKER Init function. Establishes Points objects for holding conjugate and non-conjugate poles and zerores.
            obj.primary.zeroes = Points(); % makes obj.primary a struct with property zeroes
            obj.primary.poles  = Points(); % adds the property poles to obj.primary
            obj.conjugate.zeroes = Points(); % makes obj.conjugate a struct with property zeroes
            obj.conjugate.poles  = Points(); % adds the property poles to obj.conjugate
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
            poles = [obj.primary.poles.points, obj.conjugate.poles.points];
            poles(isnan(poles)) = [];
            poles = unique(poles);
        end

        function zeroes = getZeroes(obj)
            % GETZEROES Returns a 1 x n vector of all zeroes for conjugates and non-conjugates,
            % after removing NaN and duplicate values. This prevents double zeroes on the real axis due to
            % conjugate pairs, especially during snapping.
            zeroes = [obj.primary.zeroes.points, obj.conjugate.zeroes.points];
            zeroes(isnan(zeroes)) = [];
            zeroes = unique(zeroes);
        end

        function addPoint(obj, roi)
            % ADDPOINT Accepts an ROI object that was created using the gui input (or programatically) from drawpoint
            % in PoleZeroApp.m. Adds this new point to the appropriate conjugate or non-conjugate pole or zero Points lists,
            % using data stored in the ROI object itself (added by PoleZeroApp.m)
            if roi.UserData.isConjugate
                if roi.UserData.type == "zero"
                    obj.conjugate.zeroes.add(roi);
                elseif roi.UserData.type == "pole"
                    obj.conjugate.poles.add(roi);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            else
                if roi.UserData.type == "zero"
                    obj.primary.zeroes.add(roi);
                elseif roi.UserData.type == "pole"
                    obj.primary.poles.add(roi);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            end
        end

        function deletePoint(obj, src, evt, conjugate, type, id)
            % DELETEPOINT Called by the ROI deletion handler. Calls the delete method on the appropriate
            % conjugate or non-conjugate pole or zero Points object, based on conjugate and type.
            % type must be passed in, because it is not available for the other point in the conjugate pair
            % after the first point is deleted.
            % conjugate is a boolean for whether to operate on conjugate (true) or primary (false).
            % type is either "zero" or "pole".
            if conjugate
                if type == "zero"
                    obj.conjugate.zeroes.delete(id);
                elseif type == "pole"
                    obj.conjugate.poles.delete(id);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            else
                if type == "zero"
                    obj.primary.zeroes.delete(id);
                elseif type == "pole"
                    obj.primary.poles.delete(id);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            end
        end

        function movePoint(obj, src, evt, conjugate, flipSign, snap)
            % MOVEPOINT Called by the ROI movement handler. Calls the update method on the appropriate
            % conjugate or non-conjugate pole or zero Points object, based on conjugate and type.
            % conjugate is a boolean for whether to operate on conjugate (true) or primary (false).
            % type is determined from the UserData of the ROI.
            % flipsign is either [1, 1] or [1, -1] and determines whether a conjugate needs to have its sign flipped.
            % snap is passed through to the Points object and determines the snapping behavior on movement.
            if conjugate
                if src.UserData.type == "zero"
                    idx = src.UserData.id;
                    obj.conjugate.zeroes.update(idx, toComplex(src.Position .* flipSign), snap);
                elseif src.UserData.type == "pole"
                    idx = src.UserData.id;
                    obj.conjugate.poles.update(idx, toComplex(src.Position .* flipSign), snap);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            else
                if src.UserData.type == "zero"
                    idx = src.UserData.id;
                    obj.primary.zeroes.update(idx, toComplex(src.Position .* flipSign), snap);
                elseif src.UserData.type == "pole"
                    idx = src.UserData.id;
                    obj.primary.poles.update(idx, toComplex(src.Position .* flipSign), snap);
                else
                    error("type must be either 'zero' or 'pole', not '%s'", type)
                end
            end
        end

    end
end