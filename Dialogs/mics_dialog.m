function [mics_selected] = mics_dialog(varargin)
   
    nm_pos = [24,19,9];
    
    xyz_mm = {0:20:460,0:20:360,0:40:320};
    
    switch nargin
        case 0
            mics_selected = false(31,32);
        case 1 
            mics_selected = varargin{1}; 
        otherwise
            disp('Too much arguments!');
            return;
    end
    
    mics_selected_prev = mics_selected;
    
    btn_pressed = false;
    last_ticked_idx = 0;
    tick_char = char(hex2dec('2713'));
    font_normalized_size = 0.7;
   
    handles_all = gobjects(32*31,1);
%     positions_all = zeros(sum(nm_pos),4);
  	all_indexing = struct('axis',zeros(32*31,1), 'position',zeros(32*31,1));
%     glb_idx = 1;
    screen_ = get(0,'screensize');

    fig = figure('Units','normalized','Position', [0.25,(1-screen_(3)/screen_(4)*0.5)/2,0.5,screen_(3)/screen_(4)*0.5],'MenuBar','none','ToolBar','none','Name','Microphones selector','NumberTitle','off'); 
    drawnow;
    set(fig,'WindowButtonDownFcn',@fig_m_down_up_move);
    set(fig,'WindowButtonUpFcn',@fig_m_down_up_move);
    set(fig,'WindowButtonMotionFcn',@fig_m_down_up_move);
    set(fig,'CloseRequestFcn',@fig_close);
    
    ax = axes(  fig,'Units','normalized','Position',[0.1,0.1,0.85,0.8],...
                'visible','on','XAxisLocation','top','YAxisLocation','left',...
                'YDir','reverse','Color','none');
   
    
    xticklabels(ax,[string(1:1:31),'src']);
%     xticklabels(ax,string(1:1:31));
    xlabel(ax,'Microphone index','visible','on');
    ylabel(ax,'Reference microphone index','visible','on');

    panel_presets = uibuttongroup(fig,'Title','Presets','Position',[0.1,0.01,0.49,0.09]);
    
    
    posss = get(ax,'Position');
%     posss(4) = posss(4)*0.99; 
%     posss(1) = posss(1)+0.01; 
%     axis(ax,'tight')
    panel_ = uibuttongroup(fig,'Position',posss,'BorderType','none','BorderWidth',0);
    panel_pos = get(panel_,'InnerPosition');
    width_x  = 1/71;
    height_y = 1/68;
    x = [(0:2:8)*width_x,(11:2:19)*width_x,(22:2:30)*width_x,(33:2:41)*width_x,(44:2:52)*width_x,(55:2:63)*width_x,66*width_x,69*width_x];
    y = [(0:2:8)*height_y,(11:2:19)*height_y,(22:2:30)*height_y,(33:2:41)*height_y,(44:2:52)*height_y,(55:2:63)*height_y,66*height_y];
    
    [X,Y] = meshgrid(x,y);
    [X_id,Y_id] = meshgrid(1:32,1:31);
    X = X(:);
    Y = Y(:);
    X_id = X_id(:);
    Y_id = Y_id(:);
    
    positions_all = zeros(length(X),4);
    positions_all(:,1) = X;
    positions_all(:,2) = max(Y)- Y;
    positions_all(:,3) = width_x*2;
    positions_all(:,4) = height_y*2;
%     all_indexing = struct('axis',zeros(length(X),1), 'position',zeros(length(X),1));
    xticks(ax,x+width_x);
    yticks(ax,y+(height_y*0.85));
    yticklabels(ax,string(1:1:31));
    
    uicontrol(  fig,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size, ...
                'Position',[0.6,0.01,0.19,0.05],'Style','PushButton','String','Cancel','Tag','Cancel','Callback',@btn_ok_cancel);
            
    uicontrol(  fig,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size, ...
                'Position',[0.8,0.01,0.19,0.05],'Style','PushButton','Tag','OK','String','OK','Callback',@btn_ok_cancel);
            
            
            
    uicontrol(  panel_presets,'Units','normalized',...
                'Position',[0,0,0.15,1],'Style','RadioButton','Tag','atf','String','ATFs','Callback',@radio_presets);
            
    uicontrol(  panel_presets,'Units','normalized', ...
                'Position',[0.15,0,0.325,1],'Style','RadioButton','Tag','1_','String','1. in each array','Callback',@radio_presets);
    
    uicontrol(  panel_presets,'Units','normalized', ...
                'Position',[0.15+0.325,0,0.325,1],'Style','RadioButton','Tag','3_','String','3. in each array','Callback',@radio_presets);
            
    rb_custom = uicontrol(  panel_presets,'Units','normalized', ...
                'Position',[0.80,0,0.2,1],'Style','RadioButton','Tag','custom','String','Custom','Value',1,'Callback',@radio_presets);
            
            
            
    [r,c] = find(mics_selected);
    sele = [r,c];
    for i = 1:size(positions_all,1)
        h = uicontrol(   panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                          'Position',positions_all(i,:) ,'Style','PushButton','Enable','inactive');
        if(any(ismember(sele,[Y_id(i),X_id(i)],'rows')))
           set(h,'String',tick_char);
        end
        all_indexing(i).axis = X_id(i);
        all_indexing(i).position = Y_id(i);
        handles_all(i) = h;
    end
    
    
    waitfor(fig);
    
    %% callbacks
    function fig_m_down_up_move(src,event)    
        switch event.EventName
            
            case 'WindowMousePress'
                switch get(src,'SelectionType')
                    case 'normal'
                        btn_pressed = true;
                    case 'alt'
                        btn_pressed = false;
                    case 'open'
                        btn_pressed = false;
                    otherwise
                        btn_pressed = false;
                end
                
            case 'WindowMouseRelease'
                switch get(src,'SelectionType')
                    case 'normal'
                        btn_pressed = false;
                        last_ticked_idx = 0;
%                         [X_s,Y_s,Z_s] = meshgrid(xyz_mm{1}(mics_selected{1}),xyz_mm{2}(mics_selected{2}),xyz_mm{3}(mics_selected{3}));
%                         set(selected_scatter,'XData',X_s(:));
%                         set(selected_scatter,'YData',Y_s(:));
%                         set(selected_scatter,'ZData',Z_s(:));
                    case 'alt'
                        btn_pressed = false;
                    case 'open'
                        btn_pressed = false;
                    otherwise
                        btn_pressed = false;
                end
        end
        
        if(btn_pressed)
            F = get (src, 'CurrentPoint');
            
            p_left = panel_pos(1);
            p_bottom = panel_pos(2);
            p_width = panel_pos(3);
            p_height = panel_pos(4);
            
            if((F(1)>= p_left && F(1)<= p_left+p_width) && (F(2)>= p_bottom && F(2)<= p_bottom+p_height))
               F_rel = [ ((F(1)-p_left))/(p_width) ,((F(2)-p_bottom))/(p_height) ];
               none_pos = true;
               for pos_idx = 1:size(positions_all,1)
                   if((F_rel(1)>=positions_all(pos_idx,1) && F_rel(1) <= positions_all(pos_idx,1)+positions_all(pos_idx,3)) && (F_rel(2)>=positions_all(pos_idx,2) && F_rel(2) <= positions_all(pos_idx,2)+positions_all(pos_idx,4)))
                        none_pos = false;
                        if(pos_idx~=last_ticked_idx)
                            if(~mics_selected(all_indexing(pos_idx).position,all_indexing(pos_idx).axis))
                                 set(handles_all(pos_idx),'String',tick_char);
                                 mics_selected(all_indexing(pos_idx).position,all_indexing(pos_idx).axis) = true;
                            else
                                set(handles_all(pos_idx),'String','');
                                mics_selected(all_indexing(pos_idx).position,all_indexing(pos_idx).axis) = false;
                            end
                            set(rb_custom,'Value',1);
                        end
                        last_ticked_idx = pos_idx;  
                        break;
                   end
               end
               if(none_pos)
                   last_ticked_idx = 0; 
               end
            end 
        end
    end
    function btn_ok_cancel(src,~)
       switch src.Tag
           case 'OK'
                delete(fig);
           case 'Cancel'
                close(fig);
       end
    end
    function fig_close(~,~)
        mics_selected = mics_selected_prev;
        delete(fig);
    end
    function radio_presets(src,~)
        switch src.Tag
            case 'atf'
%                 disp('atf')
                set(handles_all,'String','');
                mics_selected(:,:) = false;
                for h_i = 0:30
                    set(handles_all(end-h_i),'String',tick_char);
                end
                mics_selected(:,end) = true;
            case '1_'
%                 disp('1. in each')
                
                set(handles_all,'String','');
                mics_selected(:,:) = false;
                
                start = 1;
                stop  = 31*5; 
                
                for h_i = 1:6
                    set(handles_all(start:31:stop-1),'String',tick_char);
                    start = (stop+6);
                    stop = start+(31*5)-1;
                    mics_selected(((h_i-1)*5)+1,(((h_i-1)*5)+1):((h_i)*5)) = true;
                end
  
            case '3_'
%                 disp('3. in each')
                
                set(handles_all,'String','');
                mics_selected(:,:) = false;
                
                start = 3;
                stop  = 2+(31*5); 
                
                for h_i = 1:6
                    set(handles_all(start:31:stop-1),'String',tick_char);
                    start = (stop+6);
                    stop = start+(31*5)-1;
                    mics_selected(((h_i-1)*5)+3,(((h_i-1)*5)+1):((h_i)*5)) = true;
                end
            case 'custom'
%                 disp('custom')
        end
    end
end

