library(rsvg)
library(png)
library(grid)
library(gridExtra)

path <- snakemake@input[["plots"]]


svg_files <- unlist(list.files(path, pattern = ".*\\.svg$"))

plots_png <- lapply (1:length(svg_files), function(i){
  out_file <- gsub(" ","", paste(path, "/", strsplit(svg_files[i], "\\.")[[1]][1], ".png"))
  rsvg_png(gsub(" ","", paste(path, "/", svg_files[i])), out_file)
})

png_files <- unlist(list.files(path, pattern = ".*\\.png$"))

pdf(file=snakemake@output[[1]])
for (i in seq(along=png_files)){
  im <- rasterGrob(readPNG(gsub(" ","", paste(path, "/",png_files[i])), native = FALSE), interpolate = FALSE)
  do.call(grid.arrange, c(list(im), ncol = 1))
}
dev.off()

delete_png <- file.remove((gsub(" ","", paste(path, "/",png_files))))

#x <- "test"
#pdf("test.pdf")#,width=5,height=5)
#plot.new()
#plot(NA, xlim=c(0,5), ylim=c(0,5), bty='n',
#     xaxt='n', yaxt='n', xlab='', ylab='')
#text(x, pos = 1)
#cat(x)
#dev.off()

#pdf("test.pdf", height=13.7, paper="special")
#par(mfrow=c(1,2), oma=c(0,0,3,0),cex=0.5)
#plot.new()
#tx <- file("../sleuth/p-values_all_transcripts.csv", "r")
#while(length(line <- readLines(tx, 1)) > 0) {
#  text(line, "\n")
#}
#mtext("A nice-looking paragraph! Now this is what I call good advice!")
#dev.off() 


