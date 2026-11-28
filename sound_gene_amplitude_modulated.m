function generated_sound = sound_gene_amplitude_modulated(f, Fs, time, N, filename)

pink_noise = pinknoise(N);
pink_noise = pink_noise./max(pink_noise);

s1 = sin(2*pi*f*time);
s2 = reshape(pink_noise, [1,N]);
generated_sound = s2.*(1.5+s1);
generated_sound = generated_sound./ceil(max(abs(generated_sound)));

% Save Sound
audiowrite(filename, generated_sound, Fs);
clear modu_sound
[modu_sound,Fs] = audioread(filename);
sound(modu_sound, Fs)

end