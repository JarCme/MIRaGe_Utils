function [xyz_selected,xyz_mesh] = grid_dialog(varargin)
   
    nm_pos = [24,19,9];
    
    xyz_mm = {0:20:460,0:20:360,0:40:320};
    
    switch nargin
        case 0
            xyz_selected = {false(nm_pos(1),1),false(nm_pos(2),1),false(nm_pos(3),1)};
        case 1 
            xyz_selected = varargin{1}; 
        otherwise
            disp('Too much arguments!')
            return;
    end
    
    xyz_selected_prev = xyz_selected;
    
    btn_pressed = false;
    last_ticked_idx = 0;
    tick_char = char(hex2dec('2713'));
    font_normalized_size = 0.7;
    i_z = 0;
    handles_all = gobjects(sum(nm_pos),1);
    positions_all = zeros(sum(nm_pos),4);
  	all_indexing = struct('axis',zeros(sum(nm_pos),1), 'position',zeros(sum(nm_pos),1));
    glb_idx = 1;
    
    fig = figure('Units','normalized','Position', [0.25,0.25,0.5,0.5],'MenuBar','none','ToolBar','none','Name','Grid positions selector','NumberTitle','off'); 
    set(fig,'WindowButtonDownFcn',@fig_m_down_up_move);
    set(fig,'WindowButtonUpFcn',@fig_m_down_up_move);
    set(fig,'WindowButtonMotionFcn',@fig_m_down_up_move)
    set(fig,'CloseRequestFcn',@fig_close)
    
    panel_ = uibuttongroup('Position',[.01,.01,0.2,1-.02]);
    panel_pos = get(panel_,'InnerPosition');

    ax = axes(      fig,'Units','normalized','OuterPosition',[0.22,.06,1-0.23,1-0.07]);
    [X,Y,Z] = meshgrid(xyz_mm{1},xyz_mm{2},xyz_mm{3});
    [X_s,Y_s,Z_s] = meshgrid(xyz_mm{1}(xyz_selected{1}),xyz_mm{2}(xyz_selected{2}),xyz_mm{3}(xyz_selected{3}));
    measured_scatter = scatter3(ax,X(:),Y(:),Z(:),'MarkerFaceAlpha',0.5,'MarkerEdgeAlpha',0.5,'DisplayName','Measured positions');
    hold(ax,'on');
    selected_scatter = scatter3(ax,X_s(:),Y_s(:),Z_s(:),'MarkerFaceColor','red','MarkerEdgeColor','red','DisplayName','Selected positions');
    axis(ax,'equal');
    xlim(ax,[-10,470]);
    ylim(ax,[-10,370]);
    zlim(ax,[-10,330]);
    xlabel(ax,'x');
    ylabel(ax,'y');
    zlabel(ax,'z');
    leg = legend(ax,[measured_scatter,selected_scatter]);
    set(leg,'Units','normalized');
    set(leg,'Position',[0.24,0.85,0.2,0.12]);
    hold(ax,'off');

    nm_rows = nm_pos(1)+2;
    nm_columns = size(nm_pos,2)+1; 
    width = (1-0.02)/nm_columns;
   
    positions = zeros(nm_rows,nm_columns);
    positions(:,1) = ones(nm_rows,1)*0.01;
    positions(:,2) = linspace(0.01,1-0.01,nm_rows)';
    positions(:,3) = width;
    height = positions(2,2)-positions(2,1);
    positions(:,4) = height;   
    
    uicontrol(  fig,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size, ...
                'Position',[0.6,0.01,0.19,0.05],'Style','PushButton','String','Cancel','Tag','Cancel','Callback',@btn_ok_cancel);
            
    uicontrol(  fig,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size, ...
                'Position',[0.8,0.01,0.19,0.05],'Style','PushButton','Tag','OK','String','OK','Callback',@btn_ok_cancel);
        
    uicontrol(  panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                'Position',positions(end-1,:),'Style','Text','String','mm', ...
                'HorizontalAlignment','center','FontName','FixedWidth','Enable','inactive'); 
            
    uicontrol(  panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                'Position',positions(end-1,:)+[width*1,0,0,0],'Style','Text','String','X', ...
                'HorizontalAlignment','center','FontName','FixedWidth','Enable','inactive'); 
            
    uicontrol(  panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                'Position',positions(end-1,:)+[width*2,0,0,0],'Style','Text','String','Y', ...
                'HorizontalAlignment','center','FontName','FixedWidth','Enable','inactive');     
            
    uicontrol(  panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                'Position',positions(end-1,:)+[width*3,0,0,0],'Style','Text','String','Z', ...
                'HorizontalAlignment','center','FontName','FixedWidth','Enable','inactive'); 
    
    for i = nm_rows-2:-1:1
        uicontrol(  panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                    'Position',positions(i,:),'Style','Text','String',num2str((nm_pos(1)-i)*20), ...
                    'HorizontalAlignment','center','FontName','FixedWidth','Enable','inactive'); 
                  
        h1 = uicontrol(   panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                        'Position',positions(i,:)+[width*1,0,0,0],'Style','PushButton','Enable','inactive');        
        idx_per_axis = (((nm_pos(1)-i)*20)/20)+1;
        all_indexing(glb_idx).axis = 1;
        all_indexing(glb_idx).position = idx_per_axis;
        positions_all(glb_idx,:) = (positions(i,:)+[width*1,0,0,0]);
        if(xyz_selected{1}(idx_per_axis))
            set(h1,'String',tick_char);
        end
        handles_all(glb_idx) = h1;
        glb_idx = glb_idx + 1;
        
        if(i>(nm_rows-2-nm_pos(2)))
            data_to_ui.axis = 2;
            data_to_ui.position = (((nm_pos(1)-i)*20)/20)+1;  
            h2 = uicontrol(   panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                            'Position',positions(i,:)+[width*2,0,0,0],'Style','PushButton','Enable','inactive');            
            all_indexing(glb_idx).axis = 2;
            all_indexing(glb_idx).position = idx_per_axis;
            positions_all(glb_idx,:) = (positions(i,:)+[width*2,0,0,0]);
            if(xyz_selected{2}(idx_per_axis))
                set(h2,'String',tick_char);
            end
            handles_all(glb_idx) = h2;
            glb_idx = glb_idx + 1; 
        end
        
        if(mod(i,2) == 0)
            i_z = i_z + 1; 
            if(i_z<=nm_pos(3))
                h3 = uicontrol(   panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                                'Position',positions(i,:)+[width*3,0,0,0] ,'Style','PushButton','Enable','inactive');                
                idx_per_axis = (((nm_pos(1)-i)*20)/40)+1;
                all_indexing(glb_idx).axis = 3;
                all_indexing(glb_idx).position = idx_per_axis;
                positions_all(glb_idx,:) =(positions(i,:)+[width*3,0,0,0]);
                if(xyz_selected{3}(idx_per_axis))
                    set(h3,'String',tick_char);
                end
                handles_all(glb_idx) = h3;  
                glb_idx = glb_idx + 1;
            end
        end
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
                        [X_s,Y_s,Z_s] = meshgrid(xyz_mm{1}(xyz_selected{1}),xyz_mm{2}(xyz_selected{2}),xyz_mm{3}(xyz_selected{3}));
                        set(selected_scatter,'XData',X_s(:));
                        set(selected_scatter,'YData',Y_s(:));
                        set(selected_scatter,'ZData',Z_s(:));
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
                            if(~xyz_selected{all_indexing(pos_idx).axis}(all_indexing(pos_idx).position))
                                 set(handles_all(pos_idx),'String',tick_char);
                                 xyz_selected{all_indexing(pos_idx).axis}(all_indexing(pos_idx).position) = true;
                            else
                                set(handles_all(pos_idx),'String','');
                                xyz_selected{all_indexing(pos_idx).axis}(all_indexing(pos_idx).position) = false;
                            end
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
                [X_tmp,Y_tmp,Z_tmp] = meshgrid(xyz_mm{1}(xyz_selected{1}),xyz_mm{2}(xyz_selected{2}),xyz_mm{3}(xyz_selected{3}));
                xyz_mesh = [X_tmp(:),Y_tmp(:),Z_tmp(:)];
                delete(fig);
           case 'Cancel'
                close(fig);
       end
    end
    function fig_close(~,~)
        xyz_selected = xyz_selected_prev;
        [X_tmp,Y_tmp,Z_tmp] = meshgrid(xyz_mm{1}(xyz_selected{1}),xyz_mm{2}(xyz_selected{2}),xyz_mm{3}(xyz_selected{3}));
        xyz_mesh = [X_tmp(:),Y_tmp(:),Z_tmp(:)];
        delete(fig);
    end
end

