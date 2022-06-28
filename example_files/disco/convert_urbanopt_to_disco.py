import pandas as pd
import json

def extract_lines(input_data):
    """
        Parameters
        ----------
        input_data: dict 
            The json file representing the input data.
            i.e. The urbanopt extended catalog that we're parsing

        Returns
        -------
        line_attributes: pd.DataFrame
            The dataframe of the lines in the format of the DISCO cost database

    """

    line_attributes= pd.DataFrame(columns=['Description','phases','voltage_kV','ampere_rating','line_placement','cost_per_m','cost_units'])
    
    
    all_wires = {}
    for wire in input_data['WIRES']['WIRES CATALOG']:
        all_wires[wire['nameclass']] = wire
    
    all_lines = input_data['LINES']
    count = 0
    for zone in all_lines:
        if not type(zone) == dict:
            continue
        for zone_name in zone:
            for line in zone[zone_name]:
                wires = line['Line geometry']
                first_wire_name = wires[0]['wire']
    
                Description = line['Name']
                phases = line['Nphases']
                voltage_kV = line['Voltage(kV)']
                wire_type = all_wires[first_wire_name]['type']
                ampere_rating = all_wires[first_wire_name]['ampacity (A)']
                if wire_type.startswith('OH'):
                    line_placement = 'overhead'
                elif wire_type.startswith('UG'):
                    line_placement = 'underground'
                else:
                    raise ValueError("Unexpected wire type in catalog")
                cost_per_m = float(line['Investment Cost (dolars/km)'])/1000
                cost_units = 'USD'
    
                line_attributes.loc[count] = [Description,phases,voltage_kV,ampere_rating,line_placement,cost_per_m,cost_units]
                count+=1
    
    return line_attributes

def extract_transformers(input_data):
    """
        Parameters
        ----------
        input_data: dict 
            The json file representing the input data.
            i.e. The urbanopt extended catalog that we're parsing

        Returns
        -------
        transformer_attributes: pd.DataFrame
            The dataframe of the transformers in the format of the DISCO cost database

    """

    transformer_attributes= pd.DataFrame(columns=['phases','primary_kV','secondary_kV','num_windings','primary_connection_type','secondary_connection_type','rated_kVA','cost','cost_units'])

    all_transformers = input_data['SUBSTATIONS AND DISTRIBUTION TRANSFORMERS']
    count = 0
    for zone in all_transformers:
        if not type(zone) == dict:
            continue
        for zone_name in zone:
            for transformer in zone[zone_name]:
                phases = transformer['Nphases']
                primary_kV = transformer['Primary Voltage (kV)']
                secondary_kv = transformer['Secondary Voltage (kV)']
                if transformer['Centertap']:
                    num_windings = '3'
                else:
                    num_windings = '1'
                connection_sp = transformer['connection'].split('-')
                primary_connection_type = connection_sp[0].lower()
                secondary_connection_type = connection_sp[1].lower()
                if 'Installed Power(kVA)' in transformer:
                    rated_kVA = transformer['Installed Power(kVA)']
                elif 'Installed Power(MVA)' in transformer:
                    rated_kVA = 1000*float(transformer['Installed Power(MVA)'])
                else:
                    raise ValueError("Transformer Rating not found")
                cost = transformer['Investment Cost (dolars)']
                cost_units = 'USD/unit'

                transformer_attributes.loc[count] = [phases,primary_kV,secondary_kv,num_windings,primary_connection_type,secondary_connection_type,rated_kVA,cost,cost_units]
                count+=1
    return transformer_attributes



if __name__ == '__main__':
    input_file = 'extended_catalog.json'
    output_file = 'cost_databsase.xlsx'

    input_data = None
    with open(input_file) as fp:
        input_data = json.load(fp)
    
    output_sheets = ['lines','transformers','control_changes','voltage_regulators','misc','notes']

    print('extracting lines...')
    lines = extract_lines(input_data)
    print('extracting transformers...')
    transformers = extract_transformers(input_data)
    print('copying control changes...')
    control_changes = pd.read_csv('default_control_changes.csv',header=0)
    print('copying voltage regulators...')
    voltage_regulators = pd.read_csv('default_voltage_regulators.csv',header=0)

    with pd.ExcelWriter(output_file) as writer:
        lines.to_excel(writer,sheet_name = 'lines')
        transformers.to_excel(writer,sheet_name = 'transformers')
        control_changes.to_excel(writer,sheet_name = 'control_changes')
        voltage_regulators.to_excel(writer,sheet_name = 'voltage_regulators')



