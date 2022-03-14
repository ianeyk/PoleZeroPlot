function out = outOfBounds(pos, bounds)
    out = pos(1) < bounds(1, 1) || pos(1) > bounds(1, 2) || ...
          pos(2) < bounds(2, 1) || pos(2) > bounds(2, 2);
end