

classdef LCR_device_name_type

    properties (Access = private)
        class_name_ string
        address_string_ string
    end

    methods (Access = public)
        function obj = LCR_device_name_type(class_name, address_string)
            arguments
                class_name string
                address_string string = ""
            end
                obj.class_name_ = class_name;
                obj.address_string_ = address_string;
        end

        function dev_obj = init_connection(obj)
            dev_obj = feval(obj.class_name_, obj.address_string_);
        end
    end


end