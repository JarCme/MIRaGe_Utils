function [g, index] = findRTF(structure, pos, mic, ref_mic, t60)
    %Function that returns a specified filter g amd its index within a
    %structure from the MIRaGe software
    %
    %inputs:
    %   structure = structure containing data from the MIRaGe software
    %   pos = position in the grid relative coordinates, e.g. [260, 180, 160]
    %   mic = microphone index (e.g. 31 for on-crane mic) or input sound (32)
    %   ref_mic = reference microphone (e.g. 5)
    %   t60 = reverberation time, e.g. 100
    %
    %outputs:
    %   g = time-domain filter (ATF or RTF)
    %   index = index of the desired filter within the input structure
    
    if(isscalar(pos))
        pos = [pos,-1,-1]; 
    end
    
    cache = [reshape([structure.data(:).pos],3,[]).', ...
        [structure.data(:).mic].', ...
        [structure.data(:).ref_mic].', ...
        [structure.data(:).t60].'];
    [~, index] = ismember([pos, mic, ref_mic, t60], cache, 'rows');
    g = structure.data(index).g;

end