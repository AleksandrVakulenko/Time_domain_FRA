
% FIXME: place to Fern:aDevice

classdef AFG1022_dev < handle
    properties (Access = private)
        visa_dev = [];

    end

%--------------------------------PUBLIC--------------------------------
    methods (Access = public)
        function obj = AFG1022_dev()
            vias_adr = find_visa_dev_by_name("AFG1022");
            if ~isempty(vias_adr)
                %new visadev is bad, we use old
                obj.visa_dev = visa('ni',vias_adr);
            else
                error('connection error');
            end
        end
        
        function delete(obj)
             delete(obj.visa_dev); %FIXME: use it or not?
        end

        function response = IDN(obj)
            response = obj.query("*IDN?");
            response = strtrim(response);
        end

        function initiate(obj)
            % FIXME: undone
        end

        function terminate(obj)
            % FIXME: undone
        end

        function freq = set_freq(obj, freq_in)
            CMD = ['SOURCE1:FREQUENCY:FIXED ' num2str(freq_in) ' Hz'];
            obj.send(CMD);
            resp = obj.query('SOURCE1:FREQUENCY:FIXED?');
            resp = strtrim(resp);
            data = sscanf(resp, '%f');
            if ~isempty(data)
                freq = data(1);
            end
        end

        function amp = set_amp(obj, amp, type)
            arguments
                obj
                amp double
                type {mustBeMember(type, ["amp", "Ap-p"])} = "amp"
            end
            if type == "amp"
                amp = amp * 2;
            end
            CMD = ['SOURce1:VOLTage:LEVel:IMMediate:AMPLitude ' num2str(amp) ' Vpp'];
            obj.send(CMD);
            resp = obj.query('SOURce1:VOLTage:LEVel:IMMediate:AMPLitude?');
            resp = strtrim(resp);
            data = sscanf(resp, '%f');
            if ~isempty(data)
                amp = data(1);
            end
        end

        function offset = set_offset(obj, offset)
            arguments
                obj
                offset double
            end
            CMD = ['SOURce1:VOLTage:LEVel:IMMediate:OFFSet ' num2str(offset) ' V'];
            obj.send(CMD);
            resp = obj.query('SOURce1:VOLTage:LEVel:IMMediate:OFFSet?');
            resp = strtrim(resp);
            data = sscanf(resp, '%f');
            if ~isempty(data)
                offset = data(1);
            end
        end     

        function shape = set_func(obj, shape)
            arguments
                obj
                shape {mustBeMember(shape, ["sin", "sq", "triangle"])}
            end
            if shape == "sin"
                shape = 'SINusoid';
            end
            if shape == "sq"
                shape = 'SQUare';
            end
            if shape == "triangle"
                shape = 'RAMP';
            end
            CMD = ['SOURce1:FUNCtion:SHAPe ' shape];
            obj.send(CMD);
            shape = obj.query('SOURce1:FUNCtion:SHAPe?');
            shape = strtrim(shape);
        end  


    end
    
    %-------------------------------PRIVATE--------------------------------

    
    methods (Access = private)
        function send(obj, CMD)
            dev = obj.visa_dev;
            fopen(dev);
            fprintf(dev, CMD);
            fclose(dev);
        end

        function response = query(obj, CMD)
            dev = obj.visa_dev;
            fopen(dev);
            fprintf(dev, CMD);
            response = fscanf(dev);
            fclose(dev);
        end
    end
    
end









function vias_adr = find_visa_dev_by_name(name)
    dev_table = visadevlist;
    ind = find(dev_table.Model == name);
    if ~isempty(ind)
        vias_adr = dev_table.ResourceName(ind);
    else
        vias_adr = "";
    end
end













