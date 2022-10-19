import shutil
import math
import pandas as pd
import opendssdirect as dss
import json
from ditto.models.line import Line
from ditto.models.phase_winding import PhaseWinding
from ditto.models.winding import Winding
from ditto.models.powertransformer import PowerTransformer
from ditto.models.wire import Wire
from ditto.store import Store
from ditto.writers.opendss.write import Writer

def update_line_format(input_matrix):
    print(input_matrix)
    size = math.sqrt(len(input_matrix))
    if int(size) != size:
        raise "input matrix is not square"
    size = int(size)
    result = ""
    for i in range(size):
        for j in range(i+1):
            result += str(input_matrix[j+i*size])
            result += " "
        if i != size-1:
            result+= "|"
    return [result.strip()]

def get_lines():
    line_flag = dss.Lines.First()
    pdelement_flag = dss.PDElements.First()
    dss.Circuit.SetActiveClass('Line')
    data = []
    while line_flag:
        data_dump = dss.utils.class_to_dataframe('Line')
        datum = {}
        datum['name'] = dss.Lines.Name()
        datum['rmatrix'] = update_line_format(dss.Lines.RMatrix() )
        datum['xmatrix'] = update_line_format(dss.Lines.XMatrix() )
        datum['cmatrix'] = update_line_format(dss.Lines.CMatrix() )
        datum['Rg'] = dss.Lines.Rg()
        datum['Xg'] = dss.Lines.Xg()
        datum['r1'] = dss.Lines.R1()
        datum['x1'] = dss.Lines.X1()
#        datum['c1'] = dss.Lines.C1()
        #datum['B1'] = dss.Lines.B1()
        datum['r0'] = dss.Lines.R0()
        datum['x0'] = dss.Lines.X0()
#        datum['c0'] = dss.Lines.C0()
        #datum['B0'] = dss.Lines.B0()
        datum['rho'] = dss.Lines.Rho()
        datum['emergamps'] = dss.Lines.EmergAmps()
        datum['normamps'] = dss.Lines.NormAmps()
        datum['phases'] = dss.Lines.Phases()
        datum['Switch'] = dss.Lines.IsSwitch()
        if datum['Switch']:
            datum['Switch'] = "Yes"
        else:
            datum['Switch'] = "No"
        datum['linecode'] = dss.Lines.LineCode()


        datum['Ratings'] = data_dump['Ratings'].iloc[0]
        datum['units'] = data_dump['units'].iloc[0]
        datum['Seasons'] = data_dump['Seasons'].iloc[0]
        datum['EarthModel'] = data_dump['EarthModel'].iloc[0]
        datum['B0'] = data_dump['B0'].iloc[0]
        datum['B1'] = data_dump['B1'].iloc[0]
        datum['geometry'] = "" #data_dump['geometry'].iloc[0]
        datum['linecode'] = data_dump['linecode'].iloc[0]
        datum['tscables'] = data_dump['tscables'].iloc[0]
        datum['cncables'] = data_dump['cncables'].iloc[0]
        datum['wires'] = data_dump['wires'].iloc[0]

        datum['faultrate'] = dss.PDElements.FaultRate()
        datum['pctperm'] = dss.PDElements.PctPermanent()
        datum['repair'] = dss.PDElements.RepairTime()

        sources_flag = dss.Vsources.First()
        datum['basefreq'] = dss.Vsources.Frequency()

        for key in datum:
            print(key,datum[key])
        line_flag = dss.Lines.Next()
        pdelement_flag = dss.PDElements.Next()
        data.append(datum)
    return data


def get_transformers():
    transformer_flag = dss.Transformers.First()
    pdelement_flag = dss.PDElements.First()
    dss.Circuit.SetActiveClass('Transformer')
    data = []
    while transformer_flag:
        data_dump = dss.utils.class_to_dataframe('Transformer')
        datum = {}
        datum['name'] = dss.Transformers.Name()
        datum['windings'] = dss.Transformers.NumWindings()
        datum['wdg'] = dss.Transformers.NumWindings()
        if dss.Transformers.IsDelta():
            datum['conn'] = 'delta'
        else:
            datum['conn'] = 'wye'
        datum['kV'] = dss.Transformers.kV()
        datum['kVA'] = dss.Transformers.kVA()
        datum['tap'] = dss.Transformers.Tap()
        datum['%R'] = dss.Transformers.R()
        datum['Rneut'] = dss.Transformers.Rneut()
        datum['Xneut'] = dss.Transformers.Xneut()
        datum['XHL'] = dss.Transformers.Xhl()
        datum['XHT'] = dss.Transformers.Xht()
        datum['XLT'] = dss.Transformers.Xlt()
        datum['X12'] = dss.Transformers.Xhl()
        datum['X13'] = dss.Transformers.Xht()
        datum['X23'] = dss.Transformers.Xlt()
        datum['MaxTap'] = dss.Transformers.MaxTap()
        datum['MinTap'] = dss.Transformers.MinTap()
        datum['NumTaps'] = dss.Transformers.NumTaps()
        datum['emergamps'] = dss.CktElement.EmergAmps()

        datum['ppm_antifloat'] = data_dump['ppm_antifloat'].iloc[0]
        datum['Core'] = data_dump['Core'].iloc[0]
        datum['LeadLag'] = data_dump['LeadLag'].iloc[0]
        datum['thermal'] = data_dump['thermal'].iloc[0]
        datum['hsrise'] = data_dump['hsrise'].iloc[0]
        datum['flrise'] = data_dump['flrise'].iloc[0]
        datum['normamps'] = data_dump['normamps'].iloc[0]
        datum['kVs'] = data_dump['kVs'].iloc[0]
        datum['kVAs'] = data_dump['kVAs'].iloc[0]
        datum['conns'] = data_dump['conns'].iloc[0]
        datum['taps'] = data_dump['taps'].iloc[0]
        datum['Xscarray'] = data_dump['Xscarray'].iloc[0]
        datum['Xscarray'] = [ i for i in datum['Xscarray'][0].split()]
        datum['m'] = data_dump['m'].iloc[0]
        datum['n'] = data_dump['n'].iloc[0]
        datum['phases'] = data_dump['phases'].iloc[0]
        datum['%loadloss'] = data_dump['%loadloss'].iloc[0]
        datum['RdcOhms'] = data_dump['RdcOhms'].iloc[0]
        datum['%imag'] = data_dump['%imag'].iloc[0]
        datum['Ratings'] = data_dump['Ratings'].iloc[0]
        datum['Seasons'] = data_dump['Seasons'].iloc[0]
        datum['XRConst'] = data_dump['XRConst'].iloc[0]
        datum['emerghkVA'] = data_dump['emerghkVA'].iloc[0]
        datum['normhkVA'] = data_dump['normhkVA'].iloc[0]
        datum['%Rs'] = data_dump['%Rs'].iloc[0]
        # taken from here: https://github.com/NREL/disco/blob/main/disco/extensions/upgrade_simulation/upgrades/common_functions.py#L867
        if datum['phases'] == 1:
            datum['amp_limit_per_phase'] = float(datum['kVAs'][0]) / float(datum['kVs'][0])
        else:
            datum['amp_limit_per_phase'] = float(datum['kVAs'][0]) / (float(datum['kVs'][0]) * math.sqrt(3))

        datum['faultrate'] = dss.PDElements.FaultRate()
        datum['pctperm'] = dss.PDElements.PctPermanent()
        datum['repair'] = dss.PDElements.RepairTime()

        sources_flag = dss.Vsources.First()
        datum['basefreq'] = dss.Vsources.Frequency()
        for key in datum:
            print(key,datum[key])
        transformer_flag = dss.Transformers.Next()
        pdelement_flag = dss.PDElements.Next()
        data.append(datum)
    return data

with open('extended_catalog.json','r') as f:
    catalog = json.load(f)

technical_catalog = {'line':[], 'transformer': [] }

all_lines = catalog["LINES"][1]["#Interurban Zone A:"]
all_transformers = catalog["SUBSTATIONS AND DISTRIBUTION TRANSFORMERS"]
all_wires = {}
for wire in catalog["WIRES"]["WIRES CATALOG"]:
    all_wires[wire['nameclass']] = wire


for line in all_lines:
    model = Store()
    ditto_line = Line(model)
    ditto_line.name = line['Name']
    ditto_line.nomial_voltage = float(line["Voltage(kV)"])*1000/math.sqrt(3)
    ditto_line.from_element = 'DummyFrom'
    ditto_line.to_element = 'DummyTo'
    ditto_line.length = 1
    wires = []
    height = 0 #Set to last wire
    for wire in line['Line geometry']:
        ditto_wire = Wire(model)
        ditto_wire.nameclass = wire['wire'].replace(" ","_")
        ditto_wire.X = wire['x (m)']
        ditto_wire.Y = wire['height (m)']
        ditto_wire.phase = wire['phase']
        height = wire['height (m)']
        if ditto_wire.phase == 'S1':
            ditto_wire.phase = 'A'
        if ditto_wire.phase == 'S2':
            ditto_wire.phase = 'B'

        wire_data = all_wires[wire['wire']]
        ditto_wire.diameter = wire_data['diameter (mm)']*0.001
        ditto_wire.ampacity = wire_data['ampacity (A)']
        ditto_wire.gmr = wire_data['gmr (mm)']*0.001
        ditto_wire.resistance = wire_data['resistance (ohm/km)']

        if '# concentric neutral strands' in wire_data:
            ditto_wire.concentric_neutral_nstrand = wire_data['# concentric neutral strands']
            ditto_wire.concentric_neutral_resistance = wire_data['resistance neutral (ohm/km)']
            ditto_wire.concentric_neutral_diameter = wire_data['concentric diameter neutral strand (mm)']*0.001
            ditto_wire.concentric_neutral_outside_diameter = wire_data['concentric neutral outside diameter (mm)']*0.001
            ditto_wire.concentric_neutral_gmr = wire_data['gmr neutral (mm)']*0.001
            ditto_wire.insulation_thickness = 10*0.001 #no insulation thickness provided so use 10mm
        wires.append(ditto_wire)
    ditto_line.wires = wires
    if height > 0:
        ditto_line.line_type = 'overhead'
    else:
        ditto_line.line_type = 'underground'


    writer = Writer(output_path='test_output')
    writer.write(model)
    result = dss.run_command("redirect test_output/Master.dss")
    print(result)
    data = get_lines()
    if len(data) !=1:
        raise("too many lines")
    data = data[0]
    data['kV'] = float(line["Voltage(kV)"])
    if data['kV'] >= 0.47:
        data['kV'] = data['kV']/math.sqrt(3)
    data['h'] = height
    data["line_definition_type"] =  ""
    if height > 0:
        data['line_placement'] = 'overhead'
    else:
        data['line_placement'] = 'underground'
    technical_catalog['line'].append(data)
    shutil.rmtree('test_output')

for region in all_transformers:
    for key in region:
        for transformer in region[key]:
            model = Store()
            ditto_transformer = PowerTransformer(model)
            ditto_transformer.name = transformer['Name']
            ditto_transformer.noload_loss = float(transformer['No load losses(kW)'])
            ditto_transformer.from_element = 'Dummy1'
            ditto_transformer.to_element  = 'Dummy2'
            ditto_transformer.is_center_tap = transformer['Centertap']
            if 'Installed Power(MVA)' in transformer:
                ditto_transformer.normhkva = float(transformer['Installed Power(MVA)']) *1000
            else:
                ditto_transformer.normhkva = float(transformer['Installed Power(kVA)'])
            
            if ditto_transformer.is_center_tap:
                ditto_transformer.reactances = [float(transformer['Reactance (p.u. transf)']),float(transformer['Reactance (p.u. transf)']),float(transformer['Reactance (p.u. transf)'])]
            else:
                ditto_transformer.reactances = [float(transformer['Reactance (p.u. transf)'])]

            windings = []
            winding1 = Winding(model)
            connection = transformer['connection'].split('-')[0].lower()
            if connection == 'delta':
                winding1.connection_type = 'D'
            if connection == 'wye':
                winding1.connection_type = 'Y'
            winding1.voltage_type = 0
            winding1.nominal_voltage = float(transformer['Primary Voltage (kV)']) *1000
            phase_windings1 = []
            for phase in range(int(transformer['Nphases'])):
                phase_winding = PhaseWinding(model)
                phase_winding.phase = chr(ord('A')+phase)
                phase_windings1.append(phase_winding)
            winding1.phase_windings = phase_windings1
            windings.append(winding1)

            winding2 = Winding(model)
            connection = transformer['connection'].split('-')[1].lower()
            if connection == 'delta':
                winding2.connection_type = 'D'
            if connection == 'wye':
                winding2.connection_type = 'Y'
            winding2.voltage_type = 1
            winding2.nominal_voltage = float(transformer['Secondary Voltage (kV)']) *1000
            phase_windings2 = []
            for phase in range(int(transformer['Nphases'])):
                phase_winding = PhaseWinding(model)
                phase_winding.phase = chr(ord('A')+phase)
                phase_windings2.append(phase_winding)
            winding2.phase_windings = phase_windings2
            windings.append(winding2)

            if ditto_transformer.is_center_tap:
                winding3 = Winding(model)
                connection = transformer['connection'].split('-')[1].lower()
                if connection == 'delta':
                    winding3.connection_type = 'D'
                if connection == 'wye':
                    winding3.connection_type = 'Y'
                winding3.voltage_type = 1
                winding3.nominal_voltage = float(transformer['Secondary Voltage (kV)']) *1000
                phase_windings3 = []
                for phase in range(int(transformer['Nphases'])):
                    phase_winding = PhaseWinding(model)
                    phase_winding.phase = chr(ord('A')+phase)
                    phase_windings3.append(phase_winding)
                winding3.phase_windings = phase_windings3
                windings.append(winding3)
            ditto_transformer.windings = windings

            writer = Writer(output_path='test_output')
            writer.write(model)
            result = dss.run_command("redirect test_output/Master.dss")
            print(result)
            data = get_transformers()
            if len(data) !=1:
                raise("too many lines")
            data = data[0]
            data['%noloadloss'] = float(transformer['No load losses(kW)'])
            if transformer['Voltage level'] == 'HV-MV':
                data['sub'] = "y"
            else:
                data['sub'] = "n"

            technical_catalog['transformer'].append(data)
            shutil.rmtree('test_output')

with open('technical_catalog.json','w') as f:
    json.dump(technical_catalog, f, indent=4)
