

Res = [
14.8686
14.8692
14.8681
14.8690
14.8685
14.8685
14.8690
       
14.8676
14.8687
14.8468
14.8692
14.8687
14.8665
14.8694
       
14.8693
14.8677
14.8366
14.8669
14.8684
14.8706
14.8702

];

Res_err = [
0.0067
0.0067
0.0067
0.0067
0.0067
0.0067
0.0066

0.0116
0.0115
0.0188
0.0116
0.0116
0.0117
0.0114

0.0161
0.0161
0.0266
0.0165
0.0161
0.0162
0.0160

];


Phi = [
-10.655
-10.657
-10.665
-10.655
-10.659
-10.658
-10.655
       
-10.684
-10.668
-10.696
-10.688
-10.695
-10.694
-10.670
       
-10.690
-10.693
-10.705
-10.693
-10.689
-10.704
-10.684

];

Phi_err = [
0.026
0.026
0.026
0.026
0.026
0.026
0.026

0.045
0.044
0.072
0.044
0.045
0.045
0.044

0.062
0.062
0.104
0.064
0.062
0.063
0.062

];


range = [10 17];
Res(range) = [];
Res_err(range) = [];
Phi(range) = [];
Phi_err(range) = [];

%%



figure
errorbar(Res, Res_err)

figure
errorbar(Phi, Phi_err)

%%

figure
plot(abs(Res_err./Res)*100)


figure
plot(abs(Phi_err./Phi)*100)


%%

figure
plot(Res)
yline(14.862)
ylim([min(Res)*0.999 max(Res)*1.001])

figure
plot(Phi)
yline(-10.692)
ylim([min(Phi)*1.001 max(Phi)*0.999])


%%
clc

Pes_real = 14.862;
Phi_real = -10.692;

Res_dev = ((mean(Res)-Pes_real)/Pes_real)*100;

Phi_dev = (mean(Phi)-Phi_real);

num2str(['Res_dev = ' num2str(Res_dev, '%0.3f') ' %'])
num2str(['Phi_dev = ' num2str(Phi_dev, '%0.3f') ' deg'])




