function [Cooling_results] = runCooling( bus_results_DA, ...
					 bus_results_RT, ...
					 cooling, ... % info about connection cooling inside power grid
					 simulationcase, ...
					 how_many_days, ...
					 day_of_year, ...
					 casefile, ...
					 actual_simulation_folder, ...
					 case_folder_input ...
					 )
%RUNcooling executes the cooling storages at given busses
%   The storage is calculated depending on the simulation case. DA_DAST
%   calculates storage power once a day. Additionally, RT_RTST calculates
%   the LMP every hour. This is the real-time adjustment.
%   here are indices of time the simulation should run

load([case_folder_input,'detailed_input_data\input_variables.mat'])
% initialisation of matrices for calculation results
singletype_storage_load_cooling_DA = zeros(number_of_buses,24,different_types_of_storage_CO,365);
singletype_storage_load_cooling_RT = zeros(number_of_buses,24,different_types_of_storage_CO,365);

% initialisation power grid object system
grid_system = Power_grid(cooling, how_many_days);

switch simulationcase

case 'DA_DAST'
% bus wise calculation of day ahead storage

for i=day_of_year:(day_of_year+how_many_days-1)
    for j=1:different_types_of_storage_CO
        disp(['Calculate storage for: Cooling load(',simulationcase,'): Type ', num2str(j), ' for Day ',num2str(i)]);
        lmp_mat_day_last=zeros(24,1);
        for k=1:number_of_buses
       %lmp_mat_day: 24x1 ->this is the lmp at that bus for 24 hours, i.e. during that day
        lmp_mat_day = bus_results_DA(k,14,:,i);
        lmp_mat_day=squeeze(lmp_mat_day);

            if cooling_load_at_each_bus(k,j) ~= 0;
                if j==2 && sum(hourly_seasonal_cooling(k,:,i))==0;
                else
                    if k>1 && (cooling_load_at_each_bus(k,j)==cooling_load_at_each_bus(k-1,j)) && (sum(lmp_mat_day-lmp_mat_day_last<1e-8)/24)
                    singletype_storage_load_cooling_DA(k,:,j,i)=singletype_storage_load_cooling_DA(k-1,:,j,i);
                    else
                    singletype_storage_load_cooling_DA(k,:,j,i) = storageDA_cooling(lmp_mat_day,hourly_constant_cooling,hourly_seasonal_cooling,i,k,j);
                    end
                end
            end
            lmp_mat_day_last=lmp_mat_day;
        end %of for with k (buses)
     end %of for with j (types)
end %of for with i (days)

case 'RT_RTST'
% bus wise calculation of real time storage
% compares RT and DA LMP with storage!
for i=day_of_year:(day_of_year+how_many_days-1)
  for j=1:different_types_of_storage
    disp(['Calculate storage for: SmartMeter load(',simulationcase,'): Type ', num2str(j), ' for Day ',num2str(i)]);
        for k=1:number_of_buses
           %lmp_mat_day: 1x24
            lmp_mat_day_DA = bus_results_DA(k,14,:,i);
            lmp_mat_day_RT = bus_results_RT(k,14,:,i);
            lmp_mat_day_DA=squeeze(lmp_mat_day_DA);
            lmp_mat_day_RT=squeeze(lmp_mat_day_RT);

        if amount(k,j) == 0;
               singletype_storage_load_smartmeter_RT(k,:,j,i) = 0;
        else
        stor_mat = []; %saves(appending) the calculated loads for the actual hour. Here it is initialized
           for l=1:24 %hourly calculation of RT adjustment

                    % optimization with: former and current RT prices and
                    % future DA prices
                    lmp_mat_day = [lmp_mat_day_RT(1:l);lmp_mat_day_DA(l+1:24)]; %becomes shorter for each hour the day advances

                    % singletype_storage_load_smartmeter_DA(k,:,j,i) = storageDA_smartmeter(lmp_mat_day) * amount(k,j);
           %end
                    % interested in storage load of actual hour + actual

                        [RT_load] = storageRT_smartmeter(lmp_mat_day,stor_mat,l,j);
                       % load_check = sum(load);

                        load_tmp = RT_load(l);


              singletype_storage_load_smartmeter_RT(k,l,j,i) =load_tmp* amount(k,j);
                    stor_mat = squeeze(singletype_storage_load_smartmeter_RT(k,:,j,i)/percentage_at_each_bus(k,j))';
          end %hour
        end %of if
        end %buses
    end %types
end % days

%total load of all subtypes from this type of storage (smartmeter) together:
%bus_storage_smartmeter_RT(hours,buses,days)
for i=1:different_types_of_storage
    storage_smartmeter_total_load_RT(:,:,:)=storage_smartmeter_total_load_RT(:,:,:)+squeeze(singletype_storage_load_smartmeter_RT(:,:,i,:));
end


end % switch
end


