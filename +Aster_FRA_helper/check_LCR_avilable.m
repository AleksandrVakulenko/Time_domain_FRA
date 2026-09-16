
function LCR_avilable = check_LCR_avilable(LCR_type)
arguments
    LCR_type Aster_FRA_helper.LCR_device_name_type
end

if isempty(LCR_type)
    LCR_avilable = false;
else
    try
        LCR_dev = LCR_type.init_connection();
        delete(LCR_dev)
        LCR_avilable = true;
    catch
        LCR_avilable = false;
    end
end

end