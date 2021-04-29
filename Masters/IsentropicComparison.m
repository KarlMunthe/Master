clear

%LOL THIS ISNT ISENTROPIC

%Gas properties and Initial and Boundary data 
mu = 1.85e-5;
c_v = 717;
c_p = 1004;
R = 287;
K = 0.026;
rho = @(x) 2e-04*(sin(2*pi*x))+1.2;

%Grid space and time
m = 20;

x_end = 1;
t_end = 120;

h=1/(m-1); % grid size.
k = 1e-5; % time step

x = 0:h:x_end;    %individual space points on the grid
t = 0:k:t_end;    %individual time points on the grid

%Eulerian viscosity coefficient alpha can equal 1 or 4/3
alpha1 = 1;
alpha2 = 4/3;

[~, ~, ~, D0] = PeriodicD0(m, h);
[~, ~, ~, D2] = PeriodicD2(m, h);

%EP1 = E(m, x, t, k, mu, alpha1, c_v, c_p, R, D0, rho);

%EP2 = E(m, x, t, k, mu, alpha2, c_v, c_p, R, D0, rho);

NSP = NS(m, x, t, k, mu, c_v, c_p, R, K, D0, D2, rho);

%NSIP = NSI(m, x, t, k, mu, c_v, c_p, D0, D2, rho);

%EIP = EI(m, x, t, k, mu, alpha1, c_v, c_p, D0, rho);

%{
plot(t, NSP)
hold on
plot(t, NSIP)
legend('Anisentropic Navier-Stokes', 'Isentropic Navier-Stokes')
xlabel('t [sec]')
ylabel('Pressure')
title('Anisentropic (not isentropic) Navier-Stokes vs. Isentropic Navier-Stokes, 8th order operators')
%}

%{
c = 343;
g = 1/(2*c^3.*NSP)*(4/3*mu+K*(1/c_v-1/c_p));
a = exp(-g.*t);
%}


te=t(1:10:end);

plot(te,NSP)
%hold on
%plot(t,a)
xlabel('t [sec]')
ylabel('Pressure')
title('Navier-Stokes')