

function LCR_terminate(LCR_type)

if isempty(LCR_type)
    return
end

try
    LCR_dev = LCR_type.init_connection();
catch
    return
end

err = [];
try
    LCR_dev.terminate;
catch err
    delete(LCR_dev);
    rethrow(err);
end

if isempty(err)
    delete(LCR_dev);
end

end