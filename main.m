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

%%This code is the main script for the iterative FE method 
%%Initial fit to provide the first guess
creepoptimization

%%Save the parameters and keep the history
History=[a b c K_E  G_E K_M G_M eta_s];
Parameter_history = fopen('Parameter_history.txt','w');
fprintf(Parameter_history, '%6.8f %6.8f %6.8f %6.8f %6.8f %6.8f %6.8f %6.8f', History);
fclose(Parameter_history);

%Save the plot in the appropriate folder
k='initial';
sample='bulk-';
ext='.fig';
file=strcat(sample,k, ext);
fileloc=fullfile('C:\', 'Work', 'automated', 'figures',file);
savefig(fileloc);

%%Call external programs
%update parameters in the user subroutine
!oldumat
system('lista.bat') %call ABAQUS and perform the analysis
%extract time vs displacement data (no visualization)
!C:\SIMULIA\Abaqus\Commands\abaqus cae noGUI=dataget.py 
Plotting 
%Save the indentation history files
dlmwrite('1indent.dat',FE,'delimiter','\t','precision',5)
Optim_loop2
savefig('C:\Work\automated\figures\bulkopti1.fig')
kw=1;
save ('kw.mat','kw');

%verify convergence
while errorsq>3.5e-08
    History=[d e f  K_E  G_E K_M G_M eta_s];
    Parameter_history=fopen('Parameter_history.txt','a');
    fprintf(Parameter_history, '\n%6.8f %6.8f %6.8f %6.8f %6.8f %6.8f %6.8f %6.8f', History);
    fclose(Parameter_history);
    resnor=fopen('resnorm.txt','a');
    fprintf(resnor, '\n%8.8f', errorsq);
    fclose(resnor);
    %%call external codes
    !umat
    !umat
    system('lista.bat')
    !C:\SIMULIA\Abaqus\Commands\abaqus cae noGUI=dataget.py 
    %%plot results
    Plotting
    load kw.mat
    ks=num2str(kw+1);
    indent='indent.dat';
    fileindent=strcat(ks,indent);
    dlmwrite(fileindent,FE,'delimiter','\t','precision',5)
    Optim_loop2
    load kw;
    ks=num2str(kw);
    Pplot='bulk-iter';
    fileopt=strcat(Pplot,ks);
    fileloc=fullfile('C:\', 'Work', 'automated', 'figures',fileopt);
    savefig(fileloc);
    kw=kw+1;
    save('kw.mat', 'kw');
    end
displ ('Convergence achieved')
displ ('Data and figures saved')
