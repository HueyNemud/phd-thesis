from PIL import Image
import shapefile
import csv
import glob
import math
import re
import numpy as np

#Taille du tableau d'assemblage
N_ROWS = 9
N_COLUMNS = 8
IMG_W = 7016
IMG_H = 5154




def main():
        paths = glob.glob("/media/New_Data/THESE/PLANS/GEOREFERENCES/Verniquet_1785_1799/GCP/BUILDINGS/*_batis.points")
        csvwriter =csv.writer( open("/media/New_Data/THESE/verniquet_batis_merged.csv", 'w+'), delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
        w = shapefile.Writer(shapefile.POINT)
        w.field('FIRST_FLD')
        for path in paths:
                reader = csv.reader(open(path), delimiter=',', quotechar='|')
                gcps=[]
                for row in reader:
                        if(is_number(row[0])):
                                gcp =[float(row[0]),float(row[1]),float(row[2]),-float(row[3])]
                                gcps.append(gcp)

                try:
                    idimg = int(re.search('/([0-9]{2})_', path).group(1))
                    res = getRowAndCol(idimg)
                    print 'processing image '+str(idimg ) + ' at position'+str(res)
                    tgcps = GCPRectification(res[0],res[1],gcps)
                    for tgcp in tgcps:
                        #print tgcp
                        csvwriter.writerow([tgcp[0], tgcp[1],tgcp[2], tgcp[3]])
                        w.point(tgcp[0], tgcp[1])
                        w.record('a')
                        w.point(tgcp[2], tgcp[3])
                        w.record('a')
                except AttributeError:
                    # AAA, ZZZ not found in the original string
                    print 'Error : image id not found'
        w.save('/media/New_Data/THESE/verniquet_batis_merged')
        

#Recuperer la ligne et colonne de la planche dans le tableau d'assemblage
def getRowAndCol(cell):
        i = math.ceil(float(cell)/N_COLUMNS)-1
        j = cell-i*N_COLUMNS-1
        return [i,j]


#Transforme les points de l'image vers leur emplacement dans l'assemblage
def GCPRectification(i,j,gcps):
        #(0,0) de l'image dans le referentiel de l'assemblage
        x0 = j*IMG_W
        y0 = i*IMG_H
        tm = np.mat([[1,0,x0],[0,1,y0],[0,0,1]])
        tgcps=[]
        for gcp in gcps:       
                mgcp = np.mat([[gcp[2]],[gcp[3]],[1]]) 
                tgcp = tm.dot(mgcp)
                tgcps.append([tgcp[0,0],-tgcp[1,0],gcp[0],gcp[1]])

        return tgcps

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

main()
'''


with open(csvfilepath, 'rb') as csvfile:
        gcpreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in gcpreader:
                print ', '.join(row)
print gcpreader 

for file in os.listdir("/media/Data/THESE/PLANS/ORIGINAUX/Verniquet_1785_1799/"):
    if file.endswith(".jpg"):
        im=Image.open("/media/Data/THESE/PLANS/ORIGINAUX/Verniquet_1785_1799/"+file)
        print file + str(im.size) # (width,height) tuple
'''

