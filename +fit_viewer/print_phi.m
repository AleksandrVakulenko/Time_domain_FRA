function print_phi(Phi, Phi_err)
arguments
    Phi
    Phi_err = []
end
    if ~isempty(Phi_err)
        disp(['Phi = ' num2str(Phi, '%0.3f') ' ± ' ...
            num2str(Phi_err, '%0.3f') ' deg'])
    else
        disp(['Phi = ' num2str(Phi, '%0.3f') ' deg'])
    end
end