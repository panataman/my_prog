NK_KT_S = { ...
    1, ... % the number decides which kind of fridge is installed one means plug in fridge or two combine fridge
    4.7e3, ... % energy consumption per day Wh/24h
    2, ... % epsilon
    0.66, ... % compressor quotient
    0, ... % cooling power in W
    [16.4 6.7], ... % area_wall
    [0.38 0.38], ... % heat_transmission_coefficient
    [19 15], ... % temperature_outside
    [200 200]... % masse_stored
    [2.3 3.52], ... % specific_heat_capacity for each mass
    0, ... % temperature_min in C°
    4, ... % temperature_max in C°
    2, ... % averaged cooling room temperature in C°
    0, ... % refrigerating capacity
    0.75 ... % factor for reducing of cooling demand
    };

TK_TKT_S = { ...
    1, ... % the number decides which kind of fridge is installed one means plug in fridge or two combine fridge
    7.4e3, ... % energy consumption per day Wh/24h
    1.5, ... % epsilon
    0.66, ... % compressor quotient
    0, ... % cooling power in W
    [36.9 16.8] ... % area_wall
    [0.38 0.38], ... % heat_transmission_coefficient
    [19 15], ... % temperature_outside
    [480 840 360 756]... % masse_stored
    [1.76 1.76 1.38 1.91], ... % specific_mass_capacity
    -26, ... % temperature_min in C��
    -18, ... % temperature_max in C��
    -22, ... % averaged cooling room temperature in C��
    0, ... % refrigerating capacity
    0.75}; % factor for reducing of cooling demand

NK_KR_V = { ...
    2, ... % the number decides which kind of fridge is installed one means plug in fridge or two combine fridge
    0, ... % energy consumption per day Wh/24h
    2, ... % epsilon
    0, ... % compressor quotient
    28.3e3, ... % cooling power in W
    [40.2 68.8 24.3], ... % area_wall
    [1.53 0.62 0.38], ... % heat_transmission_coefficient
    [19 19 15], ... % temperature_outside
    [1210 1050 2520], ... % masse_stored
    [2.51 2.3 3.85], ... % specific_mass_capacity
    2, ... % temperature_min in C��
    8, ... % temperature_max in C��
    5, ... % averaged cooling room temperature in C��
    0, ... % refrigerating capacity
    0.75}; % factor for reducing of cooling demand

NK_KZ = { ...
    2, ... % refrigeration unit
    0, ... % energy consumption per day Wh/24h
    2, ... % epsilon
    0, ... % compressor quotient
    830, ... % cooling power in W
    [30.7], ... % area_wall
    [0.26], ... % heat_transmission_coefficient
    [15], ... % temperature_outside
    [1440 2304], ... % masse_stored
    [2.51 3.85], ... % specific_mass_capacity
    1, ... % temperature_min in C��
    5, ... % temperature_max in C��
    3,  ... % averaged cooling room temperature in C��
    0, ... % refrigerating capacity
    1}; % factor for reducing of cooling demand
    
TK_KZ = { ...
    2, ... % refrigeration unit
    0, ... % energy consumption per day Wh/24h
    1.5, ... % epsilon
    0, ... % compressor quotient
    1060 ... % cooling power in W
    [30.7], ... % area_wall
    [0.21], ... % heat_transmission_coefficient
    [15], ... % temperature_outside
    [1522 1384], ... % masse_stored
    [1.76 1.76], ... % specific_mass_capacity
    -26, ... % temperature_min in C��
    -18, ... % temperature_max in C��
    -22, ... % averaged cooling room temperature in C��
    0, ... % refrigerating capacity
    1}; % factor for reducing of cooling demand
