function MIRaGe_GUI()

    addpath(['Dialogs',filesep]);
    addpath(['RTF_Estimators',filesep]);
    addpath(['Tools',filesep]);

    [estimators_names,estimators_parameters] = find_RTF_estimators();

    if(exist('last_settings.mat','file')==2)
        answer = questdlg('Would you like load previous settings (Database folder and Output folder)','Settings loader', 'Yes','No','Yes');
% Handle response
    switch answer
        case 'Yes'
            load('last_settings.mat');
        case 'No'
    end
        
    end
    
    selected_method_idx = 2;
    selected_method = estimators_names(selected_method_idx);
    RTF_est_params.targetFS = 48000;
    RTF_est_params.RTFlength = 1024;
    % parameters_handles.texts = [];
    % parameters_handles.edits = [];
    folder_database = pwd+""+filesep+"MIRaGe";
    folder_output = pwd+""+filesep+"Output";
    snd_type = 'WN';
    mic_matrix = [];
    grid_pos = [];
    oog_pos = [];
    t60 = ["100","300","600"];
    t60_selected = [1,0,0];
    Font_size = 8;
    export_var_name = "RTFs_struct";
    stop_flag = 0;
    nm_RTFs = 0;
    grid_pos_v2 = {false(24,1),false(19,1),false(9,1)};
    mic_matrix = false(31,32);
    oog_pos_v2 = false(25,1);

    
    if(exist('last_settings.mat','file')==2)
        load('last_settings.mat');
    end
    
    
    screen_res = get(0,'ScreenSize');
    fig = figure(   'Units','normalized','Position',[ 0.5-(600/screen_res(3)/2) , 0.5-(350/screen_res(4)/2) ,600/screen_res(3), 350/screen_res(4)],'MenuBar','none',...
                    'ToolBar','none','Resize','off','CloseRequestFcn',@app_close_callback, ...
                    'NumberTitle','off','Name','RTF ','NextPlot','new');


    panel_folder_selection = uipanel(fig,'Title','Folders selection','Position',[0.0100    0.8000    0.65    0.2000]);
    uicontrol( panel_folder_selection,'Units','normalized','Position',[0.01 0.51 0.98 0.48],'Style','PushButton',...
                                    'String','Database folder selection','ToolTipString',folder_database,'Tag','folder_in','CallBack',@btn_folder_selection);
    uicontrol( panel_folder_selection,'Units','normalized','Position',[0.01 0.01 0.98 0.48],'Style','PushButton',...
                                    'String','Output folder selection','ToolTipString',folder_output,'Tag','folder_out','CallBack',@btn_folder_selection);

    % ------
    panel_snd_type_selection = uibuttongroup(fig,'Title','Input sound type','Position',[0.0100    0.6000    0.322    0.2000]);
    uicontrol(  panel_snd_type_selection,'Units','normalized','Position',[0.01 0.51 0.98 0.48],'Style','RadioButton',...
                'String','WhiteNoise','Tag',"WN",'Value',strcmp(snd_type,"WN"),'Callback',@snd_type_callback);
    uicontrol(  panel_snd_type_selection,'Units','normalized','Position',[0.01 0.01 0.98 0.48],'Style','RadioButton', ...
                'Tag',"Chirp",'String','Chirp','Value',strcmp(snd_type,"Chirp"),'Callback',@snd_type_callback);

    % ------
    panel_RTF_method_selection = uibuttongroup(fig,'Title','RTF estimation method','Position',[0.3351    0.6000    0.322    0.2000]);
    method_help = help(estimators_names(selected_method_idx));
    uicontrol(   panel_RTF_method_selection,'Units','normalized','Position',[0.01 0.25 0.98 0.48],'Style','PopUpMenu',...
                        'String',estimators_names,'Value',selected_method_idx,'ToolTipString',method_help,'CallBack',@method_selection_callback);

    % ------        
    panel_RTF_params_s_selection = uibuttongroup(fig,'Title','RTF - Method specific parameters','Position',[0.3350    0.0100    0.665    0.3800]);
    add_all_parameters();

    % ------
    panel_RTF_params_b_selection = uibuttongroup(fig,'Title','RTF - Basic parameters','Position',[0.3350    0.4000    0.322    0.2000]);
    uicontrol(  panel_RTF_params_b_selection,'Units','normalized','Position',[0.01 0.01 0.48 0.48], 'Style', 'Text',...
                'String','RTF length','HorizontalAlignment','left');
    uicontrol(  panel_RTF_params_b_selection,'Units','normalized','Position',[0.5 0.01 0.48 0.48], 'Style', 'Edit',...
                'String',RTF_est_params.RTFlength,'Tag','RTF_length','CallBack',@insert_number_callback,'UserData',RTF_est_params.RTFlength);
    uicontrol(  panel_RTF_params_b_selection,'Units','normalized','Position',[0.01 0.5 0.48 0.48], 'Style', 'Text',...
                'String','Target FS','HorizontalAlignment','left');
    uicontrol(  panel_RTF_params_b_selection,'Units','normalized','Position',[0.5 0.5 0.48 0.48], 'Style', 'Edit',...
                'String',RTF_est_params.targetFS,'Tag','FS','CallBack',@insert_number_callback,'UserData',RTF_est_params.targetFS);

    % ------
    panel_t_60_selection = uibuttongroup(fig,'Title','T60 selection [ms]','Position',[0.0100    0.4000    0.322    0.2000]);
    uicontrol(  panel_t_60_selection,'Units','normalized','Position',[0.01 0.01 0.32 0.98],'Style','CheckBox',...
                'String','100','Tag','100','Value',t60_selected(1),'Callback',@t60_type_callback);
    uicontrol(  panel_t_60_selection,'Units','normalized','Position',[0.34 0.01 0.32 0.98],'Style','CheckBox',...
                'String','300','Tag','300','Value',t60_selected(2),'Callback',@t60_type_callback);
    uicontrol(  panel_t_60_selection,'Units','normalized','Position',[0.67 0.01 0.32 0.98],'Style','CheckBox',...
                'String','600','Tag','600','Value',t60_selected(3),'Callback',@t60_type_callback);

    % ------
    panel_positions_selection = uibuttongroup(fig,'Title','Positions/Mics selection','Position',[0.0100    0.0100    0.322    0.3800]);

    uicontrol( panel_positions_selection,'Units','normalized','Position',[0.01 0.76 0.98 0.24],'Style','PushButton',...
                                    'String','Microphones selection','ToolTipString',"Microphone selector, Reference -> Target matrix",...
                                    'Tag','MICs','CallBack',@mic_pos_selector_callback);
    uicontrol( panel_positions_selection,'Units','normalized','Position',[0.01 0.51 0.98 0.24],'Style','PushButton',...
                                    'String','Grid positions selection','ToolTipString',"Positions inside grid selector",...
                                    'Tag','Grid','CallBack',@mic_pos_selector_callback);
    uicontrol( panel_positions_selection,'Units','normalized','Position',[0.01 0.26 0.98 0.24],'Style','PushButton',...
                                    'String','OOG positions selections','ToolTipString',"Out of grid position selector",...
                                    'Tag','OOG','CallBack',@mic_pos_selector_callback);
    nm_RTFs_text = uicontrol( panel_positions_selection,'Units','normalized','Position',[0.01 0.01 0.98 0.24],'Style','text',...
                                    'String','# selected RTFs: 0');

    % ------
    btn_start = uicontrol(fig,'Units','normalized','Position',[0.67 0.8  0.32 0.18],'Style','PushButton',...
                                    'String','START','CallBack',@btn_start_callback);

    completed_text = uicontrol(fig,'Units','normalized','Position',[0.67 0.6  0.32 0.2],'Style','text',...
                                    'String',['0/0'],'Visible','off');
    estimated_time_text = uicontrol(fig,'Units','normalized','Position',[0.67 0.5  0.32 0.2],'Style','text',...
                                    'String',"Estimated time: 0",'Visible','off');

    panel_output_variables = uibuttongroup(fig,'Title','Export settings','Position',[0.67    0.4    0.32    0.2]);

    uicontrol(panel_output_variables,'Units','normalized','Position',[0.01 0.49 1 0.49],'Style','text',...
                                    'String',"Exported variable name");
    uicontrol(panel_output_variables,'Units','normalized','Position',[0.01 0.01 1 0.49],'Style','Edit',...
                                    'String',export_var_name,'CallBack',@edit_export_var_callback);

    all_UI_controls = findobj(fig,'Type','UIControl');

    set(all_UI_controls,'FontSize',Font_size);

    
    function edit_export_var_callback(src,~)
        export_var_name = string(src.String);
    end

    function mic_pos_selector_callback(src,~)
            switch src.Tag
                case 'MICs'
%                     mic_matrix =  mic_selection_figure();
                    mic_matrix =  mics_dialog(mic_matrix);
                case 'OOG'
%                     oog_pos = oog_selection_window();
                    [oog_pos_v2,oog_pos] = OOG_dialog(oog_pos_v2);
                case 'Grid'
%                     grid_pos = grid_selection_window();
                    [grid_pos_v2,grid_pos] = grid_dialog(grid_pos_v2);
            end
            nm_RTFs = sum(t60_selected)*(sum(sum(mic_matrix))*size(grid_pos,1) + sum(sum(mic_matrix))*size(oog_pos,2));
            set(nm_RTFs_text,'String',"# selected RTFs: "+nm_RTFs);
    end

    function t60_type_callback(src,~)
        switch src.Tag
            case '100'
                t60_selected(1) = src.Value;
            case '300'
                t60_selected(2) = src.Value;
            case '600'
                t60_selected(3) = src.Value;
        end
        nm_RTFs = sum(t60_selected)*(sum(sum(mic_matrix))*size(grid_pos,1) + sum(sum(mic_matrix))*size(oog_pos,2));
        set(nm_RTFs_text,'String',"# selected RTFs: "+nm_RTFs);
    end

    function btn_start_callback(src,~)
        switch get(src,'String')
            case 'START'
                stop_flag = false;
                if(nm_RTFs==0)
                   waitfor(warndlg('No RTFs to compute. Please check input parameters.'));
                   return;
                end

                set(completed_text,'String',"0"+"/"+nm_RTFs);
                set(completed_text,'Visible','on');
                set(estimated_time_text,'String',"Estimated time: 0");
                set(estimated_time_text,'Visible','on');
                set(findobj(fig,'Type','UIControl'),'Enable','off');
                set(completed_text,'Enable','on');
                set(estimated_time_text,'Enable','on');
                set(src,'Enable','on');
                set(src,'String','STOP');
                completed = 0;

                out_struct.method  =  selected_method;
                out_struct.method_params =  RTF_est_params.input_struct;
                out_struct.RTF_length =  RTF_est_params.RTFlength;
                out_struct.target_FS =  RTF_est_params.targetFS;
                out_struct.snd_type =  snd_type;

                phase_corrections = load("tools"+filesep+"phase_corrections.mat");
                phase_corrections = phase_corrections.phase_corrections;
                how_long = [0,0];
                for idx_t60 = 1:length( t60(logical( t60_selected)))
                    t60_list =  t60(logical( t60_selected));
                    [row,col]=find(mic_matrix);
                    for idx_mic = 1:size(row,1)
                        % FIX ME notify about all packages
                        if(col(idx_mic) == 32)
                            array_ref_folder = sprintf( '%02d',ceil(row(idx_mic)/5)); 
                        else
                            array_ref_folder = sprintf( '%02d',ceil(col(idx_mic)/5));
                        end
                        if(strcmp(array_ref_folder,'07'))
                            array_ref_folder = "on_SPK_mic";
                        end
       
                        array_tar_folder = sprintf( '%02d', ceil(row(idx_mic)/5));
                        if(strcmp(array_tar_folder,'07'))
                            array_tar_folder = "on_SPK_mic";
                        end
                        
                        package_prefix = [snd_type,'_',char(t60_list(idx_t60)),'_'];
                        
                        required_packages = [char(package_prefix),char(array_ref_folder),'.zip, ',char(package_prefix),char(array_tar_folder),'.zip'];
                        if(strcmp(char(array_ref_folder),char(array_tar_folder)))
                            required_packages = [package_prefix,char(array_ref_folder),'.zip'];
                        end
                        
                        
                        for idx_pos_grid = 1:size( grid_pos,1)
                            if( stop_flag)
                                stop_flag = false;
                                return;
                            end
                            tic;
                            [g,~] = getRTF(     selected_method, t60_list(idx_t60),  grid_pos(idx_pos_grid,:),...
                                                col(idx_mic), row(idx_mic), RTF_est_params.targetFS,  RTF_est_params.RTFlength, RTF_est_params.input_struct,...
                                                 folder_database, phase_corrections,  folder_output,  snd_type,0);
                            
                            if(g == -1)
                                waitfor(warndlg(['Required audiofiles were not found. Required packages: ',required_packages]));
                                set(findobj(fig,'Type','UIControl'),'Enable','on');
                                set(src,'String','START');
                                stop_flag = true;
                                set(completed_text,'Visible','on');
                                return;
                            end
                            
                            completed = completed + 1;

                            out_struct.data(completed).g = g;
                            out_struct.data(completed).pos =  grid_pos(idx_pos_grid,:) ;
                            out_struct.data(completed).mic = col(idx_mic);
                            out_struct.data(completed).ref_mic = row(idx_mic);
                            out_struct.data(completed).t60 = str2double(t60_list(idx_t60));


                            how_long(2)=toc;
                            how_long(1)= (how_long(1)*completed+how_long(2))/(completed+1);
                            set(completed_text,'String',completed+"/"+nm_RTFs);
                            est_secs=seconds((nm_RTFs-completed)*(how_long(1)));
                            est_secs.Format = 'hh:mm:ss';
                            set(estimated_time_text,'String',"Estimated time: "+string(est_secs)+" (HH:MM:SS)");
%                             set(estimated_time_text,'String',"Estimated time: "+(nm_RTFs-completed)*(how_long(1)/60)+" mins");
                            drawnow;

                        end

                        for idx_pos_oog = 1:length(( oog_pos))
                            if( stop_flag)
                                stop_flag = false;
                                return;
                            end
                            tic;
%                             disp(oog_pos(idx_pos_oog));
                            [g,~] = getRTF(     selected_method, t60_list(idx_t60),  oog_pos(idx_pos_oog),...
                                                col(idx_mic), row(idx_mic), RTF_est_params.targetFS,  RTF_est_params.RTFlength, RTF_est_params.input_struct,...
                                                 folder_database, phase_corrections,  folder_output,  snd_type,1);
                            
                            if(g == -1)
                                waitfor(warndlg(['Required audiofiles were not found. Required packages:',required_packages]));
                                set(findobj(fig,'Type','UIControl'),'Enable','on');
                                set(src,'String','START');
                                stop_flag = true;
                                set(completed_text,'Visible','on');
                                return;
                            end
                            
                            completed = completed + 1;

                            out_struct.data(completed).g = g;
                            out_struct.data(completed).pos =  [oog_pos(idx_pos_oog),-1,-1] ;
                            out_struct.data(completed).mic = col(idx_mic);
                            out_struct.data(completed).ref_mic = row(idx_mic);
                            out_struct.data(completed).t60 = str2double(t60_list(idx_t60));


                            how_long(2)=toc;
                            how_long(1)= (how_long(1)*completed+how_long(2))/(completed+1);
                            set(completed_text,'String',completed+"/"+nm_RTFs);
                            est_secs=seconds((nm_RTFs-completed)*(how_long(1)));
                            est_secs.Format = 'hh:mm:ss';
                            set(estimated_time_text,'String',"Estimated time: "+string(est_secs)+" (HH:MM:SS)");
                            drawnow;
                        end

                    end
                end
                assignin('base', export_var_name,out_struct);        
                set(completed_text,'Visible','off');
                set(estimated_time_text,'Visible','off');
                set(src,'String','START');
                set(findobj(fig,'Type','UIControl'),'Enable','on');
                waitfor(msgbox(char("Computation completed! Output stucture has been saved in base workspace (var name: "+ export_var_name+" )")));
            case 'STOP'
                set(findobj(fig,'Type','UIControl'),'Enable','on');
                set(src,'String','START');
                stop_flag = true;
                set(completed_text,'Visible','on');
                waitfor(msgbox(char("Computatin was cancelled by user")));
                
        end
    end

    function btn_folder_selection(src,~)
        selected_folder = uigetdir(pwd);
        if selected_folder~=0
            switch src.Tag
                case 'folder_out'
                     folder_output = selected_folder;
                case 'folder_in'
                     folder_database = selected_folder;
            end
            set(src,'ToolTipString',selected_folder);
        end
    end

    function insert_number_callback(src,~)
        val = str2double(src.String);
        if(isnan(val))
            set(src,'String',src.UserData);
            dlg = warndlg('Input must be a number!','Input error','modal');
            waitfor(dlg);
            return;
        end
        switch src.Tag
            case 'FS'
                 RTF_est_params.targetFS = val;
            case 'RTF_length'
                 RTF_est_params.RTFlength = val;
        end
        set(src,'UserData',val);
    end

    function snd_type_callback(src,~)
         snd_type = src.Tag;
    end

    function app_close_callback(src,~)
        delete(src);
        rmpath(['Dialogs',filesep]);
        rmpath(['RTF_Estimators',filesep]);
        rmpath(['Tools',filesep]);
 
%         save('last_settings.mat','selected_method_idx','selected_method','RTF_est_params','folder_database',...
%              'folder_output','snd_type','t60_selected','export_var_name','grid_pos_v2','mic_matrix','oog_pos_v2');
        save('last_settings.mat','folder_database','folder_output');
    end

    function [estimators_names,estimators_parameters] = find_RTF_estimators()
    f_list = dir(['RTF_Estimators',filesep,'*.m']);
    estimators_names = strrep(string({f_list.name}),'.m','');
    estimators_parameters = {}; 
        for estimator_idx = 1:length(estimators_names)
            params_struct = load("RTF_Estimators"+filesep+estimators_names(estimator_idx)+".mat");
            estimators_parameters{estimator_idx} = params_struct;
        end
    end

    function method_selection_callback(src,~)
       set(src,'ToolTipString',help(estimators_names(src.Value)));
        selected_method_idx = src.Value;
        selected_method = estimators_names( selected_method_idx);
        RTF_est_params.input_struct = struct();
       add_all_parameters();
    end
    
    function add_all_parameters()
        delete(panel_RTF_params_s_selection.Children)
        positions = [   0.01    0.51    0.24    0.49;
                        0.26    0.51    0.24    0.49;
                        0.51    0.51    0.24    0.49;
                        0.76    0.51    0.24    0.49;
                        0.01    0.01    0.24    0.49;
                        0.26    0.01    0.24    0.49;
                        0.51    0.01    0.24    0.49;
                        0.76    0.01    0.24    0.49];
        input_struct = estimators_parameters{ selected_method_idx};
        RTF_est_params.input_struct = input_struct;
        fields = fieldnames(input_struct);
        if(length(fields)<=8)
            for field_idx = 1:length(fields)  
              add_parameter(panel_RTF_params_s_selection,positions(field_idx,:),fields{field_idx},getfield(input_struct,fields{field_idx}));
            end
        end
    end

    function [handle_name,handle_edit] = add_parameter(parent,position,name_,value_)
    text_pos = position;
    text_pos(4) = text_pos(4)/2;
    text_pos(2) = text_pos(2)+text_pos(4);
    edit_pos = position;
    edit_pos(4) = edit_pos(4)/2;
    ui_data = name_;
    handle_name = uicontrol( parent,'Units','normalized','FontSize', Font_size,'Position',text_pos,'Style','Text',...
                                'String',name_);
    handle_edit = uicontrol( parent,'Units','normalized','Position',edit_pos,'Style','Edit',...
                                'String',value_,'UserData',ui_data,'CallBack',@param_change_callback);
    end
    
    function param_change_callback(src,~) 
        val = str2double(src.String);
        if(isnan(val))
            val = str2num(src.String);
            if(isempty(val))
                val = src.String;
            end
        end
         RTF_est_params.input_struct.(src.UserData) = val;
    end
end