classdef model < handle    
    properties (SetObservable)
        density
        volume
        units
        mass
    end
        
    methods
        function obj = model()
            obj.reset();
        end
                
        function reset(obj)
            obj.density = 0;
            obj.volume = 0;
            obj.units = 'english';
            obj.mass = 0;
        end
        
        function setDensity(obj,density)
            obj.density = density;
        end
        
        function setVolume(obj,volume)
            obj.volume = volume;
        end
        
        function setUnits(obj,units)
            obj.units = units;
        end
        
        function calculate(obj)
            obj.mass = obj.density * obj.volume;
        end
    end
end