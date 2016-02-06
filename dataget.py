# -*- coding: mbcs -*-
#
# Abaqus/Viewer Release 6.14-2 replay file
# Internal Version: 2014_08_22-15.00.46 134497
# Run by mbgnkts2 on Thu Feb 04 15:36:46 2016
#

# from driverUtils import executeOnCaeGraphicsStartup
# executeOnCaeGraphicsStartup()
#: Executing "onCaeGraphicsStartup()" in the site directory ...
from abaqus import *
from abaqusConstants import *
session.Viewport(name='Viewport: 1', origin=(0.0, 0.0), width=59.5901031494141, 
    height=91.0166702270508)
session.viewports['Viewport: 1'].makeCurrent()
session.viewports['Viewport: 1'].maximize()
from viewerModules import *
from driverUtils import executeOnCaeStartup
executeOnCaeStartup()
o2 = session.openOdb(name='bulk-indent.odb')
#: Model: C:/Work/med samples/input files/bulk-indent.odb
#: Number of Assemblies:         1
#: Number of Assembly instances: 0
#: Number of Part instances:     4
#: Number of Meshes:             4
#: Number of Element Sets:       2
#: Number of Node Sets:          4
#: Number of Steps:              2
session.viewports['Viewport: 1'].setValues(displayedObject=o2)
odb = session.odbs['bulk-indent.odb']
session.xyDataListFromField(odb=odb, outputPosition=NODAL, variable=(('U', 
    NODAL), ), nodeLabels=(('bulk(wide)-small mesh-1', ('14', )), ))
session.xyDataObjects.changeKey(
    fromName='U:Magnitude PI: bulk(wide)-small mesh-1 N: 14', toName='displ')
x0 = session.xyDataObjects['displ']
session.writeXYReport(fileName='FE.dat', appendMode=OFF, xyData=(x0, ))

odb.close()
