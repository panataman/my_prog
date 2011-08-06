classdef Bus < handle % have to be handle class becouse of the speed
    %%Bus Summary of this class goes here
    %   Detailed explanation goes here
    %%
    properties
        bus_number % the number of the bus
        supermarkets % all supermarkets which are connected into bus
    end % end properties
    %%
    methods
    % the constuctor of Bus class
        function obj = Bus( ...
				supermarkets_connected, ...
				bus_number, ...
				number_steps, ...
				days ...
			)

            obj.bus_number = bus_number; % save bus_number
            for n = 1 : length([supermarkets_connected{1}{:,2}])
                if supermarkets_connected{1}{n,2} ~= 0
                        obj.supermarkets = [obj.supermarkets ...
				Supermarket( ...
					{supermarkets_connected{1}{n,1}}, ...
					supermarkets_connected{1}{n,2}, ...
					number_steps, ...
					days)];
                else
                    obj.supermarkets = [obj.supermarkets 0];
                end
            end
        end
        %%
     end % methods end

end

