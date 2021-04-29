clear

addpath('/Users/karlmunthe/Documents/UiB/UiB Master Oppgave/Code/Difference Operators')

%Gas properties and Initial and Boundary data 
%Helium values
mu = 1.87e-5;   %coefficient of viscosity
c_V = 3157;     %heat capacity at constant volume
c_p = 5240;     %heat capacity at constant pressure
R = 2077.1;     %gas constant
kappa = 0.1357;     %thermal conductivity 
rho_0 = 0.1786;  %background density at STP
rho = @(x) rho_0 + 2e-04*(sin(2*pi*x));   %reynolds decomposed pressure ion

gamma = c_p/c_V;
p_const = 10^5/(rho_0^gamma);
p_0 = p_const*rho_0^gamma;
nu_0 = mu/rho_0;
T_0 = p_0/(R*rho_0);
c = sqrt(gamma*p_0/rho_0);    %speed of sound
omega = 2*pi;
eta = 0;


PropCoeffN_S = omega^2/(2*rho_0)*((4/3*mu + eta) + (kappa/c_V)*(1/c_V-1/c_p)); %page 301 in Landou & Lipschitz
PropCoeffN_S_S = omega^2/(2*rho_0)*(mu + c_V*mu*(gamma-1)*(T_0/c^2 + 1/c_p));

m = 6;

k = 1e-6; % time step

x_end = 1;
t_end = 100;

%x = 0:h:x_end;    %individual space points on the grid

%Eulerian viscosity coefficient alpha can equal 1 or 4/3
alpha = 1;
alpha2 = 4/3;

%Creates Pade scheme
%{
Dp = diag(-ones(m-1, 1), 0) + diag(ones(m-2, 1), 1);
Dp(end, 1) = 1;
Dp = Dp/h;
Dm = diag(ones(m-1, 1), 0) + diag(-ones(m-2, 1), -1);
Dm(1, end) = -1;
Dm = Dm/h;
I = diag(ones(m-1,1));

%REMEMBER TO USE SECOND ORDER, O(2), DIFFERENCE OPERATORS WHEN USING PADE
%SCHEMES, THE FIRST SIMPLESt OF THE ONES IN THE PERIODICD0/2 FUNCTIONS
PD1 = (I + h^2*Dp*Dm/6 - h^4*(Dp*Dm)^2/30 + h^6*(Dp*Dm)^3/140);
PD2 = (I + h^2*Dp*Dm/12 - h^4*(Dp*Dm)^2/90 + h^6*(Dp*Dm)^3/560);
%}

%Pade schemes
%{
%[NS_Work] = Pade_NS(m, x, t_end, k, mu, c_v, c_p, R, K, D0, D2, PD1, PD2, rho);

%[NSS_Work] = Pade_NSS(m, x, t_end, k, mu, alpha, c_v, c_p, R, D0, PD1, PD2, rho);
%}

%Normal difference schemes
%{
x = linspace(0, x_end, m);    %individual space points on the grid
h = x(2) - x(1);

CFL = k/(h^2);

[~, ~, ~, Q1] = PeriodicD0(m, h);
[~, ~, ~, Q2] = PeriodicD2(m, h);

[NS_Work] = NS(m, x, t_end, k, c_p, c_V, kappa, mu, rho, Q1, Q2);
%[NS_Work] = NS_feil(m, x, t_end, k, mu, c_V, c_p, R, kappa, Q1, Q2, rho);


[NSS_Work] = NSS(m, x, t_end, k, c_p, c_V, mu, rho, Q1);
%[NSS_Work] = E2(m, x, t_end, k, mu, alpha, c_V, c_p, R, Q1, rho);
%}

%Spectral difference schemes

h = x_end/m;    %individual space points on the grid
x = h*(1:m);

s = 2*pi;

CFL = k/(h^2);

Q1 = SpectralD0(m, s);
Q2 = SpectralD2(m, s);

%[NS_Work] = SpectralNS(m, x, t_end, k, c_p, c_V, kappa, mu, rho, Q1, Q2);
[NSS_Work] = SpectralNSS(m, x, t_end, k, c_p, c_V, mu, rho, Q1);

%{
[Q1,~,~,~] = PeriodicD0(m,h);
[Q2,~,~,~] = PeriodicD2(m,h);

[NSS_Work2] = SpectralNSS(m, x, t_end, k, c_p, c_V, mu, rho, Q1);

[~,Q1,~,~] = PeriodicD0(m,h);
[~,Q2,~,~] = PeriodicD2(m,h);

[NSS_Work3] = SpectralNSS(m, x, t_end, k, c_p, c_V, mu, rho, Q1);

[~,~,Q1,~] = PeriodicD0(m,h);
[~,~,Q2,~] = PeriodicD2(m,h);

[NSS_Work4] = SpectralNSS(m, x, t_end, k, c_p, c_V, mu, rho, Q1);

[~,~,~,Q1] = PeriodicD0(m,h);
[~,~,~,~] = PeriodicD2(m,h);

[NSS_Work5] = SpectralNSS(m, x, t_end, k, c_p, c_V, mu, rho, Q1);
%[NS_Work] = NS_feil(m, x, t_end, k, mu, c_V, c_p, R, kappa, Q1, Q2, rho)
%}
x = [0, x];
time = linspace(0, t_end, size(NSS_Work,2));

hold on
plot(time, NSS_Work(1,:))
f1 = figure;
plot(time, NSS_Work(1,:))
%f2 = figure;
%mesh(x, time, NS_Work')

[NSS_Work] = SpectralNSS(m, x, t_end, k, c_p, c_V, mu, rho, Q1);

%[NSS_Work] = SpectralNSS(m, x, t_end, k, c_p, c_V, mu, rho, Q1);
%[NSS_Work] = E2(m, x, t_end, k, mu, alpha, c_V, c_p, R, Q1, rho);
%}

%Normal differnce schemes for isentropic (constant entropy)
%{
NSIP = NSI(m, x, t, k, mu, c_v, c_p, D0, D2, rho);

EIP = EI(m, x, t, k, mu, alpha1, c_v, c_p, D0, rho);
%}

%time-step convergence error thing
%{
NS1 = NS(m, t_end, k, mu, c_v, c_p, R, K, rho);
NS2 = NS(2*m-1, t_end, k, mu, c_v, c_p, R, K, rho);
NS2vals = reshape(NS2(1:end-1), 2, []);
NS2vals = [NS2vals(1,:), NS2(end)];


E2 = E(2*m-1, t_end, k, mu, alpha1, c_v, c_p, R, rho);
E2vals = reshape(E2(1:end-1), 2, []);
E2vals = [E2vals(1,:), E2(end)];
E1 = E(m, t_end, k, mu, alpha1, c_v, c_p, R, rho);

E_error = norm(E2vals-E1);
NS_error = norm(NS2vals-NS1);
%}

%l^2 convergence with spectral schemes
%{
N = 1;

RHO_p_list = zeros(1, N-1);
MOM_p_list = zeros(1, N-1);
ENE_p_list = zeros(1, N-1);

RHO_list = zeros(1, N);
MOM_list = zeros(1, N);
ENE_list = zeros(1, N);

h_list = zeros(1, N);
CFL_list = zeros(1, N);

M = 40;
%X = linspace(0, x_end, M);    %individual space points on the grid
%H= X(2) - X(1);


H = 2*pi/M;    %individual space points on the grid
X = H*(1:M);

CFL = k/(H^2);

Q1 = SpectralD0(M, H);
Q2 = SpectralD2(M, H);

%Q1 = PeriodicD0(M, H);
%Q2 = PeriodicD2(M, H);

[RHO_sol, MOM_sol, ENE_sol] = SpectralNS(M, X, t_end, k, c_p, c_V, kappa, mu, rho, Q1, Q2);

for i = 1:N
    
    h = 2*pi/m;    %individual space points on the grid
    x = h*(1:m);
    
    %x = linspace(0, x_end, m);
    %h = x(2)-x(1)
    %CFL = k/(h^2);

    Q1 = SpectralD0(m, h);
    Q2 = SpectralD2(m, h);
    
    %Q1 = PeriodicD0(m, h);
    %Q2 = PeriodicD2(m, h);

    CFL = k/(h^2);
    CFL_list(i) = CFL;

    [RHO, MOM, ENE] = SpectralNS(m, x, t_end, k, c_p, c_V, kappa, mu, rho, Q1, Q2);
    rho_error = RHO - RHO_sol(1:2^(N-i+2):end);
    rho_error = sqrt(h*(rho_error'*rho_error));
    RHO_list(i) = rho_error;
    
    mom_error = MOM - MOM_sol(1:2^(N-i+2):end);
    mom_error = sqrt(h*(mom_error'*mom_error));
    MOM_list(i) = mom_error;
    
    ene_error = ENE - ENE_sol(1:2^(N-i+2):end);
    ene_error = sqrt(h*(ene_error'*ene_error));
    ENE_list(i) = ene_error;
    
    m = 2*m;
    
end


%{
for i = 1:N-1
    RHO_p_list(i) = log(RHO_list(i+1)/RHO_list(i))/log(h_list(i+1)/h_list(i));
end
RHO_p_list
for i = 1:N-1
    MOM_p_list(i) = log(MOM_list(i+1)/MOM_list(i))/log(h_list(i+1)/h_list(i));
end
MOM_p_list
for i = 1:N-1
    ENE_p_list(i) = log(ENE_list(i+1)/ENE_list(i))/log(h_list(i+1)/h_list(i));
end
ENE_p_list
%}
RHO_list
MOM_list
ENE_list
%}

%l^2 convergence with FD schemes
%{
N = 1;

RHO_p_list = zeros(1, N-1);
MOM_p_list = zeros(1, N-1);
ENE_p_list = zeros(1, N-1);

RHO_list = zeros(1, N);
MOM_list = zeros(1, N);
ENE_list = zeros(1, N);

h_list = zeros(1, N);
CFL_list = zeros(1, N);

M = 41;
X = linspace(0, x_end, M);    %individual space points on the grid
H= X(2) - X(1);

CFL = k/(H^2);

[~, ~, ~, Q1] = PeriodicD0(M, H);
[~, ~, ~, Q2] = PeriodicD2(M, H);

[RHO_sol, MOM_sol, ENE_sol] = NS(M, X, t_end, k, c_p, c_V, kappa, mu, rho, Q1, Q2);

for i = 1:N
    
    x = linspace(0, x_end, m);
    
    h = x(2)-x(1);
    h_list(i) = h;
    
    CFL = k/(h^2);

    [~, ~, ~, Q1] = PeriodicD0(m, h);
    [~, ~, ~, Q2] = PeriodicD2(m, h);

    CFL = k/(h^2);
    CFL_list(i) = CFL;

    [RHO, MOM, ENE] = NS(m, x, t_end, k, c_p, c_V, kappa, mu, rho, Q1, Q2);
    
    rho_error = RHO - RHO_sol(1:2^(N-i+2):end);
    rho_error = sqrt(h*(rho_error'*rho_error));
    RHO_list(i) = rho_error;
    
    mom_error = MOM - MOM_sol(1:2^(N-i+2):end);
    mom_error = sqrt(h*(mom_error'*mom_error));
    MOM_list(i) = mom_error;
    
    ene_error = ENE - ENE_sol(1:2^(N-i+2):end);
    ene_error = sqrt(h*(ene_error'*ene_error));
    ENE_list(i) = ene_error;
    
    m = 2*m-1;
    
end


%{
for i = 1:N-1
    RHO_p_list(i) = log(RHO_list(i+1)/RHO_list(i))/log(h_list(i+1)/h_list(i));
end
RHO_p_list
for i = 1:N-1
    MOM_p_list(i) = log(MOM_list(i+1)/MOM_list(i))/log(h_list(i+1)/h_list(i));
end
MOM_p_list
for i = 1:N-1
    ENE_p_list(i) = log(ENE_list(i+1)/ENE_list(i))/log(h_list(i+1)/h_list(i));
end
ENE_p_list
%}
RHO_list
MOM_list
ENE_list
%}

%Round off error check
%{
x = linspace(0, x_end, m);    %individual space points on the grid
h = x(2) - x(1);

CFL = k/(h^2);

[~, ~, ~, Q1] = PeriodicD0(m, h);
[~, ~, ~, Q2] = PeriodicD2(m, h);

iter = 2;

NS_Work = zeros(length(x),iter);
NSS_Work = zeros(length(x),iter);

for i = 1:iter
    Navier_Stokes = NS(m, x, t_end, k, c_p, c_V, kappa, mu, rho, Q1, Q2);
    NS_Work(:, i) = Navier_Stokes(:, end-1);
    Navier_Stokes_Svard = NSS(m, x, t_end, k, c_p, c_V, mu, rho, Q1);
    NSS_Work(:, i) = Navier_Stokes_Svard(:, end-1);
    k = 2*k;
end
%}

%mesh plot
%{
mesh(x,t, NSIP')
xlabel('t [sec]')
ylabel('Pressure')
title('Anisentropic Navier-Stokes')
%}

%Individual plot
%{
t = linspace(0,t_end,ceil(ceil(t_end/k)/100)+1);
plot(t, NS)
xlabel('t [sec]')
ylabel('Pressure')
title('Isentropic Navier-Stokes, 8th order operators')
%}

%Comparrison plots

%Comparison of decay of pressure
%{
%Getting max pressure amplitude data from Navier-Stokes-Svärd 
N_S_S = nonzeros(N_S_S);
N_S_S = N_S_S(1:round(length(N_S_S),-1));
N_S_S_plot = reshape(N_S_S, t_end, []);
N_S_S_plot = N_S_S_plot(1,:);
N_S_S_flux_plot = N_S_S_plot - p_0;         %subtracting background pressure to only show change in pressure

%Getting max pressure amplitude data from Navier-Stokes
N_S = nonzeros(N_S);
N_S = N_S(1:round(length(N_S),-1));
N_S_plot = reshape(N_S, t_end, []);
N_S_plot = N_S_plot(1,:);
N_S_flux_plot = N_S_plot - p_0;       %subtracting background pressure to only show change in pressure


tN_S_S = linspace(0,t_end,length(N_S_S_flux_plot));
tN_S = linspace(0, t_end, length(N_S_flux_plot));

%finding exponential coeficients
N_S_S_amp = max(reshape(N_S_S, [], t_end));
N_S_S_amp_flux = N_S_S_amp - p_0;
N_S_amp = max(reshape(N_S, [], t_end));
N_S_amp_flux = N_S_amp - p_0;
t2 = linspace(0,t_end,length(N_S_S_amp_flux)); %E_amp_flux and NS_amp_flux are same length

%least squares approximation to find y = exp(ax+b) for Navier-Stokes-Svärd
logN_S_S_amp_flux = log(N_S_S_amp_flux);
linearN_S_S_amp_flux = polyfit(t2, logN_S_S_amp_flux, 1);

%function giving least squares approximation of the data for
%Navier-Stokes-Svärd
LeastSquared_N_S_S = exp(linearN_S_S_amp_flux(2))*exp(linearN_S_S_amp_flux(1)*t2);

%least squares approximation to find y = exp(ax + b) for Navier-Stokes
logN_S_amp_flux = log(N_S_amp_flux);
linearN_S_amp_flux = polyfit(t2, logN_S_amp_flux, 1);

%function giving least squares approximation of the data for Navier-Stokes
LeastSquared_N_S = exp(linearN_S_amp_flux(2))*exp(linearN_S_amp_flux(1)*t2);

%initial condition
decayAmp = (LeastSquared_N_S_S(1) + LeastSquared_N_S(1))/2;

%Theoretical expectation for decay of Navier-Stokes sound waves
decayN_S = decayAmp*exp(-PropCoeffNS*t2);

%Theoretical expectation for decay pf Navier-Stokes-Svärd sound waves
decayN_S_S = decayAmp*exp(-PropCoeffNSS*t2);

%plots
tiledlayout(2,1)
nexttile
hold on
plot(tN_S, N_S_flux_plot);% 'color', 'blue')
plot(t2, LeastSquared_N_S, 'color', 'cyan')
plot(tN_S_S, N_S_S_flux_plot)%, 'color', 'yellow')
plot(t2, LeastSquared_N_S_S, 'color', 'red')
legend('Navier-Stokes', 'Navier-Stokes best fit', 'Eulerian', 'Eulerian best fit')
xlabel('t [sec]')
ylabel('Pressure')
title('Navier-Stokes vs. Eulerian, step size = 1e-6, ')
grid on

nexttile
hold on
plot(t2, LeastSquared_N_S, 'color', 'cyan')
plot(t2, decayN_S);
plot(t2, LeastSquared_N_S_S, 'color', 'red')
plot(t2, decayN_S_S);
title('Navier-Stokes and Eulerian model with amplitude approximation')
legend('Navier-Stokes', 'Navier-Stokes approximation', 'Navier-Stokes-Svärd', 'Navier-Stokes-Svärd approximation')
xlabel('t [sec]')
ylabel('Pressure')
grid on

%}


%Comparison of decay of energy
x = [0, x];
%Getting max work amplitude data from Navier-Stokes-Svärd 
int_NSS_Work = trapz(x, NSS_Work);
int_NSS_Work = nonzeros(int_NSS_Work);
int_NSS_Work = int_NSS_Work(1:round(length(int_NSS_Work), -1));

int_NSS_Work_plot = reshape(int_NSS_Work, [], t_end);
int_NSS_Work_plot = max(int_NSS_Work_plot);
logint_NSS_Work_plot = log(int_NSS_Work_plot);
t2NSS = linspace(0, t_end, length(logint_NSS_Work_plot));
Linear_NSS_Work = polyfit(t2NSS, logint_NSS_Work_plot, 1);
LeastSquared_NSS_Work = exp(Linear_NSS_Work(2))*exp(Linear_NSS_Work(1)*t2NSS);
%}
%Getting max heat amplitude data from Navier-Stokes-Svärd
%{
NSS_Heat = trapz(x, N_S_SHeat);
NSS_Heat = nonzeros(NSS_Heat);
NSS_Heat = NSS_Heat(1:round(length(NSS_Heat),-1));
NSS_Heat_plot = reshape(NSS_Heat, [], t_end);
NSS_Heat_plot = min(NSS_Heat_plot);
log_NSS_Heat_plot = log(NSS_Heat_plot);
t2NSS = linspace(0, t_end, length(log_NSS_Heat_plot));
Linear_NSS_Heat = polyfit(t2NSS, log_NSS_Heat_plot, 1);
LeastSquared_NSS_Heat = exp(Linear_NSS_Heat(2))*exp(Linear_NSS_Heat(1)*t2NSS);
%}
%Getting max work amplitude data from Navier-Stokes
int_NS_Work = trapz(x, NS_Work);
int_NS_Work = nonzeros(int_NS_Work);
int_NS_Work = int_NS_Work(1:round(length(int_NS_Work), -1));

int_NS_Work_plot = reshape(int_NS_Work, [], t_end);
int_NS_Work_plot = max(int_NS_Work_plot);
logint_NS_Work_plot = log(int_NS_Work_plot);
t2NS = linspace(0, t_end, length(logint_NS_Work_plot));
Linear_NS_Work = polyfit(t2NS, logint_NS_Work_plot, 1);
LeastSquared_NS_Work = exp(Linear_NS_Work(2))*exp(Linear_NS_Work(1)*t2NS);

%initial condition
%EnergyDecayAmp = (LeastSquared_NSS_Work(1) + LeastSquared_NS_Work(1))/2;

%Theoretical expectation for decay of Navier-Stokes sound waves
EnergyDecay_NS = LeastSquared_NS_Work(1)*exp(-2*PropCoeffN_S*t2NS);

%Theoretical expectation for decay pf Navier-Stokes-Svärd sound waves
EnergyDecay_NSS = LeastSquared_NSS_Work(1)*exp(-2*PropCoeffN_S_S*t2NSS);

t2 = linspace(0, t_end, length(int_NSS_Work));

%plots
tiledlayout(2,1)
nexttile
hold on
plot(t2, int_NS_Work);% 'color', 'blue')
plot(t2NS, LeastSquared_NS_Work, 'color', 'cyan')
plot(t2, int_NSS_Work)%, 'color', 'yellow')
plot(t2NSS, LeastSquared_NSS_Work, 'color', 'red')
legend('NS', 'NS least squared', 'NSS', 'NSS least squared')
xlabel('t [sec]')
ylabel('Work')
title('NS vs. NSS, step size = 1e-6, ')
grid on

nexttile
hold on
plot(t2NS, LeastSquared_NS_Work, 'color', 'cyan')
plot(t2NS, EnergyDecay_NS);
plot(t2NSS, LeastSquared_NSS_Work, 'color', 'red')
plot(t2NSS, EnergyDecay_NSS);
title('NS vs. NSS with Theoretical decay')
legend('NS', 'NS theoretical', 'NSS', 'NSS theoretical')
xlabel('t [sec]')
ylabel('Work')
grid on
%}

%change in frequency
%{
t_freq = linspace(0, t_end, length(E));
freq_dataE = [];
freq_indexE = [];
for i = 2:length(E)
    if E(i-1) > p_0 && E(i) < p_0 || E(i-1) < p_0 && E(i) > p_0
        freq_dataE = [freq_dataE, (E(i)+E(i-1))/2];
        freq_indexE = [freq_indexE, t_freq(i)];
    end
end

freq_dataNS = [];
freq_indexNS = [];
for i = 2:length(NS)
    if NS(i-1) > p_0 && NS(i) < p_0 || NS(i-1) < p_0 && NS(i) > p_0
        freq_dataNS = [freq_dataNS, (NS(i)+NS(i-1))/2];
        freq_indexNS = [freq_indexNS, i];
    end
end
        

%{

%exponential approximation values
%gamma = c_p/c_v;
%background_pressure = rho_bar^gamma;
%initial_amplitude = (rho_bar + 2e-04)^gamma - background_pressure;

E2_amplitude = E2(1) - background_pressure;
slope_E2 = log((E2(end)-background_pressure)/(E2_amplitude*background_pressure))/(tE2(end)-tE2(1));

NS2_amplitude = NS(1) - background_pressure;
slope_NS2 = log((NS2(end)-background_pressure)/(NS2_amplitude*background_pressure))/(tNS2(end)-tNS2(1));
%slope_E2 = log(E2(end)/E2(1))/(tE2(end)-tE2(1));
%slope_NS2 = log(NS2(end)/NS2(1))/(tNS2(end)-tNS2(1));
f = initial_amplitude*exp(slope_E2*tE2) + background_pressure;
g = initial_amplitude*exp(slope_NS2*tNS2) + background_pressure;
nexttile
hold on
plot(tNS2, NS2)
plot(tNS2,g)
plot(tE2, E2)
plot(tE2,f)
%semilogy(tNS2, NS2)
%semilogy(tE2, E2)
%}
%}

%}

%Model plot with decay
%{
decay = EP1(1)*exp(-PropCoeff*t);

t = t(1:100:end);
EP1 = EP1(1:100:end);
plot(t,EP1)
hold on
plot(t,decay)
%}

%Tiled plots
%{
tiledlayout(2,1)
nexttile
plot(t,NSP)
xlabel('t [sec]')
ylabel('Pressure')
title('Navier-Stokes at x = 1/4')

nexttile
plot(t,NSP2)
xlabel('t [sec]')
ylabel('Pressure')
title('Navier-Stokes at x = 3/4')
%}