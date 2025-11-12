%% Molecular Qubit Assessment using EasySpin
clc; clear; close all;

%% --- 0. Load EasySpin ---
addpath('/Users/shreyasat/Downloads/easyspin-6.0.11/easyspin');
savepath  % optional, saves path for future sessions

%% --- 1. Define the Spin System (example: diradical) ---
Sys.S = [1/2, 1/2];       % Two electron spins
J_cm = 2.81;              % Exchange in cm^-1
J_MHz = J_cm * 29979.2458; % Convert cm^-1 -> MHz
Sys.J = -2*J_MHz;         % EasySpin convention (MHz)

Sys.S = [1/2, 1/2];       % two spins
Sys.g = [2.0023, 2.0023, 2.0023;
         2.0023, 2.0023, 2.0023];  % 2x3
Sys.J = -2*J_MHz;         % exchange (MHz)
          % linewidth (mT)

% Optional hyperfine (replace with your molecule if known)
% Sys.A = [10, 10, 10]; % MHz

% Relaxation estimates (coherence proxies)
Sys.lwpp = 0.1;    % linewidth in mT, smaller -> longer T2

%% --- 2. Define Experiment Parameters ---
Exp.mwFreq = 9.5;      % GHz, X-band
Exp.Range = [300 400]; % mT
Exp.Temperature = 298; % K

Opt.Verbosity = 1;

%% --- 3. Simulate EPR Spectrum (Criterion 1 & 5) ---
fprintf('\nSimulating EPR spectrum...\n');
[B, spc] = pepper(Sys, Exp, Opt);

figure(1);
plot(B, spc, 'LineWidth', 1.5);
xlabel('Magnetic Field (mT)');
ylabel('Intensity (arb. units)');
title('EPR Spectrum: Energy levels & transitions');
grid on;

%% --- 4. Energy Level Diagram (Two-spin system) ---
fprintf('\nCalculating energy levels...\n');
% Basis: |↑↑>, |↑↓>, |↓↑>, |↓↓>
J_GHz = J_MHz / 1000; % GHz
g = 2.0023; muB = 9.274e-24; h = 6.626e-34;
B0 = 350; % mT
w0 = g*muB*B0*1e-3/h*1e-9; % GHz

H = zeros(4,4);
H(1,1) = w0; H(4,4) = -w0;
H(2,2) = J_GHz/4; H(3,3) = J_GHz/4;
H(2,3) = J_GHz/2; H(3,2) = J_GHz/2;

[eigvec, eigval] = eig(H);
figure(2); clf;
plot(1:4, diag(eigval), 'o', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('State index'); ylabel('Energy (GHz)');
title('Two-spin Energy Levels');
grid on;

%% --- 5. Thermal Populations (Criterion 3: initialization) ---
fprintf('\nCalculating thermal populations...\n');
kT_cm = 0.695 * Exp.Temperature; % cm^-1
P_triplet = 3*exp(J_cm/(2*kT_cm));
P_singlet = exp(-3*J_cm/(2*kT_cm));
Z = P_triplet + P_singlet;
P_triplet_norm = P_triplet / Z;
P_singlet_norm = P_singlet / Z;

fprintf('Triplet population: %.3f\n', P_triplet_norm);
fprintf('Singlet population: %.3f\n', P_singlet_norm);

%% --- 6. Time Evolution / Rabi Simulation (Criterion 5: control) ---
fprintf('\nSimulating spin dynamics (Rabi oscillations)...\n');
rho0 = [1 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0]; % |↑↑>
t = linspace(0, 100, 1000); % ns

U = @(t) expm(-1i*2*pi*H*t); % evolution operator
S1z = 0.5 * [1 0 0 0; 0 1 0 0; 0 0 -1 0; 0 0 0 -1];
S2z = 0.5 * [1 0 0 0; 0 -1 0 0; 0 0 1 0; 0 0 0 -1];

S1z_expect = zeros(size(t));
S2z_expect = zeros(size(t));

for i=1:length(t)
    rho_t = U(t(i)) * rho0 * U(t(i))';
    S1z_expect(i) = real(trace(rho_t*S1z));
    S2z_expect(i) = real(trace(rho_t*S2z));
end

figure(3); clf;
plot(t, S1z_expect, 'b', 'LineWidth', 2); hold on;
plot(t, S2z_expect, 'r--', 'LineWidth', 2);
xlabel('Time (ns)'); ylabel('<S_z>');
title('Spin Dynamics / Rabi-like Evolution');
legend('Spin 1','Spin 2'); grid on;

%% --- 7. Angular Dependence (robustness) ---
Ori = [0,0; 45,0; 90,0]; % [phi,theta] degrees
figure(4); clf;
colors = ['b','r','g'];
for i=1:size(Ori,1)
    Exp.SampleFrame = [Ori(i,:) 0];
    [B, spc] = pepper(Sys, Exp, Opt);
    plot(B, spc + (i-1)*0.2, colors(i), 'LineWidth', 1.5); hold on;
end
xlabel('Magnetic Field (mT)'); ylabel('Intensity (arb. units)');
title('Angular Dependence of EPR Spectrum'); grid on;
legend('0°','45°','90°');

fprintf('\nMolecular qubit assessment complete!\n');
