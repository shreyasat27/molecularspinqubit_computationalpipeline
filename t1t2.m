%% Theoretical T1 and T2 estimation for a diradical
clc; clear; close all;

%% --- 1. Input parameters ---
g = 2.005;                 % electron g-factor
A1 = -12.1446e6;           % Hz (converted from MHz)
A2 = -10.5097e6;           % Hz
r = 1.5e-9;                % m, distance between spins (1.5 nm)
lambda = 100;               % spin-orbit constant, cm^-1 (assumed)
T = 100;                    % Temperature in K (room temperature)
B0 = 0.01;                  % Tesla, small field

muB = 9.274e-24;            % Bohr magneton, J/T
h = 6.626e-34;              % Planck constant, J*s
kB = 1.38064852e-23;        % Boltzmann constant, J/K
gamma_e = 1.760859e11;      % rad/s/T, electron gyromagnetic ratio

%% --- 2. Zeeman energy ---
omega0 = gamma_e * B0;       % rad/s
E_z = h * omega0;            % energy splitting, J

%% --- 3. Estimate T1 (spin-lattice relaxation) ---
% Simplified direct process formula for electron spins:
% 1/T1 ~ (lambda^2) * (kB*T) * omega0^3 (very rough estimate)
% Constants absorbed into prefactor
lambda_J = lambda * 1.986e-23; % convert cm^-1 -> J
prefactor_T1 = 1e-5;            % adjustable scaling factor
T1 = 1 / (prefactor_T1 * lambda_J^2 * kB * T * omega0^3); % s

%% --- 4. Estimate T2 (decoherence time) ---
% Contributions: dipolar + hyperfine
% Dipolar coupling: 1/T2_dip ~ (mu0/4pi) * (gamma_e^2 * hbar) / r^3
mu0 = 4*pi*1e-7;  % N/A^2
T2_dip = r^3 / (mu0/(4*pi) * gamma_e^2 * hbar); % s, rough

% Hyperfine contribution
T2_hf = h / (abs(A1) + abs(A2)); % s, rough estimate

% Combine T2 contributions
T2 = 1 / (1/T2_dip + 1/T2_hf);

%% --- 5. Display results ---
fprintf('Estimated T1: %.3e s\n', T1);
fprintf('Estimated T2: %.3e s\n', T2);

