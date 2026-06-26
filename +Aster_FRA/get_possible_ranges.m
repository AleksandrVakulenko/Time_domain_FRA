
function Possible_ranges = get_possible_ranges(freq)

Freq_limit = [200 200 200 70 2 0.2]; % Hz

range = Freq_limit >= freq;

Possible_ranges = [1 2 3 4 5 6];
Possible_ranges(~range) = [];

end
