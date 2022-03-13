classdef PointTracker < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        points
        conjugates
        zeroCount
        poleCount
        conjugateMode
        deletingMode
    end

    methods
        function obj = PointTracker()
            obj.points = Points();
            obj.conjugates = Points();
            obj.zeroCount = 1;
            obj.poleCount = 1;
            obj.conjugateMode = true;
            obj.deletingMode = false;
        end

        function incrementCount(obj, type)
            if type == "zero"
                obj.zeroCount = obj.zeroCount + 1;
            elseif type == "pole"
                obj.poleCount = obj.poleCount + 1;
            end
        end

        function id = getCount(obj, type)
            if type == "zero"
                id = obj.zeroCount;
            elseif type == "pole"
                id = obj.poleCount;
            end
        end

        function poles = getPoles(obj)
            poles = [obj.points.poles, obj.conjugates.poles];
            poles(isnan(poles)) = [];
        end

        function zeroes = getZeroes(obj)
            zeroes = [obj.points.zeroes, obj.conjugates.zeroes];
            zeroes(isnan(zeroes)) = [];
        end

        function addPoint(obj, roi)
            if roi.UserData.isConjugate
                if roi.UserData.type == "zero"
                    obj.conjugates.addZero(roi);
                elseif roi.UserData.type == "pole"
                    obj.conjugates.addPole(roi);
                end
            else
                if roi.UserData.type == "zero"
                    obj.points.addZero(roi);
                elseif roi.UserData.type == "pole"
                    obj.points.addPole(roi);
                end
            end
        end

        function deletePointIfClicked(obj, src, evt)
            if obj.deletingMode
                obj.deletePoint(src, evt);
            end
        end

        function deletePoint(obj, src, evt, conjugate, type, id)
            if conjugate
                if type == "zero"
                    obj.conjugates.deleteZero(id);
                elseif type == "pole"
                    obj.conjugates.deletePole(id);
                end
            else
                if type == "zero"
                    obj.points.deleteZero(id);
                elseif type == "pole"
                    obj.points.deletePole(id);
                end
            end
        end

        function movePoint(obj, src, evt, conjugate, flipSign)
            if conjugate
                if src.UserData.type == "zero"
                    idx = src.UserData.id;
                    obj.conjugates.updateZero(idx, toComplex(src.Position .* flipSign));
                elseif src.UserData.type == "pole"
                    idx = src.UserData.id;
                    obj.conjugates.updatePole(idx, toComplex(src.Position .* flipSign));
                end
            else
                if src.UserData.type == "zero"
                    idx = src.UserData.id;
                    obj.points.updateZero(idx, toComplex(src.Position .* flipSign));
                elseif src.UserData.type == "pole"
                    idx = src.UserData.id;
                    obj.points.updatePole(idx, toComplex(src.Position .* flipSign));
                end
            end
        end

    end
end