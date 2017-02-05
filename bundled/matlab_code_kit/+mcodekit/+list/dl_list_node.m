classdef dl_list_node < handle

   
    properties
        key_
        next_
        prev_
    end
    
    methods
        function obj = dl_list_node(key)
            obj.key_ = key;
            obj.next_ = [];
            obj.prev_ = obj.next_;
        end
    end
    
end

