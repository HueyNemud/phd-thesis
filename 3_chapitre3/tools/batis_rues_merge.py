# -*- coding: UTF-8 -*-

import ogr, sys, os, getopt, Image, csv
import shapefile
from os import listdir
from os.path import isfile, join
import numbers
''' MERGE les fichiers de points de BATIS et de RUES'''


p = '/media/New_Data/THESE/PLANS/GEOREFERENCES/Verniquet_1785_1799/GCP/RUES/'
onlyfiles = [ f for f in listdir(p) if isfile(join(p,f)) ]

for i in [x+1 for x in range(72)]:

        num = '0'
        if i < 10:
               num = '0'+str(i)
        else:
               num = str(i)
        outw = csv.writer(open('/media/New_Data/THESE/PLANS/GEOREFERENCES/Verniquet_1785_1799/GCP/MERGE/'+num+'_merge.points','w+'), delimiter = ',')
        try:
                in1 = csv.reader(open('/media/New_Data/THESE/PLANS/GEOREFERENCES/Verniquet_1785_1799/GCP/BATIS/'+num+'_batis.points'),delimiter = ',')
        except Exception as e:
                print num+'_batis doesnt exist'
                in1 = None
                pass
        try:
                in2 = csv.reader(open('/media/New_Data/THESE/PLANS/GEOREFERENCES/Verniquet_1785_1799/GCP/RUES/'+num+'_rues.points'),delimiter = ',')
        except Exception as e:
                print num+'_rues doesnt exist'
                in2 = None
                pass
        if not in1 is None:
                for row in in1:
                        try:
                                test = float(row[0])
                                outw.writerow(row)
                        except Exception as e:
                                print e
                                pass
        if not in2 is None:
                for row in in2:
                        try:
                                test = float(row[0])
                                outw.writerow(row)
                        except Exception as e:
                                print e
                                pass

        
