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

% Objective function for the Optimization procedure
% This function corresponds to the holding and creep portion of the
% analytical solution only

function f= objectivecreep(z)
%where x is a vector 
%therefore D0= x(1), tau= x(3), D1= x(2)
global t ycreep tr k R weight;

%For the orgin of the functions see notes
%function for the creep portion (1)
p =  @(t)([(3*k)/(8*(R^(1/2)))]*...
 [z(1)*tr + z(2)*z(3)*(exp(-t/z(3)))*(1-(exp(tr/z(3))))]);
 
% p =  @(t)(z(1)-z(2)*exp(-t/z(3)));

%other (2) (Using Roylance)
% p =  @(t)[(3*k)/(8*(R^(1/2)))]*...
%  [tr*z(1)+tr*z(2)+(exp(-t/z(3)))*(1-exp(tr/z(3)))*z(2)*z(3)];

%f=weight.*( p(t)-ycreep);
f=p(t)-ycreep;
 end




