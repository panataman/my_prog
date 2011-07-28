classdef Power_grid < handle % handle because of call by reference (speed)
    %Power_grid Summary of this class goes here
    % Detailed explanation goes here

    properties
	busses %
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
	% properties busses of object Power_grid
		for i = 1 : configuration_grid{end,1}
			obj.busses = [obj.busses ...
				Bus({configuration_grid{i,2}}, ...
				i, ...
				number_steps, ...
				days)];
		end
	    % here hourly_demand_day and %_night calculation starts
            % const_a = 0;
            % const_b = 0;
            % for b = 1 : length(obj.busses)
		% observance of all supermarkets on each bus
                % for s = 1 : length(obj.busses(b).number_supermarkets)
		    % observance of all refrigerators of each supermarket
                %     for r = 1 : length([obj.busses(b).supermarkets(s).refrigerators])

                %         const_a = const_a + (obj.busses(b).supermarkets(s).refrigerators(r).increased_demand_heat_power_day / ...
			    % 3.6 + obj.busses(b).supermarkets(s).refrigerators(r).averaged_losses) / ...
			    % obj.busses(b).supermarkets(s).refrigerators(r).epsilon;

                %         const_b = const_b + obj.busses(b).supermarkets(s).refrigerators(r).averaged_losses / ...
                %             obj.busses(b).supermarkets(s).refrigerators(r).epsilon;
                %     end
                % end
		% !!!!!!!!!CLEAR WHAT IT IS THE FUCK!!!!!!!!!!!!
                % if obj.busses(b).number_supermarkets ~= 0
                %     const_a = const_a * obj.busses(b).number_supermarkets;
                %     const_b = const_b * obj.busses(b).number_supermarkets;
                %     obj.hourly_demand_day = const_a / 1e6;
                %     obj.hourly_demand_night = const_b / 1e6;
                % end
            % end
        end
    end
end
