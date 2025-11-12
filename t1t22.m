%===========================================================
%  THEORETICAL RELAXATION TIME ESTIMATION FOR DIRADICAL QUBIT
%===========================================================
clear; clc;
disp('=== DIRADICAL RELAXATION CALCULATION ===');

%-----------------------------------------------------------
% 1️⃣ Parameters (adjust these for your molecule)
%-----------------------------------------------------------
g = 2.005;                       % g-factor
A1 = -12.1446e6;                 % Hyperfine coupling [Hz]
A2 = -10.5097e6;                 % Hyperfine coupling [Hz]
r = 1.5e-9;                      % Distance between two spins [m]
lambda = 100 * 1.986e-23;        % Spin–orbit coupling (100 cm^-1 → J)
T = 100;                         % Temperature [K]
B0 = 0.35;                       % Magnetic field [T]
muB = 9.274e-24;                 % Bohr magneton [J/T]
h = 6.626e-34;                   % Planck constant [J·s]
kB = 1.381e-23;                  % Boltzmann constant [J/K]

%-----------------------------------------------------------
% 2️⃣ Energy splitting (Zeeman + hyperfine contribution)
%-----------------------------------------------------------
omega0 = g * muB * B0 / h;        % Zeeman frequency [Hz]
A_eff = mean([abs(A1), abs(A2)]); % Effective hyperfine strength [Hz]

fprintf('Zeeman frequency = %.2e Hz\n', omega0);
fprintf('Effective hyperfine coupling = %.2e Hz\n', A_eff);

%-----------------------------------------------------------
% 3️⃣ Theoretical relaxation models
%-----------------------------------------------------------
% Spin–lattice relaxation rate 1/T1 (Orbach + Raman + Direct)
Delta = 50 * 1.986e-23;  % Energy gap between ground & excited spin states (≈ 50 cm^-1)
C_Raman = 1e-8;          % Raman process constant (empirical)
C_Direct = 1e-12;        % Direct process constant
C_Orbach = 1e-3;         % Orbach process constant

R1 = C_Direct * omega0^3 * coth(h*omega0/(2*kB*T)) + ...
     C_Raman * T^9 + ...
     C_Orbach * exp(-Delta/(kB*T));

T1 = 1 / R1;

% Spin–spin relaxation time T2 (dipolar + spin–lattice contribution)
mu0 = 4*pi*1e-7;
gamma_e = 1.760859e11;  % gyromagnetic ratio of electron [rad/s/T]
B_dip = (mu0/(4*pi)) * (g*muB)^2 / (r^3);  % dipolar field [T]
R2 = 1/T1 + (gamma_e * B_dip)^2 * T1;      % simple Redfield-like expression
T2 = 1 / R2;

%-----------------------------------------------------------
% 4️⃣ Display results
%-----------------------------------------------------------
fprintf('\n=== THEORETICAL RESULTS ===\n');
fprintf('T = %.1f K\n', T);
fprintf('B0 = %.2f T\n', B0);
fprintf('r = %.2f nm\n', r*1e9);
fprintf('Spin–orbit constant = %.2e J\n', lambda);
fprintf('---------------------------------\n');
fprintf('T1 = %.3e s\n', T1);
fprintf('T2 = %.3e s\n', T2);

%-----------------------------------------------------------
% 5️⃣ Temperature dependence (optional)
%-----------------------------------------------------------
Temps = linspace(50, 400, 30);
T1_vals = zeros(size(Temps));
T2_vals = zeros(size(Temps));

for i = 1:length(Temps)
    T = Temps(i);
    R1 = C_Direct * omega0^3 * coth(h*omega0/(2*kB*T)) + ...
         C_Raman * T^9 + ...
         C_Orbach * exp(-Delta/(kB*T));
    T1_vals(i) = 1/R1;
    R2 = 1/T1_vals(i) + (gamma_e * B_dip)^2 * T1_vals(i);
    T2_vals(i) = 1/R2;
end

figure;
semilogy(Temps, T1_vals, 'b-o', 'LineWidth', 1.5, 'DisplayName', 'T1');
hold on;
semilogy(Temps, T2_vals, 'r-s', 'LineWidth', 1.5, 'DisplayName', 'T2');
xlabel('Temperature (K)');
ylabel('Relaxation Time (s)');
title('Temperature Dependence of T1 and T2');
legend show; grid on;

