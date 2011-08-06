classdef Refrigerator < handle
    %% REFRIGERATOR class created from Juri Steblau 09.03.10
    %   this class is a part of an program calls SuperM which simulates an
    %   supermarket as a cooling energy storage
    %%
    properties
	fridge_detector % the identification number of refrigerator
	energy_consumption_day % the maxim on power, the refrigerator can use
	epsilon % the ...
	compressor_quotient
	cooling_power
	temperature_outside_fridge
	mass_stored % the mass of stored product
	specific_heat_capacity % for each mass
	cooling_room_temperature_min % the minimum on temperature
	cooling_room_temperature_max % the maximum on temperature
	averaged_cooling_room_temperature
	temperature_history % temperature into fridge
	electric_power_consumption_history % the power consumption real
	averaged_transmission_losses
	modified_heat_transmission_coefficient
	increased_demand_heat_power_day % rest_day_power
	factor_cooling_reducer
	fridge_number_scale % factor for scale number fridges
    end % properties end
    %%
    methods
        function obj = Refrigerator( fridge_config, number_steps, days ) % fridge constructor
	    % save the object properties
	    obj.fridge_detector = fridge_config{1,1}{1}; % kind of fridge
            obj.energy_consumption_day = fridge_config{1,1}{2}; % in Wh/h
            obj.epsilon = fridge_config{1,1}{3};
            obj.compressor_quotient = fridge_config{1,1}{4};
            obj.cooling_power =  fridge_config{1,1}{5};
            obj.temperature_outside_fridge = fridge_config{1,1}{8};
            obj.mass_stored = fridge_config{1,1}{9};
            obj.specific_heat_capacity =fridge_config{1,1}{10};
            obj.cooling_room_temperature_min = fridge_config{1,1}{11};
            obj.cooling_room_temperature_max = fridge_config{1,1}{12};
            obj.averaged_cooling_room_temperature = fridge_config{1,1}{13};
            obj.temperature_history = zeros(number_steps, days);
            obj.electric_power_consumption_history = zeros(number_steps, days);
            obj.temperature_history(1,1) = obj.averaged_cooling_room_temperature;
	    obj.factor_cooling_reducer = fridge_config{1,1}{15};
	    obj.fridge_number_scale = fridge_config{2};
	    obj.modified_heat_transmission_coefficient = fridge_config{1,1}{6} .* ...
				fridge_config{1,1}{7}; % Watt/K end
	    % estimation of averaged transmission losses
	    obj.averaged_transmission_losses = sum( ...
		obj.modified_heat_transmission_coefficient .* ...
		( obj.temperature_outside_fridge - ...
		obj.averaged_cooling_room_temperature ));

            % this function estimates the rest of the power
            if obj.fridge_detector == 1 % the one means, PLUG IN FRIDGE
                % this function estimates the rest of the power
		% this function estimates the electrical energy of the fridge
		% for 24h in kJ (eigentlich Leistung)
		obj.increased_demand_heat_power_day = ...
			obj.energy_consumption_day * obj.compressor_quotient * ...
			obj.factor_cooling_reducer * obj.epsilon * 3.6 / ...
			12 - 2 * 3.6 * obj.averaged_transmission_losses;
            else
		% COMBINE FRIDGE
                obj.increased_demand_heat_power_day = (obj.cooling_power * ...
			obj.factor_cooling_reducer - ...
			obj.averaged_transmission_losses) * 3.6; % in kJ (eigentlich Leistung)
	    end % if end

        end % function constructor end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% ordinary object specific functions %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function r = sum_mass_times_capacity(obj)
        %% this function estimates a part of a main_equation
            % estimates mass specific heat-capacity
             r = sum(obj.specific_heat_capacity .* ...
		obj.mass_stored); % kJ/K
        end % function sum_mass_times_capacity end

        function [r, r_c_max]  = sum_transmission_losses(obj, ...
				number_steps, ...
				count_number_steps, ...
				count_number_day)
        %% this function sums transmission losses of the wall
            % estimates sum of all wall transmission losses into fridge
            r = 0;
            r_c_max = 0;

            for i = 1:length(obj.modified_heat_transmission_coefficient)
		% it is necessary if temperature outside the fridges is constant
		% to get vector for each time step
		if length(obj.temperature_outside_fridge(i)) == 1
                    n_temperature_outside_fridge = ...
			obj.temperature_outside_fridge(i) + zeros(1,number_steps);
		end % if end

		% VERY IMPORTANT estimates losses
                r = r + obj.modified_heat_transmission_coefficient(i) ...
			* (n_temperature_outside_fridge(count_number_steps) - ...
			obj.temperature_history(count_number_steps, count_number_day));
		% estimates maximal losses
                r_c_max = r_c_max + ...
			obj.modified_heat_transmission_coefficient(i) ...
			* (n_temperature_outside_fridge(count_number_steps) - ...
			obj.cooling_room_temperature_max);

	    end % for end

            r = r * 3.6; % transmission losses in kJ (in actual fact, POWER)

        end % function sum_transmission_losses end

        function [r, time_to_T_critical_max]  = sum_all_losses(obj, ...
				number_steps, ...
				count_number_steps, ...
				count_number_day, ...
				number_days)
        %% this function estimates the sum of the losses which can be
        %  the losses can be positive or negative

            % sum all fridge losses for step
            [sum_transmission_losses, sum_max_transmission_losses] = ...
				obj.sum_transmission_losses( ...
				number_steps, ...
                		count_number_steps, ...
				count_number_day);

	    % here the time_no_cooling or time to the temperature go critical
	    % will be estimated

	    % logarithmic estimation of maximal transmission losses
            Q_T_log_max = (sum_max_transmission_losses - ...
		sum_transmission_losses) / ...
		log(sum_max_transmission_losses / ...
		sum_transmission_losses);

            % estimation of time till maximal temperature will be achieved
            time_to_T_critical_max = ((obj.cooling_room_temperature_max - ...
		obj.temperature_history(...
				count_number_steps, ...
				count_number_day)) * ...
				obj.sum_mass_times_capacity) / ...
				(Q_T_log_max * 3.6);

	    % inspect what kind of day hour is it. Necessary because of
	    % different level of losses
	    if count_number_steps <  9 || count_number_steps >  20
                % here only the transmission losses influencing the temperature
                r = sum_transmission_losses; %
            else
                % here in addition to the transmission losses the static losses
		% of day activities influencing the temperature
                r = sum_transmission_losses + ...
			obj.increased_demand_heat_power_day;

                time_to_T_critical_max = ((obj.cooling_room_temperature_max - ...
			obj.temperature_history(count_number_steps, ...
			count_number_day)) * obj.sum_mass_times_capacity) / ...
			(Q_T_log_max * 3.6  + ...
				obj.increased_demand_heat_power_day);
	    end % if else end
        end % function sum_all_losses end

        function r = capacity_estimator(obj, ...
				count_number_steps, ...
				count_number_day, ...
				Q_losses)
	%% this function estimates the heat power, which can be stored into the
	%fridge if the fridge temperature is T(i).

             r = Q_losses - (obj.cooling_room_temperature_min - ...
		obj.temperature_history(count_number_steps, count_number_day)) * ...
		obj.sum_mass_times_capacity; % in kJ

        end % function capacity_estimator end

        function r = temperature_change(obj, ...
				number_steps, ...
				count_number_steps, ...
				count_number_day, ...
				cooling, ...
				Q_losses)
        %% this function estimates the temperature in the fridge
            Q = 0.8 * (Q_losses - cooling);
            %% this is the main equation
            r = Q / obj.sum_mass_times_capacity + ...
		obj.temperature_history(count_number_steps, ...
				count_number_day);
            %%
            if count_number_steps == number_steps
                obj.temperature_history(1,count_number_day + 1) = r;
                obj.electric_power_consumption_history(1,count_number_day + 1) = ...
				cooling / obj.epsilon;
            else
                obj.temperature_history(count_number_steps + 1, ...
				count_number_day) = r;
                obj.electric_power_consumption_history(count_number_steps + ...
				1, count_number_day) = cooling / obj.epsilon;
	    end % if else end
        end % function main equation end
     end % methods end
end % class end
