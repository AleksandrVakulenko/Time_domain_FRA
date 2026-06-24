

function write_json_file(Filename, JSON_text)
fid = fopen(Filename, "w");
fprintf(fid, '%s', JSON_text);
fclose(fid);
end