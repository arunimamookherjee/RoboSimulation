classdef Robot < simiam.ui.Drawable

    
    properties
        supervisor
        
        driver
        optitrack
        hostname
        port
        islinked
    end
    
    methods
        function obj = Robot(parent, start_pose)
            obj = obj@simiam.ui.Drawable(parent, start_pose);
            obj.islinked = false;
            obj.driver = [];
            obj.optitrack = [];
        end
        
        function attach_supervisor(obj, supervisor)
            obj.supervisor = supervisor;
            supervisor.attach_robot(obj);
        end
        
        % Hardware connectivty related functions        
        function open_hardware_link(obj)
            obj.driver.init();
            obj.islinked = true;
        end
        
        function close_hardware_link(obj)
            obj.islinked = false;
            obj.driver.close();
        end
    end
    
end

