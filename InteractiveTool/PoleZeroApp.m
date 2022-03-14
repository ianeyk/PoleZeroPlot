classdef PoleZeroApp < handle
    % POLEZEROAPP A class containing the functionality for running the PoleZeroTool app.
    %   Changes to the interface of the PoleZeroTool GUI essentially call various methods
    %   on POLEZEROAPP. The main purpose is to allow input of pole and zero locations and to
    %   store these values. Whenever a change is made, the method plotTimeDomainResponse is
    %   called, which solves the inverse Laplace transform for the transfer function given
    %   by the poles and zeroes. Using event handlers allows the time domain response to
    %   update in real time (albeit with significant lag due to computational intensity).

    % Author: Ian Eykamp
    % Date Modified: 3/14/2022

    properties
        timeAxes      % axes object passed by PoleZeroTool app for the time response
        poleZeroAxes  % axes object passed by PoleZeroTool app for the pole-zero plot gui
        timeSpan      % 1 x 2 vector for time response
        bounds        % 2 x 2 vector for pole-zero plot bounds: [minX, maxX; minY, maxY]
        zeroStruct    % static struct for storing properties related to zeroes (color, name, etc.)
        poleStruct    % static struct for storing properties related to poles (color, name, etc.)
        userStopped   % boolean flag used for placing multiple poles and zeroes
        deletingMode  % boolean flag that tells us when the Delete Points button has been clicked
        conjugateMode % boolean flag for whether conjugate points should be treated together
        pointTracker  % PointTracker object; essentially a list of the active poles and zeroes on
                            % the pole-zero plot. Also contains functionality for conjugate pairs
    end

    methods
        function app = PoleZeroApp(poleZeroAxes, timeAxes)
            % POLEZEROAPP init function. Pass in axes handles from the PoleZeroTool app
            app.bounds = [-2, 2; -3, 3];
            app.timeSpan = [0, 5];
            app.zeroStruct.type = "zero";
            app.poleStruct.type = "pole";
            app.zeroStruct.color = [0, 0, 1];
            app.poleStruct.color = [1, 0, 0];
            app.timeAxes = timeAxes;
            app.poleZeroAxes = poleZeroAxes;
            app.userStopped = false;
            app.deletingMode = false;
            app.conjugateMode = true;
            app.pointTracker = PointTracker();
            app.setupAxes(); % initialize axes
        end

        function setupAxes(app)
            % SETUPAXES initializes pole-zero and time response plots by drawing horizontal and
            % vertical axes on the pole-zero plot and setting axes limits on both plots.
            xlim(app.poleZeroAxes, app.bounds(1, :));
            ylim(app.poleZeroAxes, app.bounds(2, :));
            xline(app.poleZeroAxes, 0, 'k-');
            yline(app.poleZeroAxes, 0, 'k-');
            xlim(app.timeAxes, [app.timeSpan(1), app.timeSpan(2)]);
        end

        function addPoints(app, typeStruct);
            % ADDPOINTS allows user to input new poles and zeroes using drawpoint, which is the ROI gui.
            % Runs in a while loop until the user clicks outside the bounds or presses ESC. The pole or zero
            % is determined by typeStruct, which is either app.zeroStruct or app.poleStruct (containing the
            % type "pole" or "zero" and the color the ROI points). For each pole or zero that is created by
            % the drawpoint gui, another ROI is created if conjugateMode is in effect. The new poles and
            % zeroes are added to app.pointTracker, which ensures that points and conjugates are kept track
            % of together.

            app.userStopped = false;
            while ~app.userStopped
                % stay in the loop until the user clicks outside the box or presses ESC. This will set app.userStopped to true
                userData.type = typeStruct.type;
                userData.id = app.pointTracker.getCount(typeStruct.type);
                userData.isConjugate = false;

                % initiate the drawpoint gui, which allows the user to create an ROI clicking on the screen
                roi = drawpoint(app.poleZeroAxes, "Color", typeStruct.color, "DrawingArea", "unlimited", "UserData", userData);

                if ~isvalid(roi) || isempty(roi.Position) || outOfBounds(roi.Position, app.bounds)
                    % The user clicked outside the box. Discard the last point (by not continuing to the else statement)
                    % and exit the loop
                    app.userStopped = true;
                else
                    % Add the ROI to pointTracker and give it update handles
                    app.pointTracker.addPoint(roi);
                    app.addHandlers(roi);

                    % Add a conjugate point if using conjugateMode
                    if app.conjugateMode
                        conjPosition = roi.Position .* [1, -1];
                        userData.isConjugate = true;

                        % Add a conjugate point by passing the "Position", [x y] name-value pair to drawpoint. This skips
                        % the gui but creates an ROI that is dragable and editable by the user.
                        roiConj = drawpoint(app.poleZeroAxes, "Color", typeStruct.color, "DrawingArea", "unlimited", "Position", conjPosition, "UserData", userData);

                        % Add the conjugate ROI to pointTracker and give it update handles
                        app.pointTracker.addPoint(roiConj);
                        app.addHandlers(roiConj);
                    else
                        % If not in conjugateMode, still create a placeholder ROI object and insert it into pointTracker.
                        % This helps keep the indices of pointTracker matched between conjugates and non-conjugates.
                        roiConj.Position = [NaN, NaN]; % create a generic struct that just contains the Position and userDaat properties
                        userData.isConjugate = true;
                        roiConj.UserData = userData;
                        app.pointTracker.addPoint(roiConj);
                    end

                    % increment the index of pointTracker now that both the point and the
                    % conjugate or conjugate placeholder have been added
                    app.pointTracker.incrementCount(typeStruct.type);
                    app.plotTimeDomainResponse();
                end
            end
        end

        function deletePointIfClicked(app, src, evt)
            % DELETEPOINTIFCLICKED helper function for checking deletingMode before deleting
            if app.deletingMode
                app.deletePoint(src, evt);
            end
        end

        function deletePoint(app, src, evt)
            % DELETEPOINT event handler for deleting ROI. Handles deletion of conjugate pairs
            % For pointTracker.deletePoint
            % src and evt are objects passed by the event handler
            % true to move the conjugate variable; false for the non-conjugate
            % type is "pole" or "zero", determined by the UserData of the ROI
            % id is the index of the pole or zero, as stored in pointTracker
            type = src.UserData.type;
            id = src.UserData.id;
            if app.conjugateMode
                % delete both the conjugate and non-conjugate
                app.pointTracker.deletePoint(src, evt, false, type, id);
                app.pointTracker.deletePoint(src, evt, true, type, id);
            else
                if src.UserData.isConjugate
                    % delete only the conjugate
                    app.pointTracker.deletePoint(src, evt, true, type, id);
                else
                    % delete only the non-conjugate
                    app.pointTracker.deletePoint(src, evt, false, type, id);
                end
            end
            app.plotTimeDomainResponse();
        end

        function movePointSnap(app, src, evt)
            % MOVEPOINTSNAP helper function for event handling with snapping
            app.movePoint(src, evt, true);
        end

        function movePointNoSnap(app, src, evt)
            % MOVEPOINTNOSNAP helper function for event handling without snapping
            app.movePoint(src, evt, false);
        end

        function movePoint(app, src, evt, snap)
            % MOVEPOINT event handler for moving ROI. Also handles movement of conjugate pairs
            % when conjugateMode is selected. The value of snap is passed through.
            % For pointTracker.movePoint
            % src and evt are objects passed by the event handler
            % true to move the conjugate variable; false for the non-conjugate
            % [1, 1] means the value should be preserved. [1, -1] means the value should be flipped
            % snap determines the snapping behavior
            if app.conjugateMode
                if src.UserData.isConjugate
                    % move the conjugate; also make the non-conjugate mirrored
                    app.pointTracker.movePoint(src, evt, true, [1, 1], snap);
                    app.pointTracker.movePoint(src, evt, false, [1, -1], snap);
                else
                    % move the non-conjugate; also make the conjugate mirrored
                    app.pointTracker.movePoint(src, evt, false, [1, 1], snap);
                    app.pointTracker.movePoint(src, evt, true, [1, -1], snap);
                end
            else
                if src.UserData.isConjugate
                    % only move the conjugate; do not mirror the non-conjugate
                    app.pointTracker.movePoint(src, evt, true, [1, 1], snap);
                else
                    % only move the non-conjugate; do not mirror the conjugate
                    app.pointTracker.movePoint(src, evt, false, [1, 1], snap);
                end
            end
            app.plotTimeDomainResponse();
        end

        function addHandlers(app, roi)
            % ADDHANDLERS adds handlers for tracking position of ROI object
            addlistener(roi, 'MovingROI',   @app.movePointNoSnap);
            addlistener(roi, 'ROIMoved',    @app.movePointSnap);
            addlistener(roi, 'DeletingROI', @app.deletePoint);
            addlistener(roi, 'ROIClicked',  @app.deletePointIfClicked);
        end

        function clearPoints(app)
            % CLEARPOINTS removes all poles and zeroes from the pole-zero plot; resets poles and
            % zeroes in memory

            % seek existing ROI objects and clear them
            oldPoints = findobj(app.poleZeroAxes,'Type','images.roi.point');
            delete(oldPoints);
            app.pointTracker = PointTracker(); % reset poles and zeroes in memory
            app.plotTimeDomainResponse(); % reset the time domain plot
        end

        function deletePoints(app)
            % DELETEPOINTS called when the Delete Points button is pressed; sets deletingMode = true
            app.deletingMode = true;
        end

        function stopActions(app)
            % STOPACTIONS sets all global modes to the off state
            app.deletingMode = false;
            app.userStopped = false;
        end

        function plotTimeDomainResponse(app)
            % PLOTTIMEDOMAINRESPONSE using existing poles and zeroes, creates a transfer function
            % H(s) = zeroes / poles, and solves it for the time response. Plots the time response
            % on the time response axes.
            syms s t
            numerator = prod(s - app.pointTracker.getZeroes());
            denominator = prod(s - app.pointTracker.getPoles());
            laplaceEquation = numerator ./ denominator;

            ts = linspace(app.timeSpan(1), app.timeSpan(2), 100);
            timeResponse_sym = ilaplace(laplaceEquation);
            timeResponse_numeric = subs(timeResponse_sym, t, ts);

            plot(app.timeAxes, ts, real(timeResponse_numeric), 'b-');
            hold(app.timeAxes, "on");
            plot(app.timeAxes, ts, imag(timeResponse_numeric), 'r-');
            legend(app.timeAxes, "Real", "Imaginary");
            xlim(app.timeAxes, app.timeSpan);
            hold(app.timeAxes, "off");
        end
    end
end