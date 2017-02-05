classdef Obstacle < simiam.ui.Drawable
    
    
    properties
       type
    end
    
    methods
        function obj = Obstacle(parent, pose, geometry)
            obj = obj@simiam.ui.Drawable(parent, pose);
            obj.type = 'obstacle';
            geometry(:,3) = ones(size(geometry,1),1);
            surface = obj.add_surface(geometry, [1 0.6 0.4]);
            set(surface.handle_, 'EdgeColor', 'r');
        end
    end
    
end

