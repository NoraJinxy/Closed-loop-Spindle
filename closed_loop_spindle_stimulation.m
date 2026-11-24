function box_out = closed_loop_spindle_stimulation(box_in, env, env_len, start_time, end_time, T, cue1_trigger)
    % k: Index of the current valid sample in the env envelope. Start at 3 to avoid
    % the difference and envelope initialization boundaries.
    % env_len: Number of columns in the current sigma-envelope block env.
    % start_time/end_time: Start/end times of the current OpenViBE signal chunk.
    % T: Time interval between adjacent samples, in seconds.
    % cue1_trigger: OpenViBE stimulation code sent when a cue is played.

    if ~isfield(box_in.user_data, 't_start')
        box_in.user_data.t_start = 0;
    end
    if ~isfield(box_in.user_data, 'current_spistart')
        box_in.user_data.current_spistart = 0;
    end
    if ~isfield(box_in.user_data, 'current_spiend')
        box_in.user_data.current_spiend = 0;
    end
    if ~isfield(box_in.user_data, 'soundIndex_cue')
        box_in.user_data.soundIndex_cue = 1;
    end

    spistart_cue = box_in.user_data.spistart_cue;
    spiend_cue = box_in.user_data.spiend_cue;
    spistart_real = box_in.user_data.spistart_real;
    spiend_real = box_in.user_data.spiend_real;
    sound_sequence = box_in.user_data.sound_sequence;
    if_stay = NaN;
    current_spistart = box_in.user_data.current_spistart;
    current_spiend = box_in.user_data.current_spiend;
    soundIndex_cue = box_in.user_data.soundIndex_cue;

    for k = 3:env_len
        % start_time and k-2 calculate the absolute time of this envelope sample.
        current_time = start_time + (k-2)*T;

        % Accumulate the absolute time of every valid envelope point.
        box_in.user_data.time = [box_in.user_data.time; current_time];

        % Disable pending stimulation when cue playback mode is turned off.
        if ~box_in.user_data.cue_start_trigger
            box_in.user_data.prepare_sti = false;
        end

        %% 1) Spindle detection state machine
        % spindle_on=0 waits for an upward threshold crossing.
        % spindle_on=1 indicates that a spindle is currently in progress.
        if box_in.user_data.spindle_on == 0
            if env(1,k) >= box_in.user_data.thresh && env(1,k-1) < box_in.user_data.thresh
                box_in.user_data.spindle_on = 1;
                % Absolute spindle start time, in seconds.
                current_spistart = current_time;
                box_in.user_data.current_spistart = current_spistart;
            end
        elseif box_in.user_data.spindle_on == 1
            if env(1,k) <= box_in.user_data.thresh && env(1,k-1) > box_in.user_data.thresh
                % Absolute spindle end time, in seconds.
                current_spiend = current_time;
                box_in.user_data.current_spiend = current_spiend;

                % Save the spindle only if its duration is within the configured limits.
                if current_spiend - current_spistart <= box_in.user_data.max_duri && ...
                        current_spiend - current_spistart >= box_in.user_data.min_duri
                    box_in.user_data.prepare_sti = true;

                    % Find unused positions in the preallocated result arrays.
                    spistart_real(find(spistart_real == 0,1)) = current_spistart;
                    spiend_real(find(spiend_real == 0,1)) = current_spiend;
                    box_in.user_data.spistart_real = spistart_real;
                    box_in.user_data.spiend_real = spiend_real;
                end

                % Reset the state machine after the spindle ends.
                box_in.user_data.spindle_on = 0;
            end
        end

        %% 2) Cue playback timing
        % tt: Time elapsed since the most recent spindle end, in seconds.
        tt = current_time - current_spiend;

        % Trigger one cue after the configured spindle-end delay and within a 0.2 s window.
        if box_in.user_data.cue_start_trigger && box_in.user_data.prepare_sti && ...
                tt >= box_in.user_data.spiend_pause && tt < (box_in.user_data.spiend_pause + 0.2)
            box_in.user_data.prepare_sti = false;

            % Find the latest previously played cue time.
            nsound = find(sound_sequence == 0,1) - 1;
            if nsound == 0
                s_start = 0;
            else
                s_start = sound_sequence(nsound);
            end

            % Apply the minimum interval between adjacent cues.
            if abs(current_time - s_start) > box_in.user_data.cue_interval
                if box_in.user_data.cue_play
                    % cue_num_count is the cumulative cue count.
                    % stimu_times is the number of cues in each stimulation group.
                    if_stay = rem(box_in.user_data.cue_num_count, box_in.user_data.stimu_times);
                    if if_stay == 0
                        % Restart randomized playback after the sequence is exhausted.
                        if box_in.user_data.randIndex_cue > box_in.user_data.num_cue_sounds
                            box_in.user_data.randIndex_cue = 1;
                            box_in.user_data.nthLoop_cue = box_in.user_data.nthLoop_cue + 1;
                            box_in.user_data.randSounds_cue = randperm(box_in.user_data.num_cue_sounds);
                        end

                        % Select the WAV file index from the randomized sequence.
                        soundIndex_cue = box_in.user_data.randSounds_cue(box_in.user_data.randIndex_cue);
                        box_in.user_data.soundIndex_cue = soundIndex_cue;
                    end
                    soundIndex_cue = box_in.user_data.soundIndex_cue;
                    fprintf('if_stay: %d, soundIndex_cue: %d\n', if_stay, soundIndex_cue);

                    % Store the cue start time and send the stimulation trigger.
                    sound_sequence(nsound + 1) = current_time;
                    box_in = OV_addOutputBuffer(box_in,2,start_time,end_time,[cue1_trigger current_time 0]);

                    % Store the selected sound index for later result files.
                    box_in.user_data.sound_ids(nsound + 1) = soundIndex_cue;

                    % Play the selected WAV data using its original sampling frequency.
                    sound(box_in.user_data.sound_info_cue(soundIndex_cue).y, ...
                        box_in.user_data.sound_info_cue(soundIndex_cue).Fs);

                    box_in.user_data.cue_num_count = box_in.user_data.cue_num_count + 1;

                    % Store the spindle start/end times associated with this cue.
                    spistart_cue(find(spistart_cue == 0,1)) = current_spistart;
                    spiend_cue(find(spiend_cue == 0,1)) = current_spiend;
                    box_in.user_data.spistart_cue = spistart_cue;
                    box_in.user_data.spiend_cue = spiend_cue;
                end
            end
        end

        %% 3) Cue cooldown countdown
        % With stimu_times=20, if_stay==19 starts the cooldown before the next cycle.
        if box_in.user_data.cue_play && if_stay == 19
            box_in.user_data.t_start = current_time;
            box_in.user_data.cue_play = false;
        end

        if ~box_in.user_data.cue_play
            % t: Elapsed cooldown time, in seconds.
            t = current_time - box_in.user_data.t_start;
            if t >= box_in.user_data.countdown
                box_in.user_data.cue_play = true;
                box_in.user_data.randIndex_cue = box_in.user_data.randIndex_cue + 1;
                fprintf('t: %d\n', t);
            end
        end
    end

    box_in.user_data.sound_sequence = sound_sequence;
    box_out = box_in;
end
