classdef Wall < handle
    %WALL
    %   Detailed explanation goes here

    properties
%        wall_length
%        wall_height
%	wall_area
%        heat_transmission_coefficient
        temperature_outside_wall
	wall_area_times_heat_transmission_coefficient
    end

    methods
        function obj = Wall(wall_length, wall_height, ...
                heat_transmission_coefficient, temperature_outside_wall)
%            obj.wall_length = wall_length;
%            obj.wall_height = wall_height;
%	    obj.wall_area = wall_length * wall_height;
%            obj.heat_transmission_coefficient = ...
%                heat_transmission_coefficient;
            obj.temperature_outside_wall = temperature_outside_wall;
	    obj.wall_area_times_heat_transmission_coefficient = ...
	        wall_length * wall_height * heat_transmission_coefficient;
        end
%        function r = area_times_htc(obj)
%            r = obj.wall_length * obj.wall_height * ...
%                obj.heat_transmission_coefficient;
%        end
      %  function r = volume_fridge(obj)
      %      r = 
      %  end
   end

end

