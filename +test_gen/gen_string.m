function String = gen_string(N)
array_c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
ind = round(rand(1, N)*1000);
ind = mod(ind, numel(array_c))+1;
Word = array_c(ind);
String = test_gen.set_rand(Word);
end