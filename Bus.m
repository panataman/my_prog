classdef Bus < handle % have to be handle class becouse of the speed
    %%Bus Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        bus_number % the number of the bus
        number_supermarkets % memorized how much supermarkets are connectet
        supermarkets % all supermarkets which are connected into bus
        grid_debit % the following electrical debit of the grid from this bus
	number_different_model_supermarkets % number of different model
	hourly_demand_day % hourly demand of the day
	hourly_demand_night % hourly demand of the night
    end % end properties
    
    methods
    % the constuctor of Bus class
        function obj = Bus( ...
				supermarkets_connected, ...
				bus_number, ...
				number_steps, ...
				days ...
			)
            obj.bus_number = bus_number; % save bus_number
            obj.grid_debit = 0; % grid_debit?
	    %
            for j = 1 : length([supermarkets_connected{1}{:,2}])
                if supermarkets_connected{1}{j,2} ~= 0

                        obj.supermarkets = [obj.supermarkets ...
				Supermarket({supermarkets_connected{1}{j,1}}, ...
				number_steps, days)];

			obj.number_supermarkets = [obj.number_supermarkets supermarkets_connected{1}{j,2}];
                else
                    obj.supermarkets = [obj.supermarkets 0];
                end
            end
	    obj.number_different_model_supermarkets = length(obj.number_supermarkets);
        end
        %%
     %    function [ r ] = bus_max_power_installed(obj)
     % % %        %BUS_MAX_POWER_INSTALLED estimates the power installed into the bus
     % % %        %   Detailed explanation goes here
     % % %        r = 0;
     % % %        for i = 1 : length(obj.supermarkets)
     % % %            r = r + obj.supermarkets(i).max_e_power_installed;
	    % end % end for
     % % %    end % end function bus_max_power_installed
     %    %%
     %    function [ r ] = bus_needed_power(obj)
     %        %BUS_NEEDED_POWER estimates the power which is needed for cooling
     %        %   on each bus
     %        r = 0;
     %        for i = 1 : length(obj.supermarkets)
     %            r = r + obj.supermarkets(i).supermarket_needet_power;
     %        end
        % end % end function bus_needed_power

     end % methods end

end

