clc; close all; clear all;

sub = 222;

Fs = 1000;
dt = 1/Fs;
T = 2;
N = Fs*T;
time = 0:dt:(N-1)*dt;

% Get path
current_path                    = pwd;
[path_main, ~, ~]               = fileparts(current_path);
path_results                    = [path_main,'\Closed-Loop_Spindle_Memory_Documents\Results\'];
path_adaptation                 = [path_results,'\Adaptation_Results\'];
path_experiment                 = [path_results,'\Experiment_Results\'];
path_sigma_peak                 = [path_adaptation,'\Staging Results\SigmaPeak\data\'];
path_pink_noise                 = [path_experiment,'\Stimulation Material\'];
path_sound_file                 = [path_experiment,'\Stimulation Material','\sub',num2str(sub),'\sound\'];
path_sound_fig                  = [path_experiment,'\Stimulation Material','\sub',num2str(sub),'\figure\'];

file_name_sigma_peak            = dir([path_sigma_peak,'\sub',num2str(sub),'*.mat']);

% Add functionss' path
functionPath                    = fullfile(path_main,'functions'); 
addpath(genpath(functionPath));

% Load data
load([path_sigma_peak, file_name_sigma_peak.name])
[pink_noise,Fs] = audioread([path_pink_noise, 'Pink_noise.wav']);

% Genarate folder
mkdir(path_sound_file);
mkdir(path_sound_fig);

%% Rhythmic Sound 
filename = [path_sound_file,'Rhythmic_Sound.wav'];
rhythmic_sound = sound_gene_rhythmic(sigma_peak, Fs, T, pink_noise, filename);

% Plot Modulated Signal
tit = 'Rhythmic Sound';
xlab_sound = 'Time [s]';
ylab_sound = 'Amplitude';
filename = [path_sound_fig,'Rhythmic_Sound.png'];
plot_sound(rhythmic_sound, time, tit, xlab_sound, ylab_sound, filename)

% Plot Frequency Spectrum of Modulated Signal
xlab_fre = 'Frequncy [Hz]';
ylab_fre = 'Amplitude';
tit = [path_sound_fig,'Rhythmic Sound BaseSigmaPeak = ', num2str(sigma_peak), 'Hz'];;
filename = [path_sound_fig,'Rhythmic_Sound_Frequency.png'];
plot_sound_frespectrum(rhythmic_sound, Fs, tit, xlab_fre, ylab_fre, filename)
