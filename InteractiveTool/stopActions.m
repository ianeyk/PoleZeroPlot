function stopActions()
    % set all global modes to the off state
    global deletingMode userStopped;
    deletingMode = false;
    userStopped = false;
end