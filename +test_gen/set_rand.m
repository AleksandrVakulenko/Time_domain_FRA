
% FIXME: put in Fern::common

function String = set_rand(String)
    arguments
        String = ""
    end
    
    if ~isempty(char(String))
        data = uint8(char(String));
        adler = java.util.zip.Adler32();
        adler.update(data);
        adler32_val = adler.getValue();
        
        Seed = uint32(adler32_val);
        rng(Seed)
    else
        rng('shuffle')
        String = gen_string(6);
    end
end