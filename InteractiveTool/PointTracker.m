classdef PointTracker < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        points
        conjugates
        conjugateMode
    end

    methods
        function obj = PointTracker()
            obj.points = Points();
            obj.conjugates = Points();
            obj.conjugateMode = true;
        end

        function poles = getPoles(obj)
            poles = [obj.points.poles, obj.conjugates.poles];
            poles(isnan(poles)) = [];
        end

        function zeroes = getZeroes(obj)
            zeroes = [obj.points.zeroes, obj.conjugates.zeroes];
            zeroes(isnan(zeroes)) = [];
        end

        function addPoint(obj, type, roi)
            if type == "zero"
                obj.points.addZero(roi);
            elseif type == "pole"
                obj.points.addPole(roi);
            end

            if obj.conjugateMode
                roi.Position = roi.Position .* [1, -1];
            else
                roi.Position = [NaN, NaN];
            end

            if type == "zero"
                obj.conjugates.addZero(roi);
            elseif type == "pole"
                obj.conjugates.addPole(roi);
            end
        end

        function deletePoint(obj, type, position)

            if type == "zero"
                idx = obj.findPoints(position, obj.points.zeroes);
                obj.points.deleteZero(idx);
            elseif type == "pole"
                idx = obj.findPoints(position, obj.points.poles);
                obj.points.deletePole(idx);
            end

            if obj.conjugateMode
                if type == "zero"
                    obj.conjugates.deleteZero(idx); % can use the same index because order is preserved
                elseif type == "pole"
                    obj.conjugates.deletePole(idx); % can use the same index because order is preserved
                end
            end
        end

        function movePoint(obj, type, oldPosition, newPosition)

            if type == "zero"
                idx = obj.findPoints(oldPosition, obj.points.zeroes);
                for id = idx
                    obj.points.updateZero(idx, toComplex(newPosition));
                end
            elseif type == "pole"
                idx = obj.findPoints(oldPosition, obj.points.poles);
                for id = idx
                    obj.points.updatePole(idx, toComplex(newPosition));
                end
            end

            if obj.conjugateMode
                if type == "zero"
                    for id = idx
                        obj.conjugates.updateZero(idx, toComplex(newPosition .* [1, -1])); % can use the same index because order is preserved
                    end
                elseif type == "pole"
                    for id = idx
                        obj.conjugates.updatePole(idx, toComplex(newPosition .* [1, -1])); % can use the same index because order is preserved
                    end
                end
            end
        end

        function idx = findPoints(obj, position, points)
            equalityThresh = 1e-4;
            idx = find((position(1) - real(points) < equalityThresh) & (position(2) - imag(points) < equalityThresh));
        end

    end
end