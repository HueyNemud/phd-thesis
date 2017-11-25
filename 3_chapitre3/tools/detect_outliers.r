library('spatstat')
library('maptools')
# ANALYSE LES RESIDUS OUTLIERS DE LA CATEGORIE DE POINTS CHOISIS
xv <- vector()
yv <- vector()
daffv <- vector()
dp2v <- vector()
isoutlieraff <-  vector()
isoutlierp2 <-  vector()
for (i in 1:72 ) {
        tryCatch({

str = ""
        if(i<10){
                str = paste0('0',i)        
        }else{
                str=toString(i)        
        }       
        path = paste0("/media/New_Data/THESE/PLANS/GEOREFERENCES/Verniquet_1785_1799/GCP/RUES/",str,"_rues.points")
        message(path)
        output=  paste0("/media/New_Data/THESE/",str,"_residuals")
        message(output)
        data = read.csv(path,sep=",", dec=".")
        pix = data$pixelX
        line = -data$pixelY

        x<-data$mapX
        y<-data$mapY
        geopts = cbind(x,y)

        #Find the coefficients AFFINE
        xaff = lm(x ~ pix+line)
        yaff = lm(y ~ pix+line)

        #Find the coefficients polynomial 2
        xp2 = lm(x ~ pix+line+pix*pix+pix*line+line*line)
        yp2 = lm(y ~ pix+line+pix*pix+pix*line+line*line)

        rdist_aff = sqrt(xaff$residuals*xaff$residuals + yaff$residuals*yaff$residuals)
        rdist_p2 = sqrt(xp2$residuals*xp2$residuals + yp2$residuals*yp2$residuals)

        pts = SpatialPointsDataFrame(data.frame(x,y),data.frame(rdist_aff,rdist_p2))
        writeSpatialShape(pts,output)

        xv  = c(xv,x)
        yv  = c(yv,y)
        daffv  = c(daffv,rdist_aff)
        dp2v  = c(dp2v,rdist_p2)

        bxpdat = boxplot(rdist_aff,plot=FALSE)
        isoutlieraff = c(isoutlieraff,1:length(x) %in% names(bxpdat$out))
        bxpdat = boxplot(rdist_p2,plot=FALSE)
        isoutlierp2 = c(isoutlierp2,1:length(x) %in% names(bxpdat$out))
        },error = function(e){
              print(e)
        }
        )
}

pts = SpatialPointsDataFrame(data.frame(xv,yv),data.frame(daffv,dp2v,isoutlieraff,isoutlierp2))
writeSpatialShape(pts,"/media/New_Data/THESE/all_residuals")


