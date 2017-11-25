data<-read.csv("/home/BDumenieu/ntfs_drive/workspace/geoxygene-cogit/documents/src/main/latex/theseBD/5_chapitre5/images/data_herrault_regular.csv",sep=" ",dec=".")
ngcp<-data$NGCP
AFFINE<-data$AFFINE
ORDER2<-data$ORDER2
ORDER3<-data$ORDER3

data2<-read.csv("/home/BDumenieu/ntfs_drive/workspace/geoxygene-cogit/documents/src/main/latex/theseBD/5_chapitre5/images/data_herrault_random.csv",sep=" ",dec=".")

AFFINE2<-data2$AFFINE
ORDER22<-data2$ORDER2
ORDER32<-data2$ORDER3


dev.new()
jpeg('/home/BDumenieu/ntfs_drive/workspace/geoxygene-cogit/documents/src/main/latex/theseBD/5_chapitre5/images/herrault.jpg',width=800,height=400)
layout(matrix(c(1,2,3,3), ncol=2, byrow=TRUE), heights=c(4, 1))
par(mai=rep(0.5, 4))
plot(ngcp,AFFINE,col="red",type="l",lty=1,ylim=c(50,110),xlab='Nombre de points',ylab='RMSE(m)',main="Erreur résiduelle pour des points réguliers",,lwd=2)
lines(ngcp,ORDER2,col="blue",type="l",lty=2,lwd=2)
lines(ngcp,ORDER3,col="green",type="l",lty=3,lwd=2)

plot(ngcp,AFFINE2,col="red",type="l",lty=1,ylim=c(50,110),xlab='Nombre de points',ylab='RMSE(m)',main="Erreur résiduelle pour des points aléatoires",,lwd=2)
lines(ngcp,ORDER22,col="blue",type="l",lty=2,lwd=2)
lines(ngcp,ORDER32,col="green",type="l",lty=3,lwd=2)
par(mai=c(0,0,0,0))
plot.new()
legend("center",xpd=TRUE,c("Affine","Polynomial d'ordre 2", "Polynomiale d'ordre 3"),lty=c(1,2,3),col=c("red","blue","green"))
dev.off()


