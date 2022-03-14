classdef PoleZeroApp < handle
    % POLEZEROAPP is a class containing the functionality for running the PoleZeroTool app.
    %   Changes to the interface of the PoleZeroTool GUI essentially call various methods
    %   on POLEZEROAPP. The main purpose is to allow input of pole and zero locations and to
    %   store these values. Whenever a change is made, the method plotTimeDomainResponse is
    %   called, which solves the inverse Laplace transform for the transfer function given
    %   by the poles and zeroes. Using event handlers allows the time domain response to
    %   update in real time (albeit with significant lag due to computational intensity).

    properties
        poles % PointTracker object; essentially a list of the active poles on the pole-zero plot
        zeroes % PointTracker object; essentially a list of the active zeroes on the pole-zero plot
        timeAxes % axes object passed by PoleZeroTool app for the time response
        poleZeroAxes % axes object passed by PoleZeroTool app for the pole-zero plot gui
        timeSpan % 1 x 2 vector for time response
        bounds % 2 x 2 vector for pole-zero plot bounds: [minX, maxX; minY, maxY]
        zeroStruct % static struct for storing properties related to zeroes (color, name, etc.)
        poleStruct % static struct for storing properties related to poles (color, name, etc.)
        % currentPointType
        userStopped % boolean flag used for placing multiple poles and zeroes
        deletingMode % boolean flag that tells us when the Delete Points button has been clicked
        conjugateMode % boolean flag for whether conjugate points should be treated together
        pointTracker % PointTracker object; essentially a list of the active poles and zeroes on
                     % the pole-zero plot. Also contains functionality for conjugate pairs
    end

    methods
        function app = PoleZeroApp(poleZeroAxes, timeAxes)
            app.bounds = [-2, 2; -3, 3];
            app.timeSpan = [0, 5];
            app.poles = [];
            app.zeroes = [];
            app.zeroStruct.type = "zero";
            app.poleStruct.type = "pole";
            app.zeroStruct.color = [0, 0, 1];
            app.poleStruct.color = [1, 0, 0];
            app.timeAxes = timeAxes;
            app.poleZeroAxes = poleZeroAxes;
            app.userStopped = false;
            app.deletingMode = false;
            app.conjugateMode = true;
            % app.currentPointType = "";
            app.pointTracker = PointTracker();
            app.setupAxes();
        end

        function setupAxes(app)
            xlim(app.poleZeroAxes, app.bounds(1, :));
            ylim(app.poleZeroAxes, app.bounds(2, :));
            xline(app.poleZeroAxes, 0, 'k-');
            yline(app.poleZeroAxes, 0, 'k-');
            xlim(app.timeAxes, [app.timeSpan(1), app.timeSpan(2)]);
        end

        function addPoints(app, typeStruct);
            app.userStopped = false;
            while ~app.userStopped
                % pointRoi = app.pointTracker.addPoint(app.poleZeroAxes, typeStruct);
                userData.type = typeStruct.type;
                userData.id = app.pointTracker.getCount(typeStruct.type);
                userData.isConjugate = false;

                roi = drawpoint(app.poleZeroAxes, "Color", typeStruct.color, "DrawingArea", "unlimited", "UserData", userData);
                if ~isvalid(roi) || isempty(roi.Position) || outOfBounds(roi.Position, app.bounds)
                    % Deletet the last point and end the loop
                    app.userStopped = true;
                else
                    app.pointTracker.addPoint(roi);
                    app.addHandlers(roi);

                    if app.conjugateMode
                        conjPosition = roi.Position .* [1, -1];
                        userData.isConjugate = true;
                        roiConj = drawpoint(app.poleZeroAxes, "Color", typeStruct.color, "DrawingArea", "unlimited", ...
                        "Position", conjPosition, "UserData", userData);
                        app.pointTracker.addPoint(roiConj);
                        app.addHandlers(roiConj);
                    else
                        roiConj.Position = [NaN, NaN]; % create a generic struct that just contains the Position property
                        userData.isConjugate = true;
                        roiConj.UserData = userData;
                        app.pointTracker.addPoint(roiConj);
                    end

                    % only if not rejected
                    app.pointTracker.incrementCount(typeStruct.type);
                    app.plotTimeDomainResponse();
                end
            end
        end

        function callFunctionThenUpdatePlot(app, func)
            func();
            app.plotTimeDomainResponse();
        end

        function deletePointIfClicked(app, src, evt)
            if app.deletingMode
                app.deletePoint(src, evt);
            end
        end

        function deletePoint(app, src, evt)
            type = src.UserData.type;
            id = src.UserData.id;
            if app.conjugateMode
                app.pointTracker.deletePoint(src, evt, false, type, id);
                app.pointTracker.deletePoint(src, evt, true, type, id);
            else
                if src.UserData.isConjugate
                    app.pointTracker.deletePoint(src, evt, true, type, id);
                else
                    app.pointTracker.deletePoint(src, evt, false, type, id);
                end
            end
            app.plotTimeDomainResponse();
        end

        function movePointSnap(app, src, evt)
            app.movePoint(src, evt, true);
        end

        function movePointNoSnap(app, src, evt)
            app.movePoint(src, evt, false);
        end

        function movePoint(app, src, evt, snap)
            if app.conjugateMode
                if src.UserData.isConjugate
                    app.pointTracker.movePoint(src, evt, true, [1, 1], snap);
                    app.pointTracker.movePoint(src, evt, false, [1, -1], snap);
                else
                    app.pointTracker.movePoint(src, evt, false, [1, 1], snap);
                    app.pointTracker.movePoint(src, evt, true, [1, -1], snap);
                end
            else
                if src.UserData.isConjugate
                    app.pointTracker.movePoint(src, evt, true, [1, 1], snap);
                else
                    app.pointTracker.movePoint(src, evt, false, [1, 1], snap);
                end
            end
            app.plotTimeDomainResponse();
        end

        function addHandlers(app, roi)
            addlistener(roi, 'MovingROI',   @app.movePointNoSnap);
            addlistener(roi, 'ROIMoved',    @app.movePointSnap);
            addlistener(roi, 'DeletingROI', @app.deletePoint);
            addlistener(roi, 'ROIClicked',  @app.deletePointIfClicked);
        end

        function clearPoints(app)
            global zeroes poles poleZeroAxes;
            oldPoints = findobj(app.poleZeroAxes,'Type','images.roi.point');
            delete(oldPoints);
            app.zeroes = [];
            app.poles = [];
            app.pointTracker = PointTracker();
            app.plotTimeDomainResponse();
        end

        function deletePoints(app)
            app.deletingMode = true;
        end

        function stopActions(app)
            % set all global modes to the off state
            app.deletingMode = false;
            app.userStopped = false;
        end

        function plotTimeDomainResponse(app)
            syms s t
            % numerator = prod(s - app.zeroes);
            % denominator = prod(s - app.poles);
            numerator = prod(s - app.pointTracker.getZeroes());
            denominator = prod(s - app.pointTracker.getPoles());
            % two_zeros_three_poles=((s-z1).*(s-z2))./((s-p1).*(s-p2).*(s-p3));
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