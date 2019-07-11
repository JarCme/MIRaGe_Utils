function [g_tensor, selected_map] = struct2tensor(varargin)
    %Function that returns a tensor of specified filters saved within a
    %structure exported from the MIRaGe Utils software
    %
    %Syntax:
    %
    %[g_tensor, selected_map] = struct2Tensor(structure)
    %[g_tensor, selected_map] = struct2Tensor(structure, mic)
    %[g_tensor, selected_map] = struct2Tensor(structure, mic, ref_mic)
    %[g_tensor, selected_map] = struct2Tensor(structure, mic, ref_mic, x)
    %[g_tensor, selected_map] = struct2Tensor(structure, mic, ref_mic, x, y)
    %[g_tensor, selected_map] = struct2Tensor(structure, mic, ref_mic, x, y, z)
    %[g_tensor, selected_map] = struct2Tensor(structure, mic, ref_mic, x, y, z, t60)
    %
    %Inputs:
    %   structure = structure containing data from the MIRaGe software
    %
    %   mic = microphones indexes selection, vector of
    %   mic indexes | scalar for one index | ':' select all
    %
    %   ref_mic = references microphones indexes selection, vector of
    %   mic indexes | scalar for one index | ':' select all
    %
    %   x = x axis position in the grid relative coordinates, vector of
    %   positions | scalar for one position | ':' select all
    %
    %   y = y axis position in the grid relative coordinates, vector of
    %   positions | scalar for one position | ':' select all
    %
    %   z = z axis position in the grid relative coordinates, vector of
    %   positions | scalar for one position | ':' select all
    %
    %   t60 = t60 reverberation time selector in ms, vector of
    %   selected t60s  | scalar one t60 | ':' select all
    %
    %Outputs:
    %   g_tensor = time-domain filters (ATF or RTF) tensor
    %
    %   selected_map = selected values of parameters. Order corresponds to g_tensor dimensions
    
    g_tensor = [];
    if(nargin<1 || nargin>7)
        disp('Incorrect number of input arguments! See manual page of the function.');
        return;
    else
        structure = varargin{1};
        mic = ':';
        ref_mic = ':';
        x = ':';
        y = ':';
        z = ':';
        t60 = ':';

        if(nargin>1)
            mic = varargin{2};
            if(nargin>2)
                ref_mic = varargin{3};
                if(nargin>3)
                    x = varargin{4};
                    if(nargin>4)
                        y = varargin{5};
                        if(nargin>5)
                            z = varargin{6};
                            if(nargin>6)
                                t60 = varargin{7};
                            end
                        end
                    end
                end
            end
        end
    end

    cache = [reshape([structure.data(:).pos],3,[]).', ...
            [structure.data(:).mic].', ...
            [structure.data(:).ref_mic].', ...
            [structure.data(:).t60].'];

    selected_map.mic = unique(cache(:,4)).';
    if(~strcmp(mic,':'))   
        selected_map.mic = check_selected_parameters(selected_map.mic,mic,'mic');
    end

    selected_map.ref_mic = unique(cache(:,5)).';
    if(~strcmp(ref_mic,':'))  
        selected_map.ref_mic = check_selected_parameters(selected_map.ref_mic,ref_mic,'ref_mic');
    end

    selected_map.x = unique(cache(:,1)).';
    if(~strcmp(x,':'))
         selected_map.x = check_selected_parameters(selected_map.x,x,'x');
    end

    selected_map.y = unique(cache(:,2)).';
    if(~strcmp(y,':'))
        selected_map.y = check_selected_parameters(selected_map.y,y,'y');
    end

    selected_map.z = unique(cache(:,3)).';
    if(~strcmp(z,':'))
        selected_map.z = check_selected_parameters(selected_map.z,z,'z');
    end

    selected_map.t60 = unique(cache(:,6)).';
    if(~strcmp(t60,':'))
        selected_map.t60 = check_selected_parameters(selected_map.t60,t60,'t60');
    end

    g_tensor = zeros(   length(selected_map.mic), ...
                        length(selected_map.ref_mic), ...
                        length(selected_map.x), ...
                        length(selected_map.y), ...
                        length(selected_map.z), ...
                        length(selected_map.t60), ...
                        structure.RTF_length);

    for i_mic = 1:size(g_tensor,1)
        for i_ref_mic = 1:size(g_tensor,2)
            for i_x = 1:size(g_tensor,3)
                for i_y = 1:size(g_tensor,4)
                    for i_z = 1:size(g_tensor,5)
                        for i_t60 = 1:size(g_tensor,6)
                           [~, index] = ismember(   [   selected_map.x(i_x), ...
                                                        selected_map.y(i_y), ...
                                                        selected_map.z(i_z), ...
                                                        selected_map.mic(i_mic), ...
                                                        selected_map.ref_mic(i_ref_mic), ...
                                                        selected_map.t60(i_t60)], cache, 'rows');
                            if(index ==0)
                                g_tensor(i_mic, i_ref_mic, i_x, i_y, i_z, i_t60, :) = nan;
                                continue; 
                            end
                            g_tensor(i_mic, i_ref_mic, i_x, i_y, i_z, i_t60, :) = structure.data(index).g;
                        end
                    end
                end
            end
        end
    end

end

function out = check_selected_parameters(from,to,selection_type)
    uniq_to = unique(to);

    if((length(uniq_to) == length(intersect(from,uniq_to))) && ~isempty(intersect(from,uniq_to)))
        out = to;
    else
        error(['"',selection_type ,'" selection is not presented in the input structure.']); 
    end
end
