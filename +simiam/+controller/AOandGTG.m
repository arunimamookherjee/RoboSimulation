classdef AOandGTG < simiam.controller.Controller

    properties
        
        % memory banks
        E_k
        e_k_1
        
        % gains
        Kp
        Ki
        Kd
        
        % plot support     
        p
        
        % sensor geometry
        calibrated
        sensor_placement
    end
    
    properties (Constant)
        inputs = struct('x_g', 0, 'y_g', 0, 'v', 0);
        outputs = struct('v', 0, 'w', 0)
    end
    
    methods
        
        function obj = AOandGTG()
            global f1 f2 persuit_E1 persuit_E2  
            obj = obj@simiam.controller.Controller('ao_and_gtg');            
            obj.calibrated = false;
            
            if persuit_E1==0 && persuit_E2==0
                obj.Kp = 5;
                obj.Ki = 0.01;
                obj.Kd = 0.01;
            else
                 obj.Kp = 10;
                 obj.Ki = 0.04;
            obj.Kd = 0.04;
            end
                
            
            
            obj.E_k = 0;
            obj.e_k_1 = 0;
            
%             obj.p = simiam.util.Plotter();
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
            
            % Compute the placement of the sensors
            if(~obj.calibrated)
                obj.set_sensor_geometry(robot);
            end
            
            % Unpack state estimate
            [x, y, theta] = state_estimate.unpack();
            
            % Poll the current IR sensor values 1-9
            ir_distances = robot.get_ir_distances();
            nSensors = numel(ir_distances);
            
            % Interpret the IR sensor measurements geometrically
            ir_distances_wf = obj.apply_sensor_geometry(ir_distances, state_estimate);            
            
            % 1. Compute the heading vector for obstacle avoidance
            
%             sensor_gains = [1 1 0.5 1 1];
            if (nSensors == 5)
                % QuickBot
                sensor_gains = [1 1 0.5 1 1];
            elseif (nSensors == 9)
                % Khepera3
                sensor_gains = 7*ones(1,nSensors);
            end
            
            u_i = (ir_distances_wf-repmat([x;y],1,nSensors))*diag(sensor_gains);
            u_ao = sum(u_i,2);
            
            % 2. Compute the heading vector for go-to-goal
            x_g = inputs.x_g;
            y_g = inputs.y_g;
            u_gtg = [x_g-x; y_g-y];
                        
            % 3. Blend the two vectors
            alpha = 0.25;
            u_ao_gtg = alpha*u_gtg+(1-alpha)*u_ao;
                        
            % 4. Compute the heading and error for the PID controller
            theta_ao_gtg = atan2(u_ao_gtg(2),u_ao_gtg(1));
            
            e_k = theta_ao_gtg-theta;
            e_k = atan2(sin(e_k),cos(e_k));
            
            e_P = e_k;
            e_I = obj.E_k + e_k*dt;
            e_D = (e_k-obj.e_k_1)/dt;
              
            % PID control on w
            v = inputs.v;
            w = obj.Kp*e_P + obj.Ki*e_I + obj.Kd*e_D;
            
            
            % Save errors for next time step
            obj.E_k = e_I;
            obj.e_k_1 = e_k;
                        
            % plot  
            obj.p.plot_2d_ref(dt, theta, theta_ao_gtg, 'c');
            
%             fprintf('(v,w) = (%0.4g,%0.4g)\n', v,w);

            v = 0.25/(log(abs(w)+2)+1);
            
            outputs.v = v;
            outputs.w = w;
        end
        
        % Helper functions
        
        function ir_distances_wf = apply_sensor_geometry(obj, ir_distances, state_estimate)
                    
            % 1. Apply the transformation to robot frame.
            nSensors = numel(ir_distances);
            
            ir_distances_rf = zeros(3,nSensors);
            for i=1:nSensors
                x_s = obj.sensor_placement(1,i);
                y_s = obj.sensor_placement(2,i);
                theta_s = obj.sensor_placement(3,i);
                
                R = obj.get_transformation_matrix(x_s,y_s,theta_s);
                ir_distances_rf(:,i) = R*[ir_distances(i); 0; 1];
            end
            
            % 2. Apply the transformation to world frame.
            
            [x,y,theta] = state_estimate.unpack();
            
            R = obj.get_transformation_matrix(x,y,theta);
            ir_distances_wf = R*ir_distances_rf;
            
            ir_distances_wf = ir_distances_wf(1:2,:);
        end
        
        function set_sensor_geometry(obj, robot)
            nSensors = numel(robot.ir_array);
            
            obj.sensor_placement = zeros(3,nSensors);
            for i=1:nSensors
                [x, y, theta] = robot.ir_array(i).location.unpack();
                obj.sensor_placement(:,i) = [x; y; theta];
            end                        
            obj.calibrated = true;
        end
        
        function R = get_transformation_matrix(obj, x, y, theta)
            R = [cos(theta) -sin(theta) x; sin(theta) cos(theta) y; 0 0 1];
        end
        
        function reset(obj)
            % Reset accumulated and previous error
            obj.E_k = 0;
            obj.e_k_1 = 0;
        end
        
    end
    
end

