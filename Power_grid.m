classdef Power_grid < handle % handle because of call by reference (speed)
    %Power_grid Summary of this class goes here
    % Detailed explanation goes here

    properties
	buses %
	hourly_demand_day %
	hourly_demand_night %
    end

    methods
    % invoke constructor class Power_grid
        function obj = Power_grid( ...
				configuration_grid, ...
				number_steps, ...
				days ...
				)
	% in configuration_grid all data about which how many supermarkets are
	% connected on which bus invoce constructor class Bus and save into
	% properties buses of object Power_grid
		for i = 1 : configuration_grid{end,1}
			obj.buses = [obj.buses ...
				Bus({configuration_grid{i,2}}, ...
				i, ...
				number_steps, ...
				days)];
		end
	obj.hourly_demand_day = 0;
	obj.hourly_demand_night = 0;
%	    here hourly_demand_day and %_night calculation starts
	    % observance of all supermarkets on each bus
            for b = 1 : length(obj.buses)

		% observance of all refrigerators of each supermarket
                for s = 1 : length(obj.buses(b).supermarkets)
		    super = obj.buses(b).supermarkets(s); % substitution
                    for r = 1 : length(super.refrigerators)

			refr = super.refrigerators(r); % substitution

			obj.hourly_demand_day = obj.hourly_demand_day + ...
			(refr.increased_demand_heat_power_day ...
			/ 3.6 + refr.averaged_transmission_losses) * ...
			refr.fridge_number_scale * ...
			super.supermarket_number_scale ...
			/ refr.epsilon;

			obj.hourly_demand_night = obj.hourly_demand_night + ...
			refr.averaged_transmission_losses * ...
			refr.fridge_number_scale * ...
			super.supermarket_number_scale ...
			/ refr.epsilon;
                    end
                end
            end
            obj.hourly_demand_day = obj.hourly_demand_day / 1e6;
            obj.hourly_demand_night = obj.hourly_demand_night / 1e6;
        end
    end
end
