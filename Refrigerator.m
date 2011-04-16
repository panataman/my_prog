classdef Refrigerator < handle
    %% REFRIGERATOR class created from Juri Steblau 09.03.10
    %   this class is a part of an programm calls SuperM which simulates an
    %   supermarket as a cooling energy storage

    properties
        fridge_detector % the identification number of refrigerator
        masse_stored % the mass of stored product
        specific_heat_capacity % for each mass
        epsilon % the ...
        energy_consumption_day % the maximun on power, the refrigerator can use
        temperature_min % the minimun on temperature, the product can be
        temperature_max % the maximum on temperature, the product can be
        current_temperature_year % current temperature into freedge
        current_temperature_capacity % current temperature into freedge
        electric_power_consum % the power real consumed
        compressor_quotient
        averaged_cooling_room_temperature
        cooling_power
        averaged_losses
        vector_wall_area_times_heat_transmission_coefficient
        temperature_outside_wall
        increased_demand_heat_power_day % rest_day_power
    end % properties end
    methods
        function obj = Refrigerator(...
                fridge_detector, ... % the identification number of refrigerator
                epsilon, ... 
                masse_stored, ... % the mass of stored product
                specific_heat_capacity, ... % for each mass
                energy_consumption_day, ...
                temperature_min, ...
                temperature_max, ...
                wall_area, ...
                heat_transmission_coefficient, ...
                temperature_outside_wall, ...
                compressor_quotient, ...
                averaged_cooling_room_temperature, ...
                cooling_power, ...
                number_steps, ...
                days)
	    % all relevant information of one fridge will save in the objekt refrigerator
            obj.fridge_detector = fridge_detector; % kind of fridge
            obj.masse_stored = masse_stored;
            obj.specific_heat_capacity = specific_heat_capacity; % of mass stored
            obj.epsilon = epsilon;
            obj.energy_consumption_day = energy_consumption_day; % in Wh/h
            obj.temperature_min = temperature_min;
            obj.temperature_max = temperature_max;
            obj.current_temperature_year = zeros(number_steps, days);
            obj.current_temperature_capacity = zeros(number_steps, days);
            obj.electric_power_consum = zeros(number_steps, days);
            obj.compressor_quotient = compressor_quotient;
            obj.averaged_cooling_room_temperature = averaged_cooling_room_temperature;
            obj.cooling_power =  cooling_power;
            obj.temperature_outside_wall = temperature_outside_wall;
            obj.current_temperature_year(1,1) = averaged_cooling_room_temperature;
            for i = 1:length(wall_area)
                % estimates wall-area-specific ability to transport heat
		% necessary for transmission losses
                obj.vector_wall_area_times_heat_transmission_coefficient = ...
                    [obj.vector_wall_area_times_heat_transmission_coefficient wall_area(i) * heat_transmission_coefficient(i)]; % Watt/K
            end

	    % estimation of averaged transmission losses
            r = 0;
            for i = 1:length(wall_area)
                r = r + obj.vector_wall_area_times_heat_transmission_coefficient(i) * ...
                    (temperature_outside_wall(i) - obj.averaged_cooling_room_temperature); % in Watt
	    end % for end
            obj.averaged_losses = r;

            %% this functin estimates the rest of the power
            if obj.fridge_detector == 1 % the one means, PLUG IN FRIDGE
                % this functin estimates the rest of the power
                % this function estimates the electrical energy of the fridge for 24h
                estimator_compressor_energy = obj.energy_consumption_day * obj.compressor_quotient; % Wh
                % this function estimates the needet power in the night
                estimator_nigth_energy = (obj.averaged_losses * 12) / (obj.epsilon * 1e3); % kWh
                % this function estimates the day electrical energy
                estimator_day_e_power = (estimator_compressor_energy / 1e3 - estimator_nigth_energy) / 12; % kW
                % this function estimates the licht day heat power
                estimator_day_energy_heat = estimator_day_e_power * obj.epsilon; % in kW
                % THIS IS THE REST DAY ESTIMATOR FOR PLUG IN FRIDGE
                obj.increased_demand_heat_power_day = (estimator_day_energy_heat - obj.averaged_losses / 1e3) * 3.6e3; % in kJ (eigentlich Leistung)
            else
		% COMBINE FRIDGE
                obj.increased_demand_heat_power_day = (obj.cooling_power - obj.averaged_losses) * 3.6; % in kJ (eigentlich Leistung)
	    end % if end

        end % function constructor end

        function r = sum_mass_times_capacity(obj)
        %% this function estimates a part of a main_eqation
            % estimates mass specific heat-capacity
            r = 0;
            for i = 1:length(obj.masse_stored)
                r = r + obj.specific_heat_capacity(i) * obj.masse_stored(i); % kJ/K
	    end % for end
        end % function sum_mass_times_capacity end

        function [r, r_c_max]  = sum_transmission_losses(obj, number_steps, count_number_steps, count_number_day)
        %% this function sums transmission losses of the wall
            % estimates sum of all wall transmission losses into fridge
            r = 0;
            r_c_max = 0;

            for i = 1:length(obj.vector_wall_area_times_heat_transmission_coefficient)
		% it is nessesary if temperature outside the fridges is constant to get vector for each time step
                if length(obj.temperature_outside_wall(i)) == 1
                    n_temperature_outside_wall = obj.temperature_outside_wall(i) + zeros(1,number_steps);
		end % if end

		% VERY IMPORTANT estimates current losses
                r = r + obj.vector_wall_area_times_heat_transmission_coefficient(i) * (n_temperature_outside_wall(count_number_steps) - ...
                    obj.current_temperature_year(count_number_steps, count_number_day));
		% estimates maximal losses
                r_c_max = r_c_max + obj.vector_wall_area_times_heat_transmission_coefficient(i) * (n_temperature_outside_wall(count_number_steps) ...
		    - obj.temperature_max);

	    end % for end

            r = r * 3.6; % transmission losses in kJ (in actual fact, POWER)

        end % function sum_transmission_losses end

        function [r, r_c_max, time_to_T_critical_max]  = sum_all_losses(obj, number_steps, count_number_steps, count_number_day, number_days)
        %% this function estimates the sum of the losses which can be
        %  the losses can be positiv or negativ

            r_c_max = 0;

            % sum all fridge losses for current step
            [sum_current_transmission_losses, sum_max_transmission_losses] = obj.sum_transmission_losses(number_steps, ...
                count_number_steps, count_number_day);

            % here the time_no_cooling or time to the temperature go critical will be estimatet

	    % logarithmic estimation of maximal transmission losses
            Q_T_log_max = (sum_max_transmission_losses - sum_current_transmission_losses) / ...
	               log(sum_max_transmission_losses / sum_current_transmission_losses);

            % estimation of time till maximal temperature will be achieved
            time_to_T_critical_max = ((obj.temperature_max - obj.current_temperature_year( ...
                count_number_steps, count_number_day)) * obj.sum_mass_times_capacity)/ (Q_T_log_max * 3.6);

            % inspect what kind of dayhour is it. Nessesary because of different level of losses
            if count_number_steps <  9 || count_number_steps >  20
                % here only the transmission losses influencing the temperature
                r = sum_current_transmission_losses; %
                r_c_max = sum_max_transmission_losses; %
            else
                % here in addition to the transmission losses the static losses of day activies influencing the temperature
                r = sum_current_transmission_losses + obj.increased_demand_heat_power_day;

                time_to_T_critical_max = ((obj.temperature_max - obj.current_temperature_year(count_number_steps, count_number_day)) * ...
		    obj.sum_mass_times_capacity) / (Q_T_log_max * 3.6  + obj.increased_demand_heat_power_day);

	    end % if else end
        end % function sum_all_losses end

        function r = estimator_full_heat_capacity(obj, count_number_steps, count_number_day, Q_losses)
        %% this function estimates the heat power, which can be stored into the fridge if the fridge temperature is T(i).

             r = Q_losses - (obj.temperature_min - obj.current_temperature_year(count_number_steps, count_number_day)) * ...
	         obj.sum_mass_times_capacity; % in kJ

        end % function estimator_full_heat_capacity end

        function r = main_equation(obj, number_steps, count_number_steps, count_number_day, ~, ~, cooling, Q_losses)
        %% this function estimates the current temperature in the fridge

            Q =(Q_losses - cooling);

            %% this is the main equation
            r = Q / obj.sum_mass_times_capacity + obj.current_temperature_year(count_number_steps, count_number_day);

            %% decision factor for cooling strategy
            temperature_capacity = (obj.temperature_max - r) / (obj.temperature_max - obj.temperature_min);

            %%
            if count_number_steps == number_steps

                obj.current_temperature_year(1,count_number_day + 1) = r;
                obj.electric_power_consum(1,count_number_day + 1) = cooling / obj.epsilon;
                obj.current_temperature_capacity(1,count_number_day + 1)  = temperature_capacity;

            else

                obj.current_temperature_year(count_number_steps + 1, count_number_day) = r;
                obj.electric_power_consum(count_number_steps + 1, count_number_day) = cooling / obj.epsilon;
                obj.current_temperature_capacity(count_number_steps + 1, count_number_day) = temperature_capacity;

	    end % if else end
        end % function main equation end
     end % methods end
end % class end
