#!/usr/bin/python
import getopt
import os,sys
import csv
import Image
import numpy

def main(argv):
        ifile = ""
        ofile = ""
        try:
                opts, args = getopt.getopt(argv, "hi:o:", ["help","input_file=","output_file="])
        except getopt.GetoptError as e:
                print e
                usage()
                sys.exit(2)
        for opt,arg in opts:
                if opt in ("-i","--input_file"):
                        ifile = arg
                elif opt in ("-o","--output_file"):
                        ofile = arg
                else:

                        usage()
                        sys.exit()
        #Read the qgis points file and check if a valid height was prodivded. If not, try to open the JPG raster file relative to the qgis points file
        with open(ifile) as qgisfile:
                try:    
                        img = Image.open(os.path.splitext(ifile)[0]+'.jpg')
                        pxheight = img.size[1]
                        dpix =  img.info['dpi'][0]
                        dpiy =  img.info['dpi'][1]
                except IOError:
                        print "Could not read the raster "+os.path.splitext(ifile)[0]+'.jpg'
                        sys.exit()
                if pxheight < 1:
                        print pxheight+" is not a valid height value"
                        sys.exit()

                with open(ofile+".txt",'w+') as mapanalystfile:
                        #Prepare the writer
                        mapanalystwriter = csv.writer(mapanalystfile, delimiter=',', quoting=csv.QUOTE_MINIMAL)
                        #Parse qgis points
                        qgisptscontent = csv.reader(qgisfile,delimiter=',')
                        #Build the affine transformation matrix
                        tmat = numpy.matrix([[1,0,0],[0,1,pxheight],[0,0,1]])
                        #Warp everything
                        ptid = 0
                        mapanalyst_points = []
                        for row in qgisptscontent:
                                if ptid != 0:
                                        warped= numpy.matrix(warp([float(row[2]),float(row[3]),1],tmat))
                                        print "result : ",warped
                                        #Convert the points in meters because it is required by MapAnalyst
                                        warped.itemset(0,(warped.item(0) / (dpix/2.54)) /100.0)
                                        warped.itemset(1,(warped.item(1) / (dpiy/2.54))/100.0)                  
                                        #Finally, write the new point         
                                        mapanalystwriter.writerow([ptid,warped.item(0),warped.item(1),float(row[0]),float(row[1])])
                                ptid += 1
                        #Everything went better than expected
                        print "New points written in "+ofile

def warp(point, warp_matrix):
        return warp_matrix.dot(point)



def usage():
    print "\nConverts a QGIS georeferencing points file into a MapAnalyst points file. The programm will try to read the JPG raster named from the QGIS points file\n"
    print 'Usage: '+sys.argv[0]+' -i <QGIS point file> -o <MapAnalyst point file> '

if __name__ =='__main__':
    main(sys.argv[1:])
