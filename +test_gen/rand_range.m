

% FIXME: put in Fern::common

function out = rand_range(a, b, size)
arguments
    a double
    b double
    size double {mustBeInteger(size)} = 1
end

if numel(size) == 1
    size = [1 size];
end

if a == b
    out = ones(size)*a;
else
    Max = max([a b]);
    Min = min([a b]);
    out = (Max-Min).*rand(size) + Min;
end

end




