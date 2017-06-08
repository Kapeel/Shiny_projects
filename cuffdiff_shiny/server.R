library(shiny)
library(deSolve)
library(cummeRbund)

# load cuffDiff data, must be in top dir and called cuffData.db:
cuff = readCufflinks()

shinyServer(function(input,output) {
    
	getData = reactive(function() {
		if (!nzchar(input$gene))
			return()
		return(getGene(cuff,input$gene))
	})
	
	output$genePlot  = reactivePlot(function() { 
		myGene = getData()
		#fudge to stop shiny trying to plot NULL, which results in an ugly black square:
		if (is.null(myGene))
        		return(plot(1,type="n",bty="n",yaxt="n",xaxt="n",ylab="",xlab=""))
		x = data.frame(
			tissue = fpkm(myGene)$sample_name,
			fpkm=fpkm(myGene)$fpkm
		)
		print(ggplot(x,aes(fill=tissue,x=tissue,y=fpkm)) + geom_bar(position="dodge", stat="identity") + 
			labs(title=annotation(myGene)$gene_short_name))
	})  

	output$isoformPlot  = reactivePlot(function() { 
		myGene = getData()
		if (is.null(myGene))
			return(plot(1,type="n",bty="n",yaxt="n",xaxt="n",ylab="",xlab=""))
		trackList=list()
		myStart=min(features(myGene)$start)
		myEnd=max(features(myGene)$end)
		myChr=unique(features(myGene)$seqnames)
		genome='hg19'
		ideoTrack = IdeogramTrack(genome = genome, chromosome = myChr)
		axtrack=GenomeAxisTrack()
		genetrack=makeGeneRegionTrack(myGene)
		biomTrack=BiomartGeneRegionTrack(genome=genome,chromosome=as.character(myChr),
			start=myStart,end=myEnd,name="ENSEMBL",showId=T)
		trackList=c(trackList,ideoTrack,axtrack,genetrack,biomTrack)
		plotTracks(trackList,from=myStart-5000,to=myEnd+5000)
	})
		
	output$tissueIsoformPlot  = reactivePlot(function() { 
		myGene = getData()
		if (is.null(myGene))
			return(plot(1,type="n",bty="n",yaxt="n",xaxt="n",ylab="",xlab=""))
		x = data.frame(
			isoform = fpkm(isoforms(myGene))[fpkm(isoforms(myGene))$sample_name==input$tissue,]$isoform_id,
			fpkm=fpkm(isoforms(myGene))[fpkm(isoforms(myGene))$sample_name==input$tissue,]$fpkm
		)
		print(ggplot(x,aes(fill=isoform,x=isoform,y=fpkm)) + geom_bar(position="dodge", stat="identity") + 
		labs(title=input$tissue) + opts(axis.text.x=theme_text(angle=90, hjust=1)))
	})
})

