% Copyright (C) 2016, Tania Sanchez 
%This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 

%NOTE: this correcton approximation does the fit of the creep portion only
% Optimization procedure used to obtain the initial viscoelastic parameters
% by fitting the experimentally obtained data to the analytical solution
% (viscoelastic correspondence analysis using a creep compliance function
% in the form of a Prony series for a SLS model)

%%
%clear MATLAB
close all;
clear all;
clc
%%
%Load data from the indentations tests (should be time vs displ)
%NOTE: displacement should be given in mm so that it matches the ABAQUS US
load pdms2.dat

%%
%This section should be used for more than one indentaion data sets
%contained in the same .dat file
seto=1;
i=1:1;
for j=i(mod(i,2)~=0)
time= pdms2(:,j);
displ = (pdms2(:,(j+1)));

%% Make sure the data is monotonically increasing 
[tu, ui]= unique(time);
hu= displ(ui);
displ= hu;
time=tu;

%%Distribute the data in a grid  with constant spacing
% F=interparc(100,tu,hu);
% displ=F(:,2);
% time=F(:,1);

%%Scaled displacement and non-scaled displacement in monotonic form
displ= displ.^(3/2);
h=pdms2(:,(j+1));
h=h(ui);  % Note: to be used if the data has olny been made monotonic but
%not a grid
%h=F(:,2);  %Note: to be used for data in a grid

%%
%Provide constants
%k: load rate [N/s], R:indenter radius [mm]
%assign time and displacement variables from indentation tests
%this variables are global as need to be accessed by the objective function
global k R t  tr yy  ycreep weight;
%load rates.mat
R=0.015; 

% 12 uN
tr=[4.07428000000000];
Pmax=9.5e-06;
k=Pmax/tr;

% %16uN
% k=2.9343e-06;
% tr=[4.26000000000000];

%22uN
% P=19.5e-06;
% tr=[4.47000000000000];
% k=P/tr;

%%
%find the loading portion and the unloading portion based on the rising
%time tr
yy= arrayfun(@(x) find(time == x,1,'first'), tr );
ycreep = displ(yy:length(displ));
t = [time(yy:length(displ))];
%t = [time(yy:length(displ))];
hcreep = h(yy:length(displ));

 weight=(1./ycreep);
 weight=(weight-weight(1))/(weight(length(weight))-weight(1));

%% 
% Call the fitting method lsqnonlin
%provide the initial guess (can be an arbitrary value)and different to zero
z0 = [0.1 0.1 0.1];

%Options structure for the optimization routine
 options = optimoptions (@lsqnonlin,'PlotFcns', {@optimplotx,...
    @optimplotfval, @optimplotfirstorderopt,@optimplotresnorm}, 'TolFun',1e-030, 'TolX', 1e-030,'MaxFunEvals',5000,'MaxIter', 10000);

 %options = optimoptions (@lsqnonlin, 'TolFun',1e-030, 'TolX', 1e-030,'MaxFunEvals',5000,'MaxIter', 10000);

%call the optimization procedure and give the lower ans upper boundaries
%for the variables
L=[0 0 0];
U=[inf inf inf];
[z,resnorm,residual,exitflag, output, lambda, jacobian]=lsqnonlin(@objectivecreep,z0, L,U, options);

%%
%evaluate the function using the time and calculated parameters

% evaluate using the obtained parameters
a=z(1); b=z(2); c=z(3);


obj2 =  @(t)([(3*k)/(8*(R^(1/2)))]*...
 [a*tr - b*c*(exp(-t/c))*(-1+(exp(tr/c)))]);

%evaluating the function
hload2= obj2(t);

%plot indentation tests data fit
figure;
subplot(2,1,1)
set(gca, 'ColorOrder', cool(3), 'NextPlot', 'replacechildren');
hold on;
%plot the function (fit) vs the experimental data
subplot(2,1,1)
%plot(t,ycreep, 'Color', [0.72,0.3,0.82], 'linewidth', 2.3);
plot(t,ycreep, 'linewidth', 1.5);
plot(t,hload2,'-.','linewidth',2.0)
%plot(t,hload2,'-o', 'Color', [1,0.4,0.6],'linewidth', 2.3)

%Title and axis labels
title ('Indentation tests', 'Fontsize', 12);
xlabel ('Time (s)', 'Fontsize',12);
ylabel ('h^{3/2}(t) (mm)', 'Fontsize', 12);
leg=legend('experimental data','data fit ');
set(leg, 'Location', 'SouthEast');

%non-scaled load
hreal= hload2.^(2/3);
subplot(2,1,2)
 set(gca, 'ColorOrder', bone(3), 'NextPlot', 'replacechildren');
 plot(t,hreal,'-.',  'linewidth', 2.0);
%plot(t,hreal,'-', 'Color', [0.25,0.87,0.81], 'linewidth', 2.5);
hold on;
plot(t, hcreep, '-', 'linewidth',2.5);
%plot(t, hcreep, '-', 'Color', [0.5373,0.4078,0.8039],'linewidth',1.5);

%Title and exis labels
title ('Indentation tests (non-scaled data)', 'Fontsize', 12);
xlabel ('Time (s)', 'Fontsize',12);
ylabel ('h(mm)', 'Fontsize', 12);
leg=legend('data fit', 'experimental data');
set(leg, 'Location' ,'SouthEast')

%%
% RELATING TO THE UMAT 
% Determination of the mechanical properties (G, K, eta) that should be
% used in the UMAT for ABAQUS
% NOTE: the indexes 'E' stand for the elastic spring only and the 'M'
% coefficients stand for the Maxwell element components

%%
% Instataneous and long term (equilibrium) shear moduli
G_inf = 1 / (2*(z(1)));
G_0 = 1 / (2*(z(1)-z(2)));

Einf=3*G_inf;
E0=3*G_0;

%Poisson's ratio
v = 0.4995;

%% Now from the Maxwell SLS model
a= z(1);
b=z(2);
c=(z(3));

%Creep compliance coefficients
Cg=a;
Cr=a-b;

%Young's modulus
E_E=3/(2*Cg);
E_M=E0-Einf;

%Shear Modulus
G_M = E_M / (2.0*(1+v));
G_E = E_E / (2.0*(1+v));

%Bulk Modulus
K_M = E_M / (3*(1-(2*v)));
K_E = E_E / (3*(1-(2*v)));

%Viscosity
tau_diff=1/(E_E/(E_E+E_M));
tau=c*(E_E/(E_E+E_M));
tau=c;
eta_t= tau*E_M;
eta_s= tau*G_M;

%%
%Save the UMAT mechanical parameters
UMAT = fopen('UMAT.txt','w');
fprintf(UMAT, 'UMAT parameters (KE, GE, KMe, GMe, GV)\n%12.8f\n%12.8f\n%12.8f\n%12.8f\n%12.8f\r\n', K_E, G_E, K_M, G_M, eta_s);
fclose(UMAT);

%Save experimental creep data 
creepx(:,1)= t;
%creepx(:,2)=hreal;  %fit on the experimental data
creepx(:,2)=hcreep; %real experimental data
dlmwrite('pdmscreep.txt',creepx,'delimiter','\t','precision',5)

%%
%Run the .exe file to update the UMAT parameters 
%!umat

%Display the mechanical perameters used 
type UMAT.txt

%%
%New plotting style (THESIS READY)
%plot indentation tests data fit
close all;
figure('Name','final','NumberTitle','off')
subplot(2,1,1)
hold on;
box on;
%plot the function (fit) vs the experimental data
subplot(2,1,1)
plot(t,ycreep,'-*', 'linewidth', 2.5, 'color', [0.0,0.8, 0.8], 'MarkerSize', 3.0);
plot(t,hload2,'-.','color', [0.4784, 0.298, 0.7569],'linewidth',2.0)

%Title and axis labels
title ('Scaled data', 'Fontsize', 12);
xlabel ('time (s)', 'Fontsize',12);
ylabel ('h^{3/2}(t) (mm^{3/2})', 'Fontsize', 12);
leg=legend('Experimental data', 'Data fit');
set(leg, 'Location', 'SouthEast', 'box', 'off')

%non-scaled load
hreal= hload2.^(2/3);
subplot(2,1,2)
 set(gca, 'ColorOrder', bone(3), 'NextPlot', 'replacechildren');
hold on;
box on;
plot(t,hreal,'-*',  'linewidth', 2.5, 'MarkerSize', 3.0);
plot(t, hcreep, '-.', 'linewidth',2.0);


%Title and axis labels
title ('Non-scaled data', 'Fontsize', 12);
xlabel ('time (s)', 'Fontsize',12);
ylabel ('h(mm)', 'Fontsize', 12);
leg=legend('Data fit','Experimental data' );
set(leg, 'Location' ,'SouthEast', 'box', 'off');

%Save the plot in the appropriate folder
% fileloc=fullfile('\\nask.man.ac.uk','home$','My Pictures','layered PDMS','thickness correction',...
%   '3000um-12uN.fig')
% savefig(fileloc)

%%Save the parameters for all the thicknesses/data sets
parametros(seto,1)=K_E;
parametros(seto,2)=G_E;
parametros(seto,3)=K_M;
parametros(seto,4)=G_M;
parametros(seto,5)=eta_s;
parametros(seto,6)=z(1);
parametros(seto,7)=b;
parametros(seto,8)=z(3);

seto=seto+1;
end

%Preliminar plotting of the material parameters 
%NOTE: the layers thickness are in mm to comply with the units used
%throughout
 delta=[5,8,15,25,100,200,500,750,1000,1500,2000,2500,3000]./1000;
 delta=transpose(delta);
%  close all 
%  hold on 
%  plot(delta,parametros(:,2), '-o');
%  legend('Ge');
%  figure 
%  plot (delta, parametros(:,4), 'o-');
%  legend('Gm');
