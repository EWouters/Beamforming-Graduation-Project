classdef controller < handle
    properties
        model
        view
    end
    
    methods
        function obj = controller(model)
            obj.model = model;
            obj.view = view(obj);
        end
        
        function setDensity(obj,density)
            obj.model.setDensity(density)
        end
        
        function setVolume(obj,volume)
            obj.model.setVolume(volume)
        end
        
        function setUnits(obj,units)
            obj.model.setUnits(units)
        end
        
        function calculate(obj)
            obj.model.calculate()
        end
        
        function reset(obj)
            obj.model.reset()
        end
    end
end