function [g,G] = getRTF(method, t60, loc, mic_idx, ref_mic_idx,fs_req, N, input_struct, database_folder, phase_corrections, precompute_folder, input_type,oog_or_grid, delay_correction)
    %Function to retrieve an RTF from the Database 
    % 
    % Input: 
    %   method = 'TDRTF', 'other_implemented_method_name'
    %   t60 = Desired t60 level (100, 300 or 600 for real setup)
    %   loc = 3x1 array of coordinates for the source position | 1x1 index of the source position (out of grid) 
    %   ref_mic = id of the reference microphone
    %   target_mic = id of the taret microphone
    %   fs_reg = desired fs for decimation
    %   N = length of the non-causal part of the RTF. Also the length
    %   of the delay for TDRTF method.
    %   input_struct = method specific parameters function 
    %   database_folder = input database folder path
    %   phase_corrections = 32x1 array of ones and -ones
    %   precompute_folder = folder path for saving and loading precomputed RTFs 
    %   RTF/ATF
    %   input_type = "WN"|"Chirp"
    %   oog_or_grid = 1|0 - 1: OOG 0: Grid;
    %   delay_correction = 1|0 - 1: allow delay corrections 0: deny delay corrections
    
    % Output:
    %   g = 1x(nc_len+c_len) RTF in time domain
    %   G = 1x(nc_len+c_len) RTF
    %------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    array_ref_folder = sprintf( '%02d',ceil(mic_idx/5));
    if(strcmp(array_ref_folder,'07'))
        array_ref_folder = "on_SPK_mic";
    end
       
    array_tar_folder = sprintf( '%02d', ceil(ref_mic_idx/5));
    if(strcmp(array_tar_folder,'07'))
        array_tar_folder = "on_SPK_mic";
    end
   
    base_path = string(database_folder)+filesep+"DB"+filesep;
    
    if(oog_or_grid)
        audio_path_ref = base_path+input_type+"_"+t60+filesep+"OOG"+filesep;
        audio_path_tar = base_path+input_type+"_"+t60+filesep+"OOG"+filesep;
        
        input_snd_path = audio_path_ref+input_type+"_t60-"+t60+"_OOG_input_sound.flac";
        
        audio_path_ref = audio_path_ref+array_ref_folder+filesep;
        audio_path_tar = audio_path_tar+array_tar_folder+filesep;

        full_precomputed_path = string(precompute_folder)+filesep+input_type+"_"+t60+filesep+"fs-"+fs_req+filesep+"ref_mic-"+ref_mic_idx+ ...
                                filesep+"mic-"+mic_idx+filesep+"length-"+N+filesep+method+filesep+join([fieldnames(input_struct)+...
                                "-"+string(struct2cell(input_struct))],filesep)+filesep+"OOG"+filesep;
                        
        precompute_f_name = input_type+"_t60-"+t60+"_pid-"+loc(1);
        %-----------------------delay correction changes
        loc = [loc(1),-1,-1];
        %
    else
        
        audio_path_ref = base_path+input_type+"_"+t60+filesep+"Grid"+filesep;
        audio_path_tar = base_path+input_type+"_"+t60+filesep+"Grid"+filesep;
        
        input_snd_path = audio_path_ref+input_type+"_t60-"+t60+"_Grid_input_sound.flac";
        
        audio_path_ref = audio_path_ref+array_ref_folder+filesep;
        audio_path_tar = audio_path_tar+array_tar_folder+filesep;

        full_precomputed_path = string(precompute_folder)+filesep+input_type+"_"+t60+filesep+"fs-"+fs_req+filesep+"ref_mic-"+ref_mic_idx+ ...
                                filesep+"mic-"+mic_idx+filesep+"length-"+N+filesep+method+filesep+join([fieldnames(input_struct)+...
                                "-"+string(struct2cell(input_struct))],filesep)+filesep+"Grid"+filesep;

        precompute_f_name = input_type+"_t60-"+t60+"_x-"+loc(1)+"_y-"+loc(2)+"_z-"+loc(3);
    	
    end
    
    if(exist(full_precomputed_path,'dir')==0)
        mkdir(char(full_precomputed_path));
    end
    
    if (exist(char(full_precomputed_path+precompute_f_name+".mat"),'file') == 2)
        load(char(full_precomputed_path+precompute_f_name+".mat"));
    elseif (exist(char(full_precomputed_path+precompute_f_name+".mat"),'file') == 0)
        
        if(exist(char(audio_path_tar+precompute_f_name+".flac"),'file')==2)
            [x_tar, fs] = audioread(char(audio_path_tar+precompute_f_name+".flac"));
        else
            disp(['Required audiofile: ',char(audio_path_tar+precompute_f_name+".flac"),' was not found']);
            g = -1;
            G = -1;
            return;
        end
        
        x_tar = x_tar(:,ref_mic_idx-floor((ref_mic_idx-1)/5)*5) .* phase_corrections(ref_mic_idx);
        
        if(mic_idx == 32) % for ATF computation
            if(exist(char(input_snd_path),'file')==2)
                [x_ref,~] = audioread(char(input_snd_path));
            else
                disp(['Required audiofile: ',char(input_snd_path),' was not found']);
                g = -1;
                G = -1;
                return;
            end
            
            %-----------------------delay correction
            if(delay_correction)
                delay_correct = load(['delays_',char(input_type),'_',num2str(t60),'.mat']);          
                idx_delay_correct = find(ismember(delay_correct.coords,[loc(1),loc(2),loc(3)],'rows'));
                x_ref = circshift(x_ref,delay_correct.delays(idx_delay_correct));
            end
            %
             
            padding_len = length(x_tar) - length(x_ref);
            if(padding_len>0)
                x_ref = [x_ref;zeros(padding_len,1)];
            else
                x_ref = x_ref(1:length(x_tar));
            end     
        else
            
            if(exist(char(audio_path_ref+precompute_f_name+".flac"),'file')==2)
                [x_ref, fs] = audioread(char(audio_path_ref+precompute_f_name+".flac"));
            else
                disp(['Required audiofile: ',char(audio_path_ref+precompute_f_name+".flac"),' was not found']);
                g = -1;
                G = -1;
                return;
            end

            x_ref = x_ref(:,mic_idx-floor((mic_idx-1)/5)*5) .* phase_corrections(mic_idx);
        end
        
        %decimate if necessary
        if fs_req < fs 
            x_ref = resample(x_ref,fs_req,fs);
            x_tar = resample(x_tar,fs_req,fs);
            fs = fs_req;

        end

        [g,G] = feval(method,x_ref,x_tar,N,input_struct);
        
        save(char(full_precomputed_path+precompute_f_name+".mat"),'g','G');
        
    end
    
end
