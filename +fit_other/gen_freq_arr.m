
function Freq_arr = gen_freq_arr(F_min, F_max, F_num, options)
arguments
F_min {mustBeGreaterThan(F_min, 0)} = 0.1
F_max {mustBeGreaterThan(F_max, 0)} = 300e3
F_num {mustBeGreaterThan(F_num, 0), mustBeInteger(F_num)} = 33
options.correction {mustBeMember(options.correction, ["on", "off"])} = "on"
options.repeat {mustBeInteger(options.repeat), ...
    mustBeGreaterThanOrEqual(options.repeat, 1)} = 1;
options.shuffle {mustBeMember(options.shuffle, ["on", "off"])} = "off"
end

if F_min > F_max
    error('Fmin must be less or equal to F_max')
elseif F_min == F_max
    Freq_arr = F_min;
    return;
end

Freq_arr = 10.^linspace(log10(F_min), log10(F_max), F_num);

if options.correction == "on"
    Freq_arr = fit_other.correct_freq_list(Freq_arr);
end

if options.repeat > 1
    N = options.repeat;
    Freq_arr = repmat(Freq_arr, N, 1);
    Freq_arr = reshape(Freq_arr, 1, numel(Freq_arr));
end

if options.shuffle == "on"
    N = numel(Freq_arr);
    ind = randperm(N);
    Freq_arr = Freq_arr(ind);
end

end
