
### Test-svg-Dateien entfernen
### Eingabepfade und Speicherort muessen noch angepasst werden

#librsvg2-dev         #Installation from source on Linux or OSX
#librsvg2-devel       #On Fedora, CentOS or RHEL 
#librsvg              #On OS-X

#install.packages("rsvg")  #Installation on Windows
#install.packages("png")
#install.packages("grid")
#install.packages("gridExtra")

library(rsvg)
library(png)
library(grid)
library(gridExtra)

#####################################################################################
################### NUR ZUM TESTEN: Erzeugen von Test-svg-Dateien ################### 
x <- rnorm(10000)
cols <- c("red", "blue", "green", "yellow")

for (i in seq(along=cols)){

  svg(filename = gsub(" ", "", paste(as.character(i),".svg")))
  par(bg = cols[i])
  plot(x)
  dev.off()
}
#####################################################################################
#####################################################################################

svg_files <- unlist(list.files(getwd(), pattern = ".*\\.svg$"))

plots_png <- lapply (1:length(svg_files), function(i){
  out_file <- gsub(" ","", paste(strsplit(svg_files[i], "\\.")[[1]][1], ".png"))
  rsvg_png(svg_files[i], out_file)
})

png_files <- unlist(list.files(getwd(), pattern = ".*\\.png$"))

pdf("rna-seq_plots.pdf")
for (i in seq(along=png_files)){
  im <- rasterGrob(readPNG(png_files[i], native = FALSE), interpolate = FALSE)
  do.call(grid.arrange, c(list(im), ncol = 1))
}
dev.off()

delete_png <- file.remove(png_files)
