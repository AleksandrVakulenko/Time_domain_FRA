% FIXME: put in Fern::common

function out = rand_log_range(a, b, size)
arguments
    a double
    b double
    size double {mustBeInteger(size)} = 1
end

if a <= 0 || b <= 0
    error('a and b must be > 0')
end

if numel(size) == 1
    size = [1 size];
end

if a == b
    out = ones(size)*a;
else
    Max = max([a b]);
    Min = min([a b]);

    Max_log = log10(Max);
    Min_log = log10(Min);

    out_log = (Max_log-Min_log).*rand(size) + Min_log;

    out = 10.^out_log;
end

end