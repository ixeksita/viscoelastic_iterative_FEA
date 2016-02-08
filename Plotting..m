close all;
clear all;

%% Experimental data
load pdms2.dat
time= pdms2(:,1);
h=pdms2(:,2);
plot(time, h, 'linewidth',1.5)

%% FE data
hold on
[timeFE,displFE] = importFE('FE.dat',2, 445);
% load FE.dat
% timeFE= FE(:,1);
% displFE= FE(:,2);
plot(timeFE,displFE,'-.', 'Color', [0.25,0.87,0.81], 'linewidth', 2.5);
FE(:,1)=timeFE;
FE(:,2)=displFE;
dlmwrite('FE.dat',FE,'delimiter','\t','precision',5)

%%
%Title and axis labels
title ('Optimized vs experimental data (non-scaled data)', 'Fontsize', 12);
xlabel ('Time (s)', 'Fontsize',12);
ylabel ('Displacement(mm)', 'Fontsize', 12);
leg=legend('Experimental data', 'FE data');
set(leg, 'Location' ,'SouthEast')

 
