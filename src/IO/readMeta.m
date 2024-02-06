function [X,Y,Z,T,C,zRatio]=readMeta(reader)

omeMeta = reader.getMetadataStore();

Y = omeMeta.getPixelsSizeX(0).getValue(); 
X = omeMeta.getPixelsSizeY(0).getValue(); 
Z = omeMeta.getPixelsSizeZ(0).getValue(); 
T = omeMeta.getPixelsSizeT(0).getValue(); 
C = omeMeta.getPixelsSizeC(0).getValue(); 

voxelSize = omeMeta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROMETER);
zMicron = voxelSize.doubleValue(); 

voxelSize = omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROMETER);
xMicron = voxelSize.doubleValue(); 

zRatio=zMicron/xMicron;

end