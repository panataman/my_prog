classdef Supermarket < handle
    %SUPERMARKET Summary of this class goes here
    %   Detailed explanation goes here

    properties
        refrigerators
    end

    methods
        function obj = Supermarket(fridges, number_steps, days)
            for i = 1 : length(fridges{1})
                obj.refrigerators = [obj.refrigerators ...
                    Refrigerator( ...
		    fridges{1}{i}{1,1}{1},  ... % kind of fridge (plug-in ore combine)
                    fridges{1}{i}{1,1}{2},  ... % epsilon transpose cooficient
		    fridges{1}{i}{1,1}{3},  ... % masse stored
                    fridges{1}{i}{1,1}{4},  ... % specific_mass_capacity
		    fridges{1}{i}{2} * fridges{1}{i}{1,1}{5}, ... % energy consumption in ?????
                    fridges{1}{i}{1,1}{6},  ... % minimal temperature allowed in Celsius
		    fridges{1}{i}{1,1}{7},  ... % maximal temperature allowed in Celsius
                    fridges{1}{i}{1,1}{8},  ... % number of walls ? wozu?
		    fridges{1}{i}{1,1}{9},  ... % wall area
                    fridges{1}{i}{1,1}{10}, ... % heat transmission coefficient
		    fridges{1}{i}{1,1}{11}, ... % temperature outside the fridge
                    fridges{1}{i}{1,1}{12}, ... % refrigirating capacity
		    fridges{1}{i}{1,1}{13}, ... % compressor quotient
                    fridges{1}{i}{1,1}{14}, ... % averaged cooling room temperature in Celsius
		    fridges{1}{i}{1,1}{15}, ... % cooling power in Watt
                    number_steps,           ...
		    days                    ...
		    )];

            end
        end
    end

end
