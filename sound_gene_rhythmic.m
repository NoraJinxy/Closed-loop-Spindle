function voice = sound_gene_rhythmic(sigma_peak, Fs, T, filename)

n_pink_noise = 0.025*Fs;
n_voice = 2*Fs;
dur_voice = floor(1/sigma_peak*Fs);
num_noise = sigma_peak*T;

pink_noise = pinknoise(n_pink_noise);
voice = zeros(1, n_voice);
for i = 1:num_noise
    voice(1, (i-1)*dur_voice+1:(i-1)*dur_voice+n_pink_noise) = pink_noise(:,1);
end
voice = voice./max(abs(voice));

% Save Sound
audiowrite(filename, voice, Fs);
clear modu_sound
[voice,Fs] = audioread(filename);
sound(voice, Fs)

end