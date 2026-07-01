


function Freq_arr = move_bad_freq(Freq_arr, options)
arguments
    Freq_arr;
    options.Power_line_freq = 50;
    options.action {mustBeMember(options.action, ["move", "delete"])} = "move";
end

Power_line_freq = options.Power_line_freq;
Action= options.action;

% NOTE: settings
Power_line_harm_N = 5;
Harm_N = 7;
Min_dev = 0.05;

Freq_arr_init = Freq_arr;

Freq_arr = reshape(Freq_arr, 1, numel(Freq_arr));
Freq_arr = repmat(Freq_arr, Harm_N, 1);

for i = 1:size(Freq_arr, 2)
    Freq_arr(:, i) = Freq_arr(:, i)'.*(1:Harm_N);
end

Bad_freq = Power_line_freq*(1:Power_line_harm_N);

range_more = false(size(Freq_arr));
range_less = false(size(Freq_arr));
for i = 1:numel(Bad_freq)

Ratio = Freq_arr/Bad_freq(i);
range_more = range_more | (Ratio <= (1 + Min_dev) & Ratio >= 1);
range_less = range_less | (Ratio >= (1 - Min_dev) & Ratio <= 1);

end

% figure
% imagesc(range_more | range_less)

range_more = sum(range_more, 1) ~= 0;
range_less = sum(range_less, 1) ~= 0;

if Action == "delete"
    Freq_arr_init(range_more | range_less) = [];
else % "move"
    Freq_arr_init(range_more) = Freq_arr_init(range_more) * (1 + 1*Min_dev);
    Freq_arr_init(range_less) = Freq_arr_init(range_less) * (1 - 1*Min_dev);
end

Freq_arr = Freq_arr_init;

% figure
% hold on
% plot(range_less)
% plot(range_more)

end



