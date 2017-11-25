#!/usr/bin/python
import ogr, sys, os, getopt, Image, csv
from numpy import ndarray
import numpy
import qpts2map as warper

def main(argv):
        driver = ogr.GetDriverByName('ESRI Shapefile')
        sname = ''
        ofile =''
        try:
                opts, args = getopt.getopt(argv, "hs:o:", ["help","shape_tileindex=","mapanalyst_file="])
        except getopt.GetoptError:
                usage()
                sys.exit(2)
        for opt,arg in opts:
                if opt in ("-s","--shape_tileindex"):
                        sname = arg
                elif opt in ("-o","--mapanalyst_file"):
                        ofile = arg
                else:
                        usage()
                        sys.exit()
        #Get the tiles in read only mode
        print sname
        datasource = driver.Open(sname,0)
        #Quit if there is nothing to open        
        if datasource is None:
                print "Could not open " + fn
                sys.exit(1) #exit with an error code
        layer = datasource.GetLayer()
        #Check if there is actually something in the layer
        numFeatures = layer.GetFeatureCount()   
        if numFeatures == 0:
                print "Tile index Shapefile is empty"
                sys.exit(1) #exit with an error code
        print numFeatures, "features read"

        #Now we can build a matrix that contains a mapping of the rasters and store useful information for each of them
        #First compute the number of rows and column in the matrix so we can build it
        feature = layer.GetNextFeature()
        nrow = 0
        ncol = 0
        while feature:
                cur_col = feature.GetFieldAsInteger('X')
                if cur_col >= ncol: ncol = cur_col+1
                cur_row = feature.GetFieldAsInteger('Y')
                if cur_row >= nrow: nrow = cur_row+1
                feature = layer.GetNextFeature()
        layer.ResetReading()
        if nrow <= 0 or ncol <= 0:
                print "Invalid assembly matrix size (",nrow,ncol,")"
                sys.exit(1) #exit with an error code
        amatrix = ndarray((nrow,ncol),tuple)
        print amatrix, nrow, ncol
        #Then fill the matrix with all useful informations extracted from the rasters
        feature = layer.GetNextFeature()
        while feature:
                cur_row = feature.GetFieldAsInteger('Y')
                cur_col = feature.GetFieldAsInteger('X')
                raster_name = feature.GetFieldAsString('filename')
                #Let's open the raster for this feature 
                try:
                        raster = Image.open(raster_name)               
                        raster_width = raster.size[0]
                        raster_height = raster.size[1]
                        dpix =  raster.info['dpi'][0]
                        dpiy =  raster.info['dpi'][1]
                        print cur_row
                        print cur_col
                        amatrix[cur_row][cur_col] = (raster_width, raster_height, raster_name, dpix, dpiy)
                except IOError:
                        print "Could not read "+raster_name+", skipping..."
                feature = layer.GetNextFeature()
        layer.ResetReading()
        print 'Tile matrix:'
        print amatrix
        #Everything is now ready to warp and assemble the QGIS point files
        #Step 1 : Warp everything to an unique frame
        uframe = []
        uid =0
        rowid = 0
        for row in amatrix:
                colid = 0
                for frame in row:
                        print 'trating :[',rowid,',',colid,']'
                        #We must compute the horizontal and vertical offsets from the origin for each frame 
                        if frame is not None:
                                #Load the points for the current frame
                                try:
                                        with open(os.path.splitext(frame[2])[0]+'.points') as qgisfile:
                                                qgisptscontent = csv.reader(qgisfile,delimiter=',')
                                                #If this is the first frame there is nothing to
                                                if rowid == 0 and colid == 0:
                                                        #Add all points in the unique frame
                                                        for element in qgisptscontent:
                                                                try:
                                                                        float(element[0])
                                                                        uframe.append([int(uid),float(element[2]),float(element[3]),float(element[0]),float(element[1]), frame[3],frame[4]])
                                                                        print 'Added to UFRAME (frame 0):'
                                                                        print [int(uid),float(element[2]),float(element[3]),float(element[0]),float(element[1]), frame[3],frame[4]]
                                                                except:
                                                                        continue
                                                else:
                                                        #Find the horizontal offset for the current frame
                                                        xoffset = 0
                                                        for item in row[:colid]:
                                                                xoffset += item[0]

                                                        #Find the vertical offset for the current frame
                                                        yoffset = 0
                                                        for item in amatrix[:rowid,colid]:
                                                               yoffset += item[0]
               
                                                        #Build the transformation matrix : one simple translation and no rotation
                                                        tmat= numpy.matrix([[1,0,-xoffset],[0,1,-yoffset],[0,0,1]])
                                                        for element in qgisptscontent:
                                                                try:
                                                                        float(element[0])     
                                                                        print tmat   
                                                                        point = [float(element[2]),float(element[3]),1]
                                                                        warped_point = warper.warp(point, tmat)
                                                                        uframe.append([uid,warped_point.item(0),warped_point.item(1),element[0],element[1], frame[3],frame[4]])
                                                                        print 'Added to UFRAME'

                                                                except ValueError as e:
                                                                        print e
                                                                        continue
                                
                                except IOError:
                                        print "Could not open file "+os.path.splitext(frame[2])[0]+'.points, skipping...'
                        colid +=1
                        uid+=1
                colid = 0
                rowid+=1
        #Prepare the writer
        with open(ofile+".txt",'w+') as mapanalystfile:
                mapanalystwriter = csv.writer(mapanalystfile, delimiter=',', quoting=csv.QUOTE_MINIMAL)

                #Now we have an unique frame in the QGIS reference system. We're going to warp it into MapAnalyst reference system
                total_height = 0
                for item in amatrix[:1,0]:
                        total_height += item[1]

                thmatrix = numpy.matrix([[1,0,0],[0,1,total_height],[0,0,1]])
                for item in uframe:
                        point = [item[1],item[2],1]
                        try:
                                warped_point = warper.warp(point, thmatrix)
                                #Finally set it in meters
                                warped_point.itemset(0,(warped_point.item(0) / (dpix/2.54)) /100.0)
                                warped_point.itemset(1,(warped_point.item(1) / (dpiy/2.54))/100.0) 
                                #Finally write the new MapAnalyst Points File
                                mapanalystwriter.writerow([item[0],warped_point.item(0),warped_point.item(1),item[3],item[4]])
                                print 'writing',item
                        except ValueError as e:
                                print 'failure on', point
                                print e
                print 'THE END'
def usage():
        print "\nMerge several QGIS point file from an tileindex shapefile.\n"
        print 'Usage: '+sys.argv[0]+' -t <ESRI Shapefile tiles> -i <QGIS point files> -s <Raster height>'


if __name__ =='__main__':
        main(sys.argv[1:])
