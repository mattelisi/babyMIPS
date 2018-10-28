# --------------------------------------------- #
rm(list=ls())
setwd("~/git_local/baby-motion/data")

# --------------------------------------------- #
## load data

# column names
col_names <- c("block","trial","alpha","fix_x","fix_y","soa","envDir","driftDir","movTime","contrast","wavelength","tempFreq","envSpeed","sigma","internalMotion","alphaJitter","tBeg","tFix","tEnd","tHClk","tResp","resp","trueDir","signed_error")

# here change the values according to subject number (00) and initials (XX) and session number (11)
# ./00XX/11/00XX11"
d <- read.table("./00ml/01/00ml01", col.names=col_names)
str(d)

# --------------------------------------------- #
## some explorative plots

hist(d$signed_error/pi*180, xlab="error [deg]", main="", col="grey",xlim=c(-180,180),breaks=20, main="catch trials")

# reformat trueDir in [-pi,pi)
d$trueDir <- d$trueDir %% (2*pi)
d$trueDir <- ifelse(d$trueDir>pi, d$trueDir-2*pi,d$trueDir)
plot(d$trueDir/pi*180, d$resp/pi*180, xlab="true direction [deg]",ylab="reported direction [deg]")
