classdef Points < handle
    % Points Class for storing lists of points and zeroes.
    %   Also stores ROI objects for points and zeroes and can manipulate them (for example,
    %   to change the location of an ROI when its conjugate pair is changed).

    properties
        zeroes        % 1 x n array of complex numbers representing zeroes
        poles         % 1 x m array of complex numbers representing poles
        zeroRois      % 1 x n cell array of ROI objects representing zeroes
        poleRois      % 1 x m cell array of ROI objects representing poles
        snapMode      % boolean flag for whether points should snap to the real axis. This is controlled
                        % directly by the poleZeroTool app.
        snapTolerance % distance from the real axis at which snapping should occur
    end

    methods
        function obj = Points()
            % Init function establishing arrays and cell arrays.
            obj.poles = [];
            obj.zeroes = [];
            obj.poleRois = {};
            obj.zeroRois = {};
            obj.snapMode = true;
            obj.snapTolerance = 0.15;
        end

        function addZero(obj, roi)
            % ADDZERO Takes an ROI object that has just been created. Stores the ROI in zeroRois,
            % and stores the complex position in zeroes. Also handles snapping, if in effect.
            roi.Position = obj.snapToRealAxis(roi.Position);
            obj.zeroes(end + 1) = toComplex(roi.Position);
            obj.zeroRois{end + 1} = roi;
        end

        function addPole(obj, roi)
            % ADDPOLE Takes an ROI object that has just been created. Stores the ROI in poleRois,
            % and stores the complex position in poles. Also handles snapping, if in effect.
            roi.Position = obj.snapToRealAxis(roi.Position);
            obj.poles(end + 1) = toComplex(roi.Position);
            obj.poleRois{end + 1} = roi;
        end

        function deleteZero(obj, idx)
            % DELETEZERO Called after an ROI has been deleted.
            % Sets the value of the complex position and the ROI to NaN to preserve ordering.
            obj.zeroes(idx) = NaN;
            try
                delete(obj.zeroRois{idx});
            catch
                % pass
            end
            obj.zeroRois{idx} = NaN;
        end

        function deletePole(obj, idx)
            % DELETEPOLE Called after an ROI has been deleted.
            % Sets the value of the complex position and the ROI to NaN to preserve ordering.
            obj.poles(idx) = NaN;
            try
                delete(obj.poleRois{idx});
            catch
                % pass
            end
            obj.poleRois{idx} = NaN;
        end

        function updateZero(obj, idx, newValue, snap)
            % UPDATEZERO Called when an ROI is being moved. Updates the complex position of the zero and
            % changes the Position property of the ROI to manipulate the other point in the conjugate pair.
            % snap acts as an override for snapMode, so that snapping only occurrs after an ROI object has been released.

            % The complex position gets snapped no matter what, to preserve continuity in the timeDomainResponse plot
            nonRoiValue = obj.snapToRealAxis(newValue);
            if snap
                % The ROI position is only snapped at the end of movement (when snap == true),
                % to allow the ROI to leave the real axis
                roiValue = obj.snapToRealAxis(newValue);
            else
                roiValue = newValue;
            end
            if ~isnan(obj.zeroes(idx))
                obj.zeroes(idx) = nonRoiValue;
                obj.zeroRois{idx}.Position = [real(roiValue), imag(roiValue)];
            end
        end

        function updatePole(obj, idx, newValue, snap)
            % UPDATEPOLE Called when an ROI is being moved. Updates the complex position of the pole and
            % changes the Position property of the ROI to manipulate the other point in the conjugate pair.
            % snap acts as an override for snapMode, so that snapping only occurrs after an ROI object has been released.

            % The complex position gets snapped no matter what, to preserve continuity in the timeDomainResponse plot
            nonRoiValue = obj.snapToRealAxis(newValue);
            if snap
                % The ROI position is only snapped at the end of movement (when snap == true),
                % to allow the ROI to leave the real axis
                roiValue = obj.snapToRealAxis(newValue);
            else
                roiValue = newValue;
            end
            if ~isnan(obj.poles(idx))
                obj.poles(idx) = nonRoiValue;
                obj.poleRois{idx}.Position = [real(roiValue), imag(roiValue)];
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