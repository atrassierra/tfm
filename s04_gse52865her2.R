#########################################################################################
##                                                                                     ##
## s04_gse52865her2.R                                                                  ##
## Script para la anotación de las DMRs, pondremos los genes a los que apuntan por     ##
## el método del promedio y del valor absoluto. Además, prepararemos el input para el  ##
## análisis de enriquecimiento funcional.                                              ##
## Autor: Antonio Manuel Trassierra Fresco                                             ##
##                                                                                     ##
#########################################################################################

# Cargamos las librerías necesarias

library(TxDb.Hsapiens.UCSC.hg19.knownGene)
library(bumphunter)
library(dplyr)

setwd('/home/atrassierra/GSE52865')

load('dmrs52865her2.RData')

# Preparamos la anotación y matcheamos los genes
anno <- annotateTranscripts(TxDb.Hsapiens.UCSC.hg19.knownGene) # Preparamos el input para matchGenes
genes <- matchGenes(dmrs$table, subject = anno) # Mactheamos genes con sus dmrs

data <- dmrs$table
data <- cbind(data, genes$name) # Juntamos la información de los genes en una misma tabla
names(data)[length(names(data))] <- "genes" # Cambiamos el nombre a la columna de los genes

datasorted <- data[order(-data$value),] # Ordenamos de mayor a menor nivel de metilación

# Escribimos el fichero

write.table(x = datasorted, file = "dmrgen52865her2.txt", row.names = FALSE, sep = "\t")

# Duplicados. Varias DMRs pueden apuntar a un mismo gen. Si esto ocurre, aunque no es lo más correcto,
# promediaremos la señal de metilación porque hay veces que la señal apunta a más metilaciónn en casos o 
# en controles y no sabemos como interpretarlo.

datasorted <- datasorted[, c("genes", "value")]

# Promedio

final <- datasorted %>% group_by(genes) %>% summarise(value = mean(value)) # Promediamos las DMR
final <- final[order(-final$value),] # Ordenamos de mayor a menor nivel de metilación diferencial
write.table(x = final, file = "genes52865her2prom.txt", row.names = FALSE, sep = "\t", quote = FALSE) # Input con el promedio para GSA
save(final, file = "genes52865her2prom.RData")

# Valor absoluto

final <- datasorted %>% group_by(genes) %>% summarise_each(funs(.[which.max(abs(.))])) # Nos quedamos con la DMR con mayor valor absoluto para cada gen
# Guardamos el resultado
write.table(x = final, file = "genes52865her2.txt", sep = "\t", row.names = FALSE, quote = FALSE) # Guardamos input para gsea con valor absoluto
save(final, file = "genes52865her2.RData")
