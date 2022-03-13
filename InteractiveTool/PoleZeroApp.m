classdef PoleZeroApp < handle
    % Class for storing data related to running the PoleZeroTool app
    %   Used as a container instead of passing a bunch of global variables

    properties
        poles
        zeroes
        timeAxes
        poleZeroAxes
        timeSpan
        bounds
        zeroColor
        poleColor
        userStopped
        deletingMode
        conjugateMode
    end

    methods
        function app = PoleZeroApp(poleZeroAxes, timeAxes)
            app.bounds = [-2, 2; -3, 3];
            app.timeSpan = [0, 5];
            app.poles = [];
            app.zeroes = [];
            app.zeroColor = [0, 0, 1];
            app.poleColor = [1, 0, 0];
            app.timeAxes = timeAxes;
            app.poleZeroAxes = poleZeroAxes;
            app.userStopped = false;
            app.deletingMode = false;
            app.conjugateMode = true;
            app.setupAxes()
        end

        function setupAxes(app)
            xlim(app.poleZeroAxes, app.bounds(1, :));
            ylim(app.poleZeroAxes, app.bounds(2, :));
            xline(app.poleZeroAxes, 0, 'k-');
            yline(app.poleZeroAxes, 0, 'k-');
            xlim(app.timeAxes, [app.timeSpan(1), app.timeSpan(2)]);
        end

        function addZeroes(app);
            disp("adding Zeroes")
            app.userStopped = false;
            while ~app.userStopped
                zero = drawpoint(app.poleZeroAxes, "Color", "b", "DrawingArea", "unlimited");
                if ~isvalid(zero) || isempty(zero.Position) || outOfBounds(zero.Position, app.bounds)
                    % End the loop
                    app.userStopped = true;
                else
                    app.zeroes(end + 1) = toComplex(zero.Position);

                    % add event listeners to the new ROI point
                    addlistener(zero,'MovingROI', @app.updateROI);
                    addlistener(zero,'ROIMoved', @app.updateROI);
                    addlistener(zero,'DeletingROI', @app.updateROI);
                    addlistener(zero,'ROIClicked', @app.updateROI);
                    app.plotTimeDomainResponse();

                    if app.conjugateMode
                        % repeat the same process, but for the conjugate
                        conjugatePosition = zero.Position .* [1, -1]; % complex conjugate
                        conjugate = drawpoint(app.poleZeroAxes, "Color", "b", "DrawingArea", "unlimited", "Position", conjugatePosition);
                        app.zeroes(end + 1) = toComplex(conjugatePosition);

                        % add event listeners to the new ROI point
                        addlistener(conjugate,'MovingROI', @app.updateROI);
                        addlistener(conjugate,'ROIMoved', @app.updateROI);
                        addlistener(conjugate,'DeletingROI', @app.updateROI);
                        addlistener(conjugate,'ROIClicked', @app.updateROI);
                        app.plotTimeDomainResponse();
                    end
                end
            end
        end

        function addPoles(app);
            app.userStopped = false;
            while ~app.userStopped
                pole = drawpoint(app.poleZeroAxes, "Color", "r", "DrawingArea", "unlimited");
                if ~isvalid(pole) || isempty(pole.Position) || outOfBounds(pole.Position, app.bounds)
                    % End the loop
                    app.userStopped = true;
                else
                app.poles(end + 1) = toComplex(pole.Position);

                % add event listeners to the new ROI point
                addlistener(pole,'MovingROI', @app.updateROI);
                addlistener(pole,'ROIMoved', @app.updateROI);
                addlistener(pole,'DeletingROI', @app.updateROI);
                addlistener(pole,'ROIClicked', @app.updateROI);
                app.plotTimeDomainResponse();

                    if app.conjugateMode
                        % repeat the same process, but for the conjugate
                        conjugatePosition = pole.Position .* [1, -1]; % complex conjugate
                        conjugate = drawpoint(app.poleZeroAxes, "Color", "r", "DrawingArea", "unlimited", "Position", conjugatePosition);
                        app.poles(end + 1) = toComplex(conjugatePosition);

                        % add event listeners to the new ROI point
                        addlistener(conjugate,'MovingROI', @app.updateROI);
                        addlistener(conjugate,'ROIMoved', @app.updateROI);
                        addlistener(conjugate,'DeletingROI', @app.updateROI);
                        addlistener(conjugate,'ROIClicked', @app.updateROI);
                        app.plotTimeDomainResponse();
                    end
                end
                app.poles
            end
        end

        function clearPoints(app)
            global zeroes poles poleZeroAxes;
            oldPoints = findobj(app.poleZeroAxes,'Type','images.roi.point');
            delete(oldPoints);
            app.zeroes = [];
            app.poles = [];
            app.plotTimeDomainResponse();
        end

        function deletePoints(app)
            app.deletingMode = true;
        end

        function stopActions(app)
            % set all global modes to the off state
            deletingMode = false;
            userStopped = false;
        end

        function plotTimeDomainResponse(app)
            syms s t
            numerator = prod(s - app.zeroes);
            denominator = prod(s - app.poles);
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

        function updatePoints(app, src, evt, deletePoint)
            src
            app.zeroes
            app.poles

            if src.Color == app.zeroColor
                findFrom = app.zeroes;
            elseif src.Color == app.poleColor
                findFrom = app.poles;
            end

            if deletePoint == "delete"
                findWhat = src.Position;
                changeTo = [];
            else
                findWhat = evt.PreviousPosition;
                changeTo = toComplex(src.Position);
                changeConjTo = toComplex(src.Position .* [1, -1]);
            end

            % update the values
            idx = findPoint(findWhat, findFrom);

            if src.Color == app.zeroColor
                app.zeroes(idx) = changeTo;
            elseif src.Color == app.poleColor
                app.poles(idx) = changeTo;
            end

            % repeat for the conjugate
            if src.Color == app.zeroColor
                findFrom = app.zeroes;
            elseif src.Color == app.poleColor
                findFrom = app.poles;
            end

            idxConj = findPoint(findWhat .* [1, -1], findFrom);
            if src.Color == app.zeroColor
                app.zeroes(idxConj) = changeConjTo;
            elseif src.Color == app.poleColor
                app.poles(idxConj) = changeConjTo;
            end


            % if src.Color == app.zeroColor
            %     if deletePoint == "delete"
            %         idx = findPoint(src.Position, app.zeroes);
            %         app.zeroes(idx) = [];
            %     else
            %         idx = findPoint(evt.PreviousPosition, app.zeroes);
            %         app.zeroes(idx) = toComplex(src.Position);
            %     end
            % elseif src.Color == app.poleColor
            %     if deletePoint == "delete"
            %         idx = findPoint(src.Position, app.poles);
            %         app.poles(idx) = [];
            %     else
            %         idx = findPoint(evt.PreviousPosition, app.poles);
            %         app.poles(idx) = toComplex(src.Position);
            %     end
            % end
            app.zeroes
            app.poles
            deletePoint
            app.plotTimeDomainResponse();
        end

        function updateROI(app, src, evt)
            disp("reached this point")
            evname = evt.EventName;
            switch(evname)
                case{'MovingROI'}
                    app.updatePoints(src, evt, "no delete");
                    disp("moving ROI")
                case{'ROIMoved'}
                    app.updatePoints(src, evt, "no delete");
                    disp("moved ROI")
                case{'DeletingROI'}
                    app.updatePoints(src, evt, "delete");
                case{'ROIClicked'}
                    % if a point is clicked, check if we are in deleting mode; if so, the click deletes the point
                    if app.deletingMode
                        app.updatePoints(src, evt, "delete");
                        delete(src);
                    end
            end
        end

    end
end