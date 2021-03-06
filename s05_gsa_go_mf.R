#########################################################################################
##                                                                                     ##
## s05_gsa_go_mf.R                                                                     ##
## El presente script ejecuta varios GSA, uno para cada una de las comparaciones       ##
## estudiadas. Utilizamos los t�rminos GO referentes a funciones moleculares.          ##
## Autores: Antonio Manuel Trassierra Fresco, Francisco Garc�a Garc�a                  ##
##                                                                                     ##
#########################################################################################


date ()
Sys.info ()[c("nodename", "user")]
commandArgs ()
rm (list = ls ())
R.version.string ##"R version 3.2.1

# Cargamos las librer�as necesarias
library (mdgsa); packageDescription ("mdgsa", fields = "Version") #"1.2.0"

setwd("/home/atrassierra/meta_analysis/scripts")
try (source (".job.r")); try (.job)


# A. Preparamos la anotaci�n
#########################################################################################
setwd (file.path (.job$dir, "data", "data_annotation"))
anot2 <- read.table("annotation.txt", sep = ",", header = T, as.is = T)
dim(anot2) 
head(anot2)

# Algunos checkings:
table(is.na(anot2[, "HGNC.symbol"]))
table(is.na(anot2[, "GO.Term.Accession"]))
dim(anot2) 

table (anot2[, "HGNC.symbol"] == "")
table(anot2[,"GO.Term.Accession"]== "")

table(duplicated(anot2[, "HGNC.symbol"])) # Genes �nicos
table(duplicated(anot2[, "GO.Term.Accession"])) # GOs �nicos

anot <- annotMat2list (anot2)
# Convierte una matriz de anotacion con dos columnas (la primera con los id de los genes y la segunda
# con los id de la anotacion) en una lista de anotacion. Cada GO con los id_ensembl asociados
head (anot)
length (unique (anot2[,"GO.Term.Accession"]))


# Separaci�n en ontolog�as
annot <- splitOntologies (anot, na.rm = TRUE, verbose = TRUE)
length(annot)
sapply (annot, length)

# Selecci�n de ontolog�a
anot <- annot[["mf"]] # Funciones moleculares
length(anot)
sum (sapply (annot, length))

# Propagamos la anotaci�n
anot <- propagateGO (anot, verbose = TRUE)
length(anot)
# Los genes anotados bajo un GO heredan la anotacion de todos los ancestros


# Filtramos la anotaci�n
table(as.numeric(lapply(anot, length)))
sum(as.numeric(lapply(anot, length)))
as.numeric(lapply(anot, length))[1:5]

# Filtra los GO estableciendo un minimo y maximo de id_ensembl asociados a cada GO
length (anot)




# B. GSEA
#########################################################################################
setwd (file.path (.job$dir, "results", "difexp"))
ficheros <- dir()
ficheros <- ficheros[grep("RData", ficheros)]
ficheros

for (i in 1:length(ficheros)){
  setwd (file.path (.job$dir, "results", "difexp"))
  cat ("\n ============================= \n")
  print(ficheros[i])
  load(ficheros[i])
  
  # Transformamos los genes en un ranking
  final <- final[!is.na(final$genes), ]
  rindex <- indexTransform (index = final$value, method = "normalize")
  names(rindex) <- as.vector(final$genes)
  # Transforma el ranking para que su distribucion sea adecuada como variable independiente de un modelo de regresion logistica
  summary(rindex)
  
  anot <- annotFilter (annot = anot, index = rindex, minBlockSize = 5, maxBlockSize = 500)
  res <- uvGsa (index = rindex, annot = anot, fulltable = TRUE)
  print(table(res$padj < 0.05))
  
  # Realiza un analisis con un modelo de regresion logistica
  
  res[1:3,]
  save (list = "res", file = file.path (.job$dir, "results", "gsea", paste("go_mf_", ficheros[i], sep = "")))
}





# Salida
warnings ()
sessionInfo ()
q ("no")


