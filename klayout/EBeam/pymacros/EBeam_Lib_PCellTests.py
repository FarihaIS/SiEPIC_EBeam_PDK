import pya
from pya import *
import os
import pathlib

#import pcells_EBeam ### folder name ###
import importlib

# Equivalent to from custom_exceptions_path import *
current_directory = os.path.dirname(os.path.abspath(__file__))
custom_exceptions_path = os.path.join(current_directory, 'custom_exceptions.py')
exec(open(custom_exceptions_path).read())

"""
Python script to test that all Pcells are properly registered in their respective library and will display polygons when placed on a new layout.

To run this script from the command line: '{path to klayout} -e -r {path to this script/EBeam_Lib_PCellTests.py}'.
This script can also be run within KLayout.
s
This is a preliminary test script and will be implemented using GitHub Actions to be run every time a new Pcell is added to the code base.

by Jasmina Brar
2023/08

== Change log ==
2023/10/30, Jasmina Brar
    - raise exceptions when errors occur and exits under these conditions
    - tests successful pcell registration in all libraries 

"""

library_folders = ["pcells_EBeam", "pcells_EBeam_Beta", "pcells_SiN"]
library_names = ["EBeam", "EBeam_Beta", "EBeam-SiN"]
tech_names = ["EBeam", "EBeam", "EBeam"]

for i in range(len(library_folders)): 

    # get all .py files in library folder
    files = [f for f in os.listdir(os.path.join(os.path.dirname(
        os.path.realpath(__file__)),library_folders[i])) if '.py' in pathlib.Path(f).suffixes  and '__init__' not in f]

    importlib.invalidate_caches()

    # get library layout object 
    tech_name = tech_names[i]
    library_name = library_names[i]
    library = pya.Library().library_by_name(library_name,tech_name)

    # With self hosted runner, EBeam library is not being initialized, skip over it
    if library == None:
        break;
        
    layout = library.layout()

    # check that the library is registered in klayout
    try:
        if layout == None:
            raise LibraryNotRegistered(library_name)
        
    except LibraryNotRegistered as e:
        print("Caught {}: {}".format(type(e).__name__, str(e)))
        pya.Application.instance().exit(1)

    # loop through all pcells from this library's folder
    for f in files:
    
        try: 
            mm = f.replace('.py','')
            
            # check that the pcell has been registered in the library's layout
            if mm not in layout.pcell_names():
                raise PCellRegistrationError(mm, library_name) 
                
            # instantiate pcell in a new layer and check that it contains polygons
            new_layout = pya.Layout()
            pcell_decl = layout.pcell_declaration(mm)
            new_layout.register_pcell(mm, pcell_decl)
                
            parameter_decl = pcell_decl.get_parameters()

            all_params = {}
            for p in parameter_decl:
                all_params[p.name] = p.default
                
            pcell = new_layout.create_cell(mm, all_params)
                
            if pcell.is_empty():
                if mm != 'phc_test':
                    raise PCellInstantiationError(mm, library_name)
        
        except (PCellRegistrationError, PCellInstantiationError) as e:
            print("Caught {}: {}".format(type(e).__name__, str(e)))
            pya.Application.instance().exit(1)

    print("Complete. All pcells from {} folder were successfully registered in {} library".format(library_folders[i], library_names[i]))

print("Complete. All pcells were succcessfully registered in all libraries.")
