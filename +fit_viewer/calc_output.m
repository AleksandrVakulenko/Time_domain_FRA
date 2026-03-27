function Output = calc_output(Result_in, pps)
arguments
    Result_in
    pps = []
end
    T_start = Result_in.amp_poly.x(1);
    T_end = Result_in.amp_poly.x(3);
    Length = T_end - T_start;  % [s]

    flag = false;
    if isempty(pps)
        pps = 5;
        flag = true;
    else

    end

    N = round(Length * pps);
    if N < 1
        N = 5;
        flag = true;
    end
    T_arr = linspace(T_start, T_end, N);
    
    Amp = fit_viewer.poly3calc(Result_in.amp_poly, T_arr);
    Phi = fit_viewer.poly3calc(Result_in.phi_poly, T_arr);
    BG = fit_viewer.poly3calc(Result_in.bg_poly, T_arr);
    Amp_err = fit_viewer.poly3calc(Result_in.amp_poly_err, T_arr);
    Phi_err = fit_viewer.poly3calc(Result_in.phi_poly_err, T_arr);
    BG_err = fit_viewer.poly3calc(Result_in.bg_poly_err, T_arr);

    if flag
        Amp_err = sqrt(std(Amp)^2 + mean(Amp_err).^2);
        Phi_err = sqrt(std(Phi)^2 + mean(Phi_err).^2);
        BG_err = sqrt(std(BG)^2 + mean(BG_err).^2);

        Amp = mean(Amp);
        Phi = mean(Phi);
        BG = mean(BG);

        T_arr = mean(T_arr);
    end

    Output.amp = Amp;
    Output.amp_err = Amp_err;
    Output.phi = Phi;
    Output.phi_err = Phi_err;
    Output.bg = BG;
    Output.bg_err = BG_err;
    Output.time = T_arr;
    Output.freq = Result_in.freq;
    Output.debug_result = Result_in;
    Output.single_flag = flag;
end