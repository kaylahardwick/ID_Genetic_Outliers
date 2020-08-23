#!/usr/bin/env Rscript

require(ggplot2)
require(dplyr)
require(gridExtra)

args=commandArgs(trailingOnly=TRUE)

Group=args[1]

data=read.table(paste("persample_IBD_DST_",Group,".txt",sep=""))
colnames(data)=c("ID","IBD","DST")

data_MedianD <- summarise(group_by(data, ID), MD = median(DST))
data_MedianI <- summarise(group_by(data, ID), MD = median(IBD))

samples=unique(data$ID)
#20 samples per plot
samples_split=split(samples, ceiling(seq_along(samples)/25))

for (x in 1:length(samples_split)){
	print(x)
	samples_to_plot=as.character(as.data.frame(samples_split[x])[,1])
	data_sub=subset(data,data$ID %in% samples_to_plot)
	data_sub_MedianD <- subset(data_MedianD,data_MedianD$ID %in% samples_to_plot)
	D=ggplot(data_sub,aes(x=data_sub$ID,y=data_sub$DST)) + 
		geom_boxplot(outlier.shape = NA) +
		geom_jitter(shape=16,position=position_jitter(width=0.2,height=0)) +
		theme(axis.title.x=element_blank(),axis.text.x = element_blank())+
		ylab("DST")+
		ylim(0,1.1)+
		geom_hline(yintercept=1,size=0.25)+
		geom_text(data = data_sub_MedianD, aes(x=data_sub_MedianD$ID, y=1.03, label = round(data_sub_MedianD$MD,2)), position = position_dodge(width = 0.8), size = 2, vjust = -0.5,colour="red",angle=45)          
	data_sub_MedianI <- subset(data_MedianI,data_MedianI$ID %in% samples_to_plot)
	I=ggplot(data_sub,aes(x=data_sub$ID,y=data_sub$IBD)) + 
		geom_boxplot(outlier.shape = NA) +
		geom_jitter(shape=16,position=position_jitter(width=0.2,height=0)) +
		theme(axis.title.x=element_blank(),axis.text.x = element_text(angle = 45,hjust = 1,size=5))+
		ylab("IBD")+
		ylim(0,1.1)+
		geom_hline(yintercept=1,size=0.25)+
		geom_text(data = data_sub_MedianI, aes(x=data_sub_MedianI$ID, y=1.03, label = round(data_sub_MedianI$MD,2)), position = position_dodge(width = 0.8), size = 2, vjust = -0.5,colour="red",angle=45)          
	outname=paste("DST_IBD_",Group,"_",x,".png",sep="")
	print(outname)
	png(outname,height=8,width=10,unit="in",res=400)
	grid.arrange(D,I, nrow=2)
	dev.off()
}
