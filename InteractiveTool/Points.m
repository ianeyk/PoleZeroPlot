classdef Points < handle
    % Points Class for storing lists of points and zeroes.
    %   Also stores ROI objects for points and zeroes and can manipulate them (for example,
    %   to change the location of an ROI when its conjugate pair is changed).

    properties
        zeroes        % 1 x n array of complex numbers representing zeroes
        poles         % 1 x m array of complex numbers representing poles
        zeroRois      % 1 x n array of ROI objects representing zeroes
        poleRois      % 1 x m array of ROI objects representing poles
        snapMode      % boolean flag for whether points should snap to the real axis
        snapTolerance % distance from the real axis at which snapping should occur
    end

    methods
        function obj = Points()
            obj.poles = [];
            obj.zeroes = [];
            obj.poleRois = {};
            obj.zeroRois = {};
            obj.snapMode = true;
            obj.snapTolerance = 0.15;
        end

        function addZero(obj, roi)
            roi.Position = obj.snapToRealAxis(roi.Position);
            obj.zeroes(end + 1) = toComplex(roi.Position);
            obj.zeroRois{end + 1} = roi;
        end

        function addPole(obj, roi)
            roi.Position = obj.snapToRealAxis(roi.Position);
            obj.poles(end + 1) = toComplex(roi.Position);
            obj.poleRois{end + 1} = roi;
        end

        function deleteZero(obj, idx)
            obj.zeroes(idx) = NaN;
            try
                delete(obj.zeroRois{idx});
            catch
                % pass
            end
            obj.zeroRois{idx} = NaN;
        end

        function deletePole(obj, idx)
            obj.poles(idx) = NaN;
            try
                delete(obj.poleRois{idx});
            catch
                % pass
            end
            obj.poleRois{idx} = NaN;
        end

        function updateZero(obj, idx, newValue, snap)
            if snap
                newValue = obj.snapToRealAxis(newValue);
            end
            if ~isnan(obj.zeroes(idx))
                obj.zeroes(idx) = newValue;
                obj.zeroRois{idx}.Position = [real(newValue), imag(newValue)];
            end
        end

        function updatePole(obj, idx, newValue, snap)
            if snap
                newValue = obj.snapToRealAxis(newValue);
            end
            if ~isnan(obj.poles(idx))
                obj.poles(idx) = newValue;
                obj.poleRois{idx}.Position = [real(newValue), imag(newValue)];
            end
        end

        function out = snapToRealAxis(obj, in)
            % handle Position form [re, im]
            if length(in) == 2
                if obj.snapMode & abs(in(2)) < obj.snapTolerance
                    out = [in(1), 0];
                else
                    out = in;
                end

            % handle complex form re + im(i)
            elseif length(in) == 1
                if obj.snapMode & abs(imag(in)) < obj.snapTolerance
                    out = real(in);
                else
                    out = in;
                end
            end
        end

    end
end