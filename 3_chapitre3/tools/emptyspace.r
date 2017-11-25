library('spatstat')
library('maptools')
#Chargement de l'emprise de la carte de Verniquet
emprise<- readShapePoly("/media/New_Data/THESE/emprise.shp")
poly <- as(emprise, "SpatialPolygons")
poly <- as(poly, "owin")
plot(poly)

#Chargement des bords de Paris
paris<- readShapeLines("/media/New_Data/THESE/sketch_paris.shp")
paris <- as(paris, "SpatialLines")
plot(paris)


#Chargement de la Seine
seine<- readShapeLines("/media/New_Data/THESE/seine_axis.shp")
seine <- as(seine, "SpatialLines")
plot(seine)

# 
# ANALYSE DE LA REPARTITION DES POINTS.
# 1 - création des cartes d'espaces vides
# 1 - création des courbes de J(pts)
# 

datac<-read.csv("/media/New_Data/THESE/verniquet_grid_merged.points",sep=",", dec=".")
xc<-datac$X
yc<-datac$Y
xc<-as.vector(xc)
yc<-as.vector(yc)
xc<-as.numeric(xc)
yc<-as.numeric(yc)
grid<-ppp(xc,yc,window=poly)


datac<-read.csv("/media/New_Data/THESE/verniquet_batis_merged.points",sep=",", dec=".")
xc<-datac$X
yc<-datac$Y
xc<-as.vector(xc)
yc<-as.vector(yc)
xc<-as.numeric(xc)
yc<-as.numeric(yc)
batis<-ppp(xc,yc,window=poly)


datac<-read.csv("/media/New_Data/THESE/verniquet_rues_merged.points",sep=",", dec=".")
xc<-datac$X
yc<-datac$Y
xc<-as.vector(xc)
yc<-as.vector(yc)
xc<-as.numeric(xc)
yc<-as.numeric(yc)
rues<-ppp(xc,yc,window=poly)

datac<-read.csv("/media/New_Data/THESE/verniquet_merge_merged.points",sep=",", dec=".")
xc<-datac$X
yc<-datac$Y
xc<-as.vector(xc)
yc<-as.vector(yc)
xc<-as.numeric(xc)
yc<-as.numeric(yc)
all<-ppp(xc,yc,window=poly)



levels = c(100,500,1000,2000,3000,4000)
cr <- colourmap(rainbow(1000,start=0.05,end=0.8), range=c(0,2500))
mapgrid<-distmap(grid,1000,1000)
mapbatis<-distmap(batis,1000,1000)
maprues<-distmap(rues,1000,1000)
mapall<-distmap(all,1000,1000)




#GRILLE
dev.new()
png('/home/BDumenieu/ntfs_drive/workspace/geoxygene-cogit/documents/src/main/latex/theseBD/5_chapitre5/images/pts_analyse/total_distmap_grille.png',width=1000,height=1000,res=100)
plot(mapgrid,col=cr, main="Carte de distances 'Grill'")
plot(poly,add=TRUE)
n2  = nndist(grid,k=2)
n3  = nndist(grid,k=3)
n4  = nndist(grid,k=4)
n5  = nndist(grid,k=5)
n6  = nndist(grid,k=6)
n7  = nndist(grid,k=7)
n8  = nndist(grid,k=8)
n9  = nndist(grid,k=9)
n10  = nndist(grid,k=10)
meanNNDist <- apply(cbind(n2,n3,n4,n5,n6,n7,n8,n9,n10),1,mean)
plot(grid %mark% (meanNNDist/2), markscale = 1,add=TRUE)
plot(paris,add=TRUE,col='black',lty=1)
plot(seine,add=TRUE,col='blue',lty=1)
dev.off()

#BATIMENTS
dev.new()
png('/home/BDumenieu/ntfs_drive/workspace/geoxygene-cogit/documents/src/main/latex/theseBD/5_chapitre5/images/pts_analyse/total_distmap_batis.png',width=1000,height=1000,res=100)
plot(mapbatis,col=cr, main="Carte de distances 'Bâtiments'")
plot(poly,add=TRUE)
n2  = nndist(batis,k=2)
n3  = nndist(batis,k=3)
n4  = nndist(batis,k=4)
n5  = nndist(batis,k=5)
n6  = nndist(batis,k=6)
n7  = nndist(batis,k=7)
n8  = nndist(batis,k=8)
n9  = nndist(batis,k=9)
n10  = nndist(batis,k=10)
meanNNDist <- apply(cbind(n2,n3,n4,n5,n6,n7,n8,n9,n10),1,mean)
plot(batis %mark% (meanNNDist/2), markscale = 1,add=TRUE)
plot(paris,add=TRUE,col='black',lty=1)
plot(seine,add=TRUE,col='blue',lty=1)
dev.off()

#RUES
dev.new()
png('/home/BDumenieu/ntfs_drive/workspace/geoxygene-cogit/documents/src/main/latex/theseBD/5_chapitre5/images/pts_analyse/total_distmap_rues.png',width=1000,height=1000,res=100)
plot(maprues,col=cr, main="Carte de distances 'Rues'")
plot(poly,add=TRUE)
n2  = nndist(rues,k=2)
n3  = nndist(rues,k=3)
n4  = nndist(rues,k=4)
n5  = nndist(rues,k=5)
n6  = nndist(rues,k=6)
n7  = nndist(rues,k=7)
n8  = nndist(rues,k=8)
n9  = nndist(rues,k=9)
n10  = nndist(rues,k=10)
meanNNDist <- apply(cbind(n2,n3,n4,n5,n6,n7,n8,n9,n10),1,mean)
plot(rues %mark% (meanNNDist/2), markscale = 1,add=TRUE)
plot(paris,add=TRUE,col='black',lty=1)
plot(seine,add=TRUE,col='blue',lty=1)
dev.off()

#ALL
dev.new()
png('/home/BDumenieu/ntfs_drive/workspace/geoxygene-cogit/documents/src/main/latex/theseBD/5_chapitre5/images/pts_analyse/total_distmap_fusion.png',width=1000,height=1000,res=100)
plot(mapall,col=cr, main="Carte de distances 'FUSION'")
#contour(mapall,lwd=1,labcex=0.8,vfont=c("sans serif","bold"),add=TRUE,levels=levels,drawlabels=FALSE)
plot(poly,add=TRUE)
n2  = nndist(all,k=2)
n3  = nndist(all,k=3)
n4  = nndist(all,k=4)
n5  = nndist(all,k=5)
n6  = nndist(all,k=6)
n7  = nndist(all,k=7)
n8  = nndist(all,k=8)
n9  = nndist(all,k=9)
n10  = nndist(all,k=10)
meanNNDist <- apply(cbind(n2,n3,n4,n5,n6,n7,n8,n9,n10),1,mean)
plot(all %mark% (meanNNDist/2), markscale = 1,add=TRUE)
plot(paris,add=TRUE,col='black',lty=1)
plot(seine,add=TRUE,col='blue',lty=1)
dev.off()



# CONSTRUCTION DES COURBES J
#

xrange<-seq(from = 0, to = 1000, by = 1)
#GRID
j<-Fest(grid,r=xrange,correction="none") #Là on applique une correction de bords car il y a continuité du phénomène.
jg<-j$un
ho<-j$theo
r<-j$r
eg<-envelope(grid,Jest, nsim=39,correction="none")

#RUES
j<-Jest(rues,r=xrange,correction="none")
jr<-j$un
rr<-j$r
er<-envelope(rues,Jest, nsim=39,correction="none")

#BATIMENTS
j<-Jest(batis,r=xrange,correction="none")
jb<-j$un
rb<-j$r
eb<-envelope(batis,Jest, nsim=39,correction="none")

#ALL
j<-Jest(all,r=xrange,correction="none")
ja<-j$un
ra<-j$r
ea<-envelope(all,Jest, nsim=39,correction="none")


plot(r,ja,type="l",lty=1,col="black",main="Jest fusion",ylim=c(0,2),ylab=expression(hat(J)~(r)))
lines(rr,jr,type="l",lty=1,col="red")
lines(rb,jb,type="l",lty=1,col="green")
lines(ra,ja,type="l",lty=1,col="orange")
lines(r,ho,type="l",lty=4,col="blue")


lines(eg$r,eg$hi,type="l",lty=2,col="black")
lines(eg$r,eg$lo,type="l",lty=2,col="black")

lines(er$r,er$hi,type="l",lty=2,col="red")
lines(er$r,er$lo,type="l",lty=2,col="red")

lines(eb$r,eb$hi,type="l",lty=2,col="green")
lines(eb$r,eb$lo,type="l",lty=2,col="green")


lines(ea$r,ea$hi,type="l",lty=2,col="orange")
lines(ea$r,ea$lo,type="l",lty=2,col="orange")

#plot(r,ho,xlim=c(0,400),ylim=c(-0.5,0.5),type="l",lty=4,col="blue",main="Jest fusion",ylab=expression(hat(F)~(r)))



a = c(1,2,3,4,5)
b = c(3,2,5,1,4)
S <- SpatialPoints(cbind(a,y))



