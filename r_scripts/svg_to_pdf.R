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

#Cover pdf-Titelseite
path.pic <- snakemake@input[["cov_pic"]]
pic <- readPNG(path.pic)

par(mar = c(0,0,0,0))
pic <- readPNG(path.pic)
plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
border <- par()
rasterImage(pic, border$usr[1], border$usr[3], border$usr[2], border$usr[4])

legend(x = 0.43, y = 0.75, paste("Fachprojekt Reproduzierbare Datenanalyse mit\n", 
                             "Snakemake am Beispiel der Bioinformatik\n"), 
       cex = 1.6, text.col = "antiquewhite2", box.col = "transparent", adj = 0.5)
text(x = 0.50, y = 0.85, paste("RNA-seq data analysis"), 
     cex = 4, col = "antiquewhite2", family="serif", font=2, adj=0.5)
text(x = 0.7, y = 0.15, paste("Gruppe 1:\n",
                              "    Jana Jansen\n",
                              "    Ludmila Janzen\n",
                              "    Sophie Sattler\n",
                              "    Antonie Vietor"), 
     cex = 1.2, col = "antiquewhite2", family="sans", font=1, adj=0)
text(x = 0.25, y = 0.5, paste("Dr. Johannes Köster"), 
     cex = 1.6, col = "antiquewhite2", family="mono", font=4, adj=0)

for (i in seq(along=png_files)){
  im <- rasterGrob(readPNG(gsub(" ","", paste(path, "/",png_files[i])), native = FALSE), interpolate = FALSE)
  do.call(grid.arrange, c(list(im), ncol = 1))
}
dev.off()

delete_png <- file.remove((gsub(" ","", paste(path, "/",png_files))))
