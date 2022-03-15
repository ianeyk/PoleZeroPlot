classdef Points < handle
    % POINTS Class for storing lists of points or zeroes coupled with ROI objects.
    %   Points are stored as complex numbers. POINTS ensures that anything done to a point
    %   is done to both the complex value and the ROI. POINTS also manipulates
    %   ROI objects to change their location when a conjugate point is changed.

    properties
        points        (1, :) double  % 1 x n array of complex numbers representing poles or zeroes
        rois          (1, :) cell    % 1 x n cell array of ROI objects representing poles or zeroes
        snapTolerance (1, 1) double  % distance from the real axis at which snapping should occur
        snapMode      (1 ,1) logical % boolean flag for whether points should snap to the real axis.
                                        % snapMode is controlled directly by the poleZeroTool app.
    end

    methods
        function obj = Points()
            % Init function establishing arrays and cell arrays.
            obj.points = [];
            obj.rois = {};
            obj.snapMode = true;
            obj.snapTolerance = 0.20;
        end

        function add(obj, roi)
            % ADD Takes an ROI object that has just been created. Stores the ROI in rois,
            % and stores the complex position in points. Also handles snapping, if in effect.
            roi.Position = obj.snapToRealAxis(roi.Position);
            obj.points(end + 1) = toComplex(roi.Position);
            obj.rois{end + 1} = roi;
        end

        function delete(obj, idx)
            % DELETE Called after an ROI has been deleted.
            % Sets the value of the complex position and the ROI to NaN to preserve ordering.
            obj.points(idx) = NaN;
            try
                delete(obj.rois{idx});
            catch
                % pass
            end
            obj.rois{idx} = NaN;
        end

        function update(obj, idx, newValue, snap)
            % UPDATE Called when an ROI is being moved. Updates the complex position and
            % changes the Position property of the ROI to manipulate the conjugate pair.
            % snap acts as an override for snapMode, so that snapping only occurrs after an ROI object has been released.

            % The complex position gets snapped no matter what, to preserve continuity in the timeDomainResponse plot
            nonRoiValue = obj.snapToRealAxis(newValue);

            % The ROI position is only snapped at the end of movement (when snap == true),
            % to allow the ROI to leave the real axis
            if snap
                roiValue = obj.snapToRealAxis(newValue);
            else
                roiValue = newValue;
            end

            % Update the complex position and the ROI
            if ~isnan(obj.points(idx))
                obj.points(idx) = nonRoiValue;
                obj.rois{idx}.Position = [real(roiValue), imag(roiValue)];
            end
        end

        function out = snapToRealAxis(obj, in)
            % SNAPTOREALAXIS Checks if snapMode is enabled. If the final position is within snapTolerance of the real
            % axis, it deletes the imaginary component.

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