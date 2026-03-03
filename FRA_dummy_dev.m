

classdef FRA_dummy_dev < handle
    properties
        T_arr_stash
        V1_arr_stash
        V2_arr_stash
        T_arr
        V1_arr
        V2_arr
        init_time = NaN
        base_time = NaN
    end

    methods
        function obj = FRA_dummy_dev(T_arr, V1_arr, V2_arr)
            arguments
                T_arr double
                V1_arr double
                V2_arr double = [];
            end
            obj.T_arr = T_arr;
            obj.V1_arr = V1_arr;
            obj.V2_arr = V2_arr;
            obj.T_arr_stash = T_arr;
            obj.V1_arr_stash = V1_arr;
            obj.V2_arr_stash = V2_arr;
        end


        function run(obj)
            obj.init_time = tic;
            obj.base_time = obj.T_arr(1);
        end


        function stop(obj)
            obj.init_time = NaN;
            obj.T_arr = obj.T_arr_stash;
            obj.V1_arr = obj.V1_arr_stash;
            obj.V2_arr = obj.V2_arr_stash;
        end


        function CMD_data_stream(obj, status)
            if status
                obj.run();
            else
                obj.stop();
            end
        end


        function [T, V1] = get_data_ch1(obj)
            [T, V1, ~] = obj.get_CV();
        end


        function [T, V1, V2] = get_CV(obj)
            if ~isnan(obj.init_time)
                Time_passed = toc(obj.init_time);
                if ~isempty(obj.T_arr)
                    range = obj.T_arr < Time_passed + obj.base_time;
                else
                    range = [];
                end
                if ~isempty(find(range))
                    T = obj.T_arr(range);
                    V1 = obj.V1_arr(range);
                    obj.T_arr(range) = [];
                    obj.V1_arr(range) = [];
                    if ~isempty(obj.V2_arr)
                        V2 = obj.V2_arr(range);
                        obj.V2_arr(range) = [];
                    else
                        V2 = [];
                    end
                else
                    T = [];
                    V1 = [];
                    V2 = [];
                end

            else
                error('data stream is not initiated (Test_dev)')
            end

        end
    end


end
