classdef Points < handle
    % Points class for poles and zeroes
    %   Detailed explanation goes here

    properties
        poles   % list of complex numbers
        zeroes  % list of complex numbers
        poleRois   % list of ROI objects
        zeroRois   % list of ROI objects
    end

    methods
        function obj = Points()
            obj.poles = [];
            obj.zeroes = [];
            obj.poleRois = {};
            obj.zeroRois = {};
        end

        function polesOrZeroes = getValues(obj, poleOrZeroIdentifier)
            % inputs a variety of options for identifying poles or zeroes and returns the corresonding array
            if ismember(poleOrZeroIdentifier, ["zero", "zeroes", "b"])
                polesOrZeroes = obj.zeroes;
            elseif ismember(poleOrZeroIdentifier, ["pole", "poles", "r"])
                polesOrZeroes = obj.poles;
            end
        end

        function addZero(obj, roi)
            obj.zeroes(end + 1) = toComplex(roi.Position);
            obj.zeroRois{end + 1} = roi;
        end

        function addPole(obj, roi)
            obj.poles(end + 1) = toComplex(roi.Position);
            obj.poleRois{end + 1} = roi;
        end

        function deleteZero(obj, idx)
            obj.zeroes(idx) = NaN;
            delete(obj.zeroRois{idx});
            obj.zeroRois{idx} = NaN;
        end

        function deletePole(obj, idx)
            obj.poles(idx) = NaN;
            delete(obj.poleRois{idx});
            obj.poleRois{idx} = NaN;
        end

        function updateZero(obj, idx, newValue)
            obj.zeroes(idx) = newValue;
            obj.zeroRois{idx}.Position = [real(newValue), imag(newValue)];
        end

        function updatePole(obj, idx, newValue)
            obj.poles(idx) = newValue;
            obj.poleRois{idx}.Position = [real(newValue), imag(newValue)];
        end

    end
end