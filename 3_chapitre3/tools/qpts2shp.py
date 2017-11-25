#!/usr/bin/python
import ogr, sys, os, getopt, Image, csv
import shapefile
from os import listdir
from os.path import isfile, join
import numbers

'''merge all GCPS.geo points in a POINT shapefile.'''

print 'CREATE NEW SHAPEFILE /media/New_Data/THESE'
shpw = shapefile.Writer(shapefile.POINT)
shpw.field('sheet')
name = "grid"


csvwriter = csv.writer(open('/media/New_Data/THESE/verniquet_'+name+'_merged.points','w+'), delimiter = ',')
csvwriter.writerow(['X','Y'])

p = '/media/New_Data/THESE/PLANS/GEOREFERENCES/Verniquet_1785_1799/GCP/'+name.upper()+'/'
onlyfiles = [ f for f in listdir(p) if isfile(join(p,f)) ]
print onlyfiles
for f in onlyfiles:
        gcpf = open('/media/New_Data/THESE/PLANS/GEOREFERENCES/Verniquet_1785_1799/GCP/'+name.upper()+'/'+f, 'r')
        fcontent = csv.reader(gcpf,delimiter=',')
        #print 'in /media/New_Data/THESE/PLANS/GEOREFERENCES/Verniquet_1785_1799/GCP/'+name.upper()+'/'+f,
        for row in fcontent:
                try:
                        #print "writing"+str(row)
                        shpw.point(float(row[0]),float(row[1]))   
                        shpw.record(f)              
                        csvwriter.writerow([row[0],row[1]])
                except Exception as e:
                        print e
                        pass
                

shpw.save('/media/New_Data/THESE/verniquet_'+name+'_merged')
