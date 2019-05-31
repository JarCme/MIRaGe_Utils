function [xyz_selected,xyz_mesh] = OOG_dialog(varargin)
   
    nm_pos = 25;
    
    xyz_mm = {1:25};
    
    
    cps = [154.5;221;115];  % center position of the volume
    nm_sources_per_axes = [24;19;9]; 
    corners_pos = [182,127;211.5,233;115,115];
    
    switch nargin
        case 0
            xyz_selected = false(nm_pos,1);
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
    
    [positions_OOG] = prepare_OOG(cps,corners_pos,nm_sources_per_axes);
    
    positions_to_plot = zeros(25,2);
    positions_to_plot(:,1) = positions_OOG(1,:)'/100;
    positions_to_plot(:,2) = positions_OOG(2,:)'/100;
    ax = axes(      fig,'Units','normalized','OuterPosition',[0.22,.06,1-0.23,1-0.07]);
    X = positions_to_plot(:,1);
    Y = positions_to_plot(:,2);
    X_s = positions_to_plot(xyz_selected,1);
    Y_s = positions_to_plot(xyz_selected,2);
    measured_scatter = scatter(ax,X(:),Y(:),'MarkerFaceAlpha',0.5,'MarkerEdgeAlpha',0.5,'DisplayName','Measured positions');
    hold(ax,'on');
    selected_scatter = scatter(ax,X_s(:),Y_s(:),'MarkerFaceColor','red','MarkerEdgeColor','red','DisplayName','Selected positions');
    axis(ax,'equal');
    xlim(ax,[0,6]);
    ylim(ax,[0,6]);
    xlabel(ax,'room length');
    ylabel(ax,'room width');
    leg = legend(ax,[measured_scatter,selected_scatter]);
    set(leg,'Units','normalized');
    set(leg,'Position',[0.24,0.85,0.2,0.12]);
    
    for pos = 1:3
        text(ax,X(pos)+0.05,Y(pos)+0.05,num2str(pos),'FontSize',6,'Color','black','clipping','on');
    end
    
    for pos = 4:6
        text(ax,X(pos)+0.05,Y(pos)+0.05,num2str(pos),'FontSize',6,'Color','black','clipping','on');
    end
    
    for pos = 7:9
        text(ax,X(pos)+0.05,Y(pos)-0.05,num2str(pos),'FontSize',6,'Color','black','clipping','on');
    end
    
    for pos = 10:length(positions_OOG)
        text(ax,X(pos)+0.05,Y(pos)+0.05,num2str(pos),'FontSize',6,'Color','black','clipping','on');
    end
    
    hold(ax,'off');

    nm_rows = nm_pos+2;
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
                'Position',positions(end-1,:),'Style','Text','String','pos idx', ...
                'HorizontalAlignment','center','FontName','FixedWidth','Enable','inactive'); 
            
            
    
    for i = nm_rows-2:-1:1
        uicontrol(  panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                    'Position',positions(i,:),'Style','Text','String',num2str((nm_pos(1)-i)+1), ...
                    'HorizontalAlignment','center','FontName','FixedWidth','Enable','inactive'); 
                  
        h1 = uicontrol(   panel_,'Units','normalized','FontUnits','normalized','FontSize', font_normalized_size,...
                        'Position',positions(i,:)+[width*1,0,0,0],'Style','PushButton','Enable','inactive');        
        idx_per_axis = (((nm_pos(1)-i)*20)/20)+1;
        all_indexing(glb_idx).axis = 1;
        all_indexing(glb_idx).position = idx_per_axis;
        positions_all(glb_idx,:) = (positions(i,:)+[width*1,0,0,0]);
        if(xyz_selected(idx_per_axis))
            set(h1,'String',tick_char);
        end
        handles_all(glb_idx) = h1;
        glb_idx = glb_idx + 1;
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
                        X_s = positions_to_plot(xyz_selected,1);
                        Y_s = positions_to_plot(xyz_selected,2);
                        set(selected_scatter,'XData',X_s(:));
                        set(selected_scatter,'YData',Y_s(:));
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
                            if(~xyz_selected(all_indexing(pos_idx).position))
                                 set(handles_all(pos_idx),'String',tick_char);
                                 xyz_selected(all_indexing(pos_idx).position) = true;
                            else
                                set(handles_all(pos_idx),'String','');
                                xyz_selected(all_indexing(pos_idx).position) = false;
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
                xyz_mesh = xyz_mm{1}(xyz_selected);  
                delete(fig);
           case 'Cancel'
                close(fig);
       end
    end
    function fig_close(~,~)
        xyz_selected = xyz_selected_prev;
        xyz_mesh = xyz_mm{1}(xyz_selected);
        delete(fig);
    end

    function [positions] = prepare_OOG(center_position,corners_pos,nm_sources_per_axes)
        grid_size = [2*(nm_sources_per_axes(1:2)-1);4*(nm_sources_per_axes(3))];
        b = [(grid_size(1)/2);(grid_size(2)/2);0];
        a = [corners_pos(1,1)-center_position(1);corners_pos(2,1)-center_position(2);0];
        theta = -(atan(b(2)/b(1))-atan(a(2)/a(1)));
        %     theta = 0;
        %     R = [cos(theta) -sin(theta); sin(theta) cos(theta)];

        %     sources_pos_x = linspace(center_position(1)-grid_size(1)/2,center_position(1)+grid_size(1)/2,nm_sources_per_axes(1)).';
        %     sources_pos_y = linspace(center_position(2)-grid_size(2)/2,center_position(2)+grid_size(2)/2,nm_sources_per_axes(2)).';
        %     sources_pos_z = linspace(center_position(3)-grid_size(3)/2,center_position(3)+grid_size(3)/2,nm_sources_per_axes(3)).';
        GX = [  center_position(1)-(grid_size(1)/2)-5;
                center_position(1)-(grid_size(1)/2)-10;
                center_position(1)-(grid_size(1)/2)-20;
                center_position(1)+(grid_size(1)/2)+5;
                center_position(1)+(grid_size(1)/2)+10;
                center_position(1)+(grid_size(1)/2)+20;
                center_position(1);
                center_position(1);
                center_position(1);];
        GY = [  center_position(2);
                center_position(2);
                center_position(2);
                center_position(2);
                center_position(2);
                center_position(2);
                center_position(2)+(grid_size(2)/2)+5;
                center_position(2)+(grid_size(2)/2)+10;
                center_position(2)+(grid_size(2)/2)+20;];
        GZ = center_position(3)*ones(size(GX));

        v = [GX(:),GY(:)].';

        x_center = center_position(1);
        y_center = center_position(2);

        center = repmat([x_center; y_center], 1, length(v));  
        R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        vo = R*(v - center) + center;
        x_rotated = vo(1,:).';
        y_rotated = vo(2,:).';

        GX = x_rotated;
        GY = y_rotated;

        GX = [  GX; 100; 100; 100; 100; 100; 200; 300; 400; 500; 500; 500; 500; 500; 400; 300; 200];

        GY = [  GY; 100; 200; 300; 400; 500; 500; 500; 500; 500; 400; 300; 200; 100; 100; 100; 100];

        GZ = [  GZ; 100*ones(16,1) ];
        %     for ax = axes_list
        % 
        %         hold(ax,'on');
        %         scatter3(ax,GX(:),GY(:),GZ(:),30,'x','filled','MarkerEdgeColor','Red','MarkerFaceColor','Red','DisplayName','OOG Positions');
        %         for pos = 1:length(GX(:))
        %             text(ax,GX(pos)+5,GY(pos)+5,GZ(pos)+5,num2str(pos),'FontSize',6,'Color','red','clipping','on');
        %         end
        %         hold(ax,'off');
        %     end
        positions = [GX(:),GY(:),GZ(:)].';
    end
end

