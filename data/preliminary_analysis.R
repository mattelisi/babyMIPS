rm(list=ls())
#setwd("/Users/matteo/git_local/babyMIPS/data/")
setwd("~/git_local/babyMIPS/data/")
#d <- read.table("00ml/02/00ml02",sep="\t")
#d3 <- read.table("00ml/03/00ml03",sep="\t")
#d <- rbind(d,d3)

# d <- read.table("01CM/02/01CM02",sep="\t")
# d1 <- read.table("01CM/03/01CM03",sep="\t")
# d2 <- read.table("01CM/04/01CM04",sep="\t")
# d3 <- read.table("01CM/05/01CM05",sep="\t")
# d <- rbind(d,d1,d2,d3)

#d <- read.table("201T/D0/201TD01",sep="\t")

d <- read.table("01ml/02/01ml02",sep="\t")
d3 <- read.table("01ml/03/01ml03",sep="\t")
d4 <- read.table("01ml/04/01ml04",sep="\t")
d5 <- read.table("01ml/05/01ml05",sep="\t")
d6 <- read.table("01ml/06/01ml06",sep="\t")
d_ <- rbind(d,d3,d4,d5,d6)

d <- read.table("03ml/01/03ml01",sep="\t")
d2 <- read.table("03ml/02/03ml02",sep="\t")
d3 <- read.table("03ml/03/03ml03",sep="\t")
d4 <- read.table("03ml/04/03ml04",sep="\t")
d <- rbind(d,d2,d3,d4,d_)


colnames(d) <- c("block","trial","fix_x","fix_y","soa","internalMotion","dur","wavelength","speed","sigma","ecc","side","dY","cond","cond_code","tBeg","tFix","tEnd","tResp","resp","rr","acc")

str(d)

# visualize one single staircase
plot(d$dY[d$cond==1],type="l",ylim=c(-3,3))
for(i in 2:12) lines(d$dY[d$cond==i])

#
library(mlisi)
library(ggplot2)
#source("~/sync/miscR/miscFunctions.R")
d$bin_dY <- cut(d$dY,16)
dag <- aggregate(cbind(rr, dY)~ecc+dur+speed+bin_dY,d[d$cond_code!="catch" & d$internalMotion==1,], mean)
dag$se <- aggregate(rr~ecc+dur+speed+bin_dY,d[d$cond_code!="catch" & d$internalMotion==1,], binomSEM)$rr

#pdf("tessa.pdf",height=4,width=5)
#pdf("cleanthis.pdf",height=4,width=5)

ggplot(d[d$cond_code!="catch" & d$internalMotion==1,],aes(x=dY, y=rr, color=dur,group=dur))+facet_grid(speed~ecc+dur)+geom_vline(xintercept=0,size=0.2)+geom_hline(yintercept=0.5,size=0.2)+geom_smooth(method="glm",method.args=list(family=binomial(logit)),se=T)+geom_point(data=dag)+geom_errorbar(data=dag,aes(ymin=rr-se,ymax=rr+se))+theme_bw()+labs(x="vertical offset [deg]",y="probability of choosing donward-drifting target")

#dev.off()

# plot control
dag <- aggregate(cbind(rr, dY)~ecc+dur+speed+bin_dY,d[d$internalMotion==0,], mean)
dag$se <- aggregate(rr~ecc+dur+speed+bin_dY,d[d$internalMotion==0,], binomSEM)$rr
ggplot(d[d$internalMotion==0,],aes(x=dY, y=rr, color=dur,group=dur))+facet_grid(ecc~dur)+geom_vline(xintercept=0,size=0.2)+geom_hline(yintercept=0.5,size=0.2)+geom_smooth(method="glm",method.args=list(family=binomial(logit)),se=T)+geom_point(data=dag)+geom_errorbar(data=dag,aes(ymin=rr-se,ymax=rr+se))+theme_bw()+labs(x="vertical offset [deg]",y="probability of choosing donward-drifting target")
