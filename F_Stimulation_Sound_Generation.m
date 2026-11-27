clc; close all; clear all;

sub = 217;

Fs = 1000;
dt = 1/Fs;
T = 2;
N = Fs*T;
time = 0:dt:(N-1)*dt;

% Get path
current_path                    = pwd;
[path_main, ~, ~]               = fileparts(current_path);
path_adaptation                 = [path_main,'\Results\Adaptation_Results\'];
path_experiment                 = [path_main,'\Results\Experiment_Results\'];
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
mkdir(path_sound_file,'Arhythmic_Sound.wav\');
mkdir(path_sound_fig,'Arhythmic_Sound.wav\');

% Genarate pink_noise
% pink_noise = pinknoise(N);
% pink_noise = pink_noise./max(pink_noise);

% filename = [path_pink_noise,'Pink_noise.wav'];
% audiowrite(filename, pink_noise, Fs);
% sound(pink_noise, Fs)

%% Ampiltude Modulate Sound (Based on Sigma Peak)
filename = [path_sound_file,'Amplitude_Modulated_Sound_BaseSigmaPeak.wav'];
modu_sound = sound_gene_amplitude_modulated(sigma_peak, Fs, time, N, pink_noise, filename);

% Plot Frequency Spectrum of Modulated Signal
tit = ['Amplitude Modulated Sound BaseSigmaPeak = ', num2str(sigma_peak), 'Hz'];
xlab_fre = 'Frequncy [Hz]';
ylab_fre = 'Amplitude';
filename = [path_sound_fig,'Amplitude_Modulated_Sound_BaseSigmaPeak_Frequency.png'];
plot_sound_frespectrum(modu_sound, Fs, tit, xlab_fre, ylab_fre, filename)

% Plot Modulated Signal
tit = 'Amplitude Modulated Sound BaseSigmaPeak';
xlab_sound = 'Time [s]';
ylab_sound = 'Amplitude';
filename = [path_sound_fig,'Amplitude_Modulated_Sound_BaseSigmaPeak.png'];
plot_sound(modu_sound, time, tit, xlab_sound, ylab_sound, filename)


%% Ampiltude Modulate Sound (Based on Low Beta)
f = 30;
filename = [path_sound_file,'Amplitude_Modulated_Sound_BaseLowGamma.wav'];
modu_sound = sound_gene_amplitude_modulated(f, Fs, time, N, pink_noise, filename);

% Plot Frequency Spectrum of Modulated Signal
tit = ['Amplitude Modulated Sound BaseLowGamma = 30Hz'];
filename = [path_sound_fig,'Amplitude_Modulated_Sound_BaseLowGamma_Frequency.png'];
plot_sound_frespectrum(modu_sound, Fs, tit, xlab_fre, ylab_fre, filename)

% Plot Modulated Signal
tit = 'Amplitude Modulated Sound BaseLowGamma';
filename = [path_sound_fig,'Amplitude_Modulated_Sound_BaseLowGamma.png'];
plot_sound(modu_sound, time, tit, xlab_sound, ylab_sound, filename)

%% Rhythmic Sound 
filename = [path_sound_file,'Rhythmic_Sound.wav'];
rhythmic_sound = sound_gene_rhythmic(sigma_peak, Fs, T, pink_noise, filename);

% Plot Modulated Signal
tit = 'Rhythmic Sound';
filename = [path_sound_fig,'Rhythmic_Sound.png'];
plot_sound(rhythmic_sound, time, tit, xlab_sound, ylab_sound, filename)

% Plot Frequency Spectrum of Modulated Signal
tit = [path_sound_fig,'Rhythmic Sound BaseSigmaPeak = ', num2str(sigma_peak), 'Hz'];;
filename = [path_sound_fig,'Rhythmic_Sound_Frequency.png'];
plot_sound_frespectrum(rhythmic_sound, Fs, tit, xlab_fre, ylab_fre, filename)

%% Arhythmic Sound 
for i = 1:5
    filename = [path_sound_file,'Arhythmic_Sound.wav\Arhythmic_Sound ', num2str(i),'.wav'];
    arhythmic_sound = sound_gene_arhythmic(sigma_peak, Fs, T, pink_noise, filename);
    
    % Plot Modulated Signal
    tit = ['Rhythmic Sound ', num2str(i)];
    filename = [path_sound_fig,'Arhythmic_Sound.wav\Arhythmic_Sound ', num2str(i),'.png'];
    plot_sound(arhythmic_sound, time, tit, xlab_sound, ylab_sound, filename)
    
    % Plot Frequency Spectrum of Modulated Signal
    tit = [path_sound_fig,'Arhythmic Sound ', num2str(i),' BaseSigmaPeak = ', num2str(sigma_peak), 'Hz'];;
    filename = [path_sound_fig,'Arhythmic_Sound.wav\Arhythmic_Sound_Frequency ', num2str(i),'.png'];
    plot_sound_frespectrum(arhythmic_sound, Fs, tit, xlab_fre, ylab_fre, filename)
end