rm(list=ls())
setwd("/Users/matteo/git_local/babyMIPS/data/")
d <- read.table("00ml/02/00ml02",sep="\t")
d3 <- read.table("00ml/03/00ml03",sep="\t")
d <- rbind(d,d3)

colnames(d) <- c("block","trial","fix_x","fix_y","soa","internalMotion","dur","wavelength","speed","sigma","ecc","side","dY","cond","cond_code","tBeg","tFix","tEnd","tResp","resp","rr","acc")

str(d)

# visualize one single staircase
plot(d$dY[d$cond==1],type="l",ylim=c(-3,3))
for(i in 2:8) lines(d$dY[d$cond==i])

#
library(mlisi)
library(ggplot2)
d$bin_dY <- cut(d$dY,16)
dag <- aggregate(cbind(rr, dY)~ecc+dur+speed+bin_dY,d[d$cond_code!="catch",], mean)
dag$se <- aggregate(rr~ecc+dur+speed+bin_dY,d[d$cond_code!="catch",], binomSEM)$rr

ggplot(d,aes(x=dY, y=rr))+facet_grid(speed+dur~ecc)+geom_smooth(method="glm",method.args=list(family=binomial(logit)),se=T)+geom_point(data=dag)+geom_errorbar(data=dag,aes(ymin=rr-se,ymax=rr+se))