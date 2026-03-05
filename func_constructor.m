function [Eq, Type] = func_constructor(X_vec, Par_pref)

% % input vars ----
% Par_pref = 'p';
% Period = 1;
% % Type = "const"; % "poly2", "const", "linear"
% % Type = "linear";
% Type = "poly2";
% % ---------------

switch numel(X_vec)
    case {0, 1}
        Type = "const";
        x1 = 0;
        x2 = 0;
        x3 = 0;
    case 2
        x1 = X_vec(1);
        x2 = X_vec(2);
        x3 = 0;
        Type = "linear";
    case 3
        x1 = X_vec(1);
        x2 = X_vec(2);
        x3 = X_vec(3);
        Type = "poly2";
    otherwise
        error('wrong number of points')
end



x12s = ['(' num2str(x1 - x2) ')'];
x13s = ['(' num2str(x1 - x3) ')'];
x21s = ['(' num2str(x2 - x1) ')'];
x23s = ['(' num2str(x2 - x3) ')'];
x31s = ['(' num2str(x3 - x1) ')'];
x32s = ['(' num2str(x3 - x2) ')'];

x1s = ['(' 'x/' num2str(1) '-' num2str(x1) ')'];
x2s = ['(' 'x/' num2str(1) '-' num2str(x2) ')'];
x3s = ['(' 'x/' num2str(1) '-' num2str(x3) ')'];

y1s = ['' Par_pref '1'];
y2s = ['' Par_pref '2'];
y3s = ['' Par_pref '3'];

A1 = [x2s '.*' x3s '/' x12s '/' x13s];
A2 = [x1s '.*' x3s '/' x21s '/' x23s];
A3 = [x1s '.*' x2s '/' x31s '/' x32s];



switch Type
    case "const"
%         Eq = ['(' y1s '+0*x' ')']; % NOTE: debug
        Eq = ['(' y3s ')']; % FIXMRE: debug
    case "linear"
        Eq = ['(' y2s '*' x2s '/' x12s ' + ' y3s '*' x1s '/' x21s ')'];
    case "poly2"
        Eq = ['(' y1s '*' A1 ' + ' y2s '*' A2 ' + ' y3s '*' A3 ')'];
    otherwise
        error('unreachable')
end


end