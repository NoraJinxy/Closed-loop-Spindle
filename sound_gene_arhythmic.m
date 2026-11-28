function voice = sound_gene_arhythmic(sigma_peak, Fs, T, filename)

n_pink_noise = 0.025*Fs;
n_voice = T * Fs;
interval = floor(1/sigma_peak*Fs);
num_noise = sigma_peak*T;

pink_noise = pinknoise(n_pink_noise);
voice = zeros(1, n_voice);
max_interval = interval - n_pink_noise;
voice_pos = randi([5, max_interval], 1, 1);
voice(1, voice_pos:voice_pos+n_pink_noise-1) = pink_noise(:,1);
for i = 2:num_noise
    max_interval = i * interval - voice_pos - n_pink_noise*2;
    voice_pos = randi([5, max_interval], 1, 1) + voice_pos + n_pink_noise;
    voice(1, voice_pos:voice_pos+n_pink_noise-1) = pink_noise(:,1);
end
voice = voice./max(abs(voice));

% Save Sound
audiowrite(filename, voice, Fs);
clear modu_sound
[voice,Fs] = audioread(filename);
sound(voice, Fs)

end