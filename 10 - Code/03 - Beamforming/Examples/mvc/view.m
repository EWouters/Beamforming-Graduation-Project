classdef view < handle
    properties
        gui
        model
        controller
    end
    
    methods
        function obj = view(controller)
            obj.controller = controller;
            obj.model = controller.model;
            obj.gui = measures('controller',obj.controller);
            
            addlistener(obj.model,'density','PostSet', ...
                @(src,evnt)view.handlePropEvents(obj,src,evnt));
            addlistener(obj.model,'volume','PostSet', ...
                @(src,evnt)view.handlePropEvents(obj,src,evnt));
            addlistener(obj.model,'units','PostSet', ...
                @(src,evnt)view.handlePropEvents(obj,src,evnt));
            addlistener(obj.model,'mass','PostSet', ...
                @(src,evnt)view.handlePropEvents(obj,src,evnt));
        end
    end
    
    methods (Static)
        function handlePropEvents(obj,src,evnt)
            evntobj = evnt.AffectedObject;
            handles = guidata(obj.gui);
            switch src.Name
                case 'density'
                    set(handles.density, 'String', evntobj.density);
                case 'volume'
                    set(handles.volume, 'String', evntobj.volume);
                case 'units'
                    switch evntobj.units
                        case 'english'
                            set(handles.text4, 'String', 'lb/cu.in');
                            set(handles.text5, 'String', 'cu.in');
                            set(handles.text6, 'String', 'lb');
                        case 'si'
                            set(handles.text4, 'String', 'kg/cu.m');
                            set(handles.text5, 'String', 'cu.m');
                            set(handles.text6, 'String', 'kg');
                        otherwise
                            error('unknown units')
                    end
                case 'mass'
                    set(handles.mass,'String',evntobj.mass);
            end
        end
    end
end