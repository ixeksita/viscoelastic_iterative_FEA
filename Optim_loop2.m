close all;
clear all;

%FE obtained data ( as extracted from ABAQUS h=[mm], t=[s])
load FE.dat
timeFE= FE(:,1);
displFE= FE(:,2);

%variables
global t tr displ yy k R;
R = 0.015;
tr=[3.97813000000000];
tr=[4.07428000000000];
Pmax=9.5e-6;
 k=Pmax/tr;
 
%%
% Fit done on the experimental data (or experimental data without fit)
load pdmscreep.txt
timex=pdmscreep(:,1);
displx=pdmscreep(:,2).^(3/2);

%set the vectors to run the optimization on 
displ= displx;  %scaled experimental displacement
%t=timex;        %experimental time

%% Make sure the data is monotonically increasing 
[tu, ui]= unique(timex);
hu= displ(ui);
displ= hu;
t=tu;

%%Distribute the data in a grid  with constant spacing
F=interparc(31,tu,hu);
displ=F(:,2);
t=F(:,1);
creepexp= displ.^(2/3);

%% 
%provide the initial guess (can be an arbitrary value)and different to zero
x0 = [0.1 0.1 0.05];


%Options structure for the optimization routine
options = optimoptions (@lsqnonlin,'Algorithm', 'levenberg-marquardt','PlotFcns', {@optimplotx,...
    @optimplotfval, @optimplotfirstorderopt}, 'TolFun',1e-030, 'TolX', 1e-030,'MaxFunEvals',5000,'MaxIter', 10000);

%invoke the optimization procedure and give the lower ans upper boundaries
%for the variables
L=[0 0 0];
U=[inf inf inf];
[x,resnorm,residual,exitflag, output]=lsqnonlin(@obj_loop,x0, L,U, options);

%Plot the experimental data and the fit data 
a=x(1);
b=x(2);
c=x(3);

%FULL CREEP
creep=  @(t)([(3*k)/(8*(R^(1/2)))]*...
 [a*tr - b*c*(exp(-t/c))*(-1+(exp(tr/c)))]);

 %Plotting
creepx=creep(t);
figure;
hold on;
plot(t,creepx, '.','Color',[1,0.4,0.6], 'linewidth', 1.5)

%%
% Fit on the FE dat%Find the creep portion of the FE data
yy= arrayfun(@(x) find(timeFE >x,1,'first'), tr );
creeptFE = [timeFE(yy:length(displFE))];
creephFE = displFE(yy:length(displFE));

%Replace the vectors with the FE data  
t=creeptFE;
displ =creephFE.^(3/2);

%Initial values for the fit 
x0= [0.1 0.1 0.05];

%Options structure for the optimization routine
options = optimoptions (@lsqnonlin,'Algorithm', 'levenberg-marquardt','PlotFcns', {@optimplotx,...
    @optimplotfval, @optimplotfirstorderopt}, 'TolFun',1e-030, 'TolX', 1e-030,'MaxFunEvals',5000,'MaxIter', 10000);
[x,resnorm,residual,exitflag, output]=lsqnonlin(@obj_loop,x0, L,U, options);
close 'Optimization PlotFcns';

%% Plotting 
%Plot FE data and the fit data 
d=x(1);
e=x(2);
f=x(3);

%FULL CREEP
creep2=  @(t)([(3*k)/(8*(R^(1/2)))]*...
 [d*tr - e*f*(exp(-t/f))*(-1+(exp(tr/f)))]);

creepFE=creep2(t);

%plot(creeptFE, creephFE);
plot(t,creepFE,'-o', 'Color', [0.25,0.87,0.81], 'linewidth', 1.5, 'MarkerFaceColor', [0.25,0.87,0.81], 'MarkerSize', 5.0 );

%Title and axis labels
title ('Creep portions and fitting' , 'Fontsize', 12);
xlabel ('Time (s)', 'Fontsize',12);
hold on;
ylabel ('h(t) (mm)', 'Fontsize', 12);
%leg=legend('experimental data', 'experimental fit', 'FE obtained creep', 'FE creep fit');
leg=legend('experimental data', 'FEfit');
set(leg, 'Location', 'SouthEast')

%SLS model
v=0.4995;

%Calculate the variation of the parameters 
Delta1=(a/d)
Delta2=(b/e)
Delta3=(c/f)

%Load the previous UMAT and recalculate the new material properties (SLS)
UMATanterior = UMATacqusition('UMAT.txt', 2, inf);
E_E_FE= (3*(1-2*v))*UMATanterior(1);
E_M_FE=(3*(1-2*v))*UMATanterior(3);
etaFE= UMATanterior(5);

CgFE=3/(2*E_E_FE);
CrFE=3/(2*(E_E_FE+E_M_FE));
beta=CgFE-CrFE;

%New bulk moduli
E_E=E_E_FE/Delta1;
E_0=(E_E_FE*(E_E_FE+E_M_FE))/((E_E_FE*Delta1)+(E_M_FE*(Delta1-Delta2)));
E_M = E_0-E_E;

%New time constant and viscosity
tauFE= (3*etaFE)/E_M_FE;
tau=(3*etaFE*Delta3)/E_M;
eta_t=tau*E_M;
eta_s=eta_t/3;

% New shear modulus
G_M=E_M/3;
G_E=E_E/3;
 
%New Bulk Modulus
K_M = E_M / (3*(1-2*v));
K_E = E_E / (3*(1-2*v));

%%Save the UMAT mechanical parameters
UMAT = fopen('UMAT.txt','w');
fprintf(UMAT, 'UMAT parameters (KE, GE KMe, GMe, GV)\n%12.8f\n%12.8f\n%12.8f\n%12.8f\n%12.8f\r\n', K_E, G_E, K_M, G_M, eta_s);
fclose(UMAT);

%Show the new parameters
type UMAT.txt

%Save FE creep data f
creepFE_data(:,1)=creeptFE;
creepFE_data(:,2)=creephFE;
dlmwrite('creepFE.txt',creepFE_data,'delimiter','\t','precision',5)

%!umat

 %Calculate the error between the experiemental data and the FE curve 
load pdmscreep.txt
creepx=pdmscreep(:,2);
fun= creepexp-creephFE;
errorsq=0.5*sum(fun.^2);
disp ('errorsq=');
disp (errorsq);
