
% NOTE:
% class for channel data (from gathering fonction)


classdef Ch_data

    properties (Access = public)
        time double
        voltage double
        outliers_range logical
        overload
        estimations fit_core.Estimation
        time_conf
        accuracy_conf
        fs (1, 1) double
        period_counter (1, 1) double
    end

    methods (Access = public)
        function obj = Ch_data(time, voltage, outliers_range, overload, ...
                estimations, time_conf, accuracy_conf, fs, period_counter)
            obj.time = time;
            obj.voltage = voltage;
            obj.outliers_range = outliers_range;
            obj.overload = overload;
            obj.estimations = estimations;
            obj.time_conf = time_conf;
            obj.accuracy_conf = accuracy_conf;
            obj.fs = fs;
            obj.period_counter = period_counter;
        end
    end

end











