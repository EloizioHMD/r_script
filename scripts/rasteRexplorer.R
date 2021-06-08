#' ---------------------------------------------------------------------------
#' Script exploração de dados e elaboração dados preliminar para classificação
#' Serie R Classificação Machine Learning Parte 2
#' por Eloízio Dantas, em 2021-06-07
#' Baseado no curso da [RadarGeo](http://plataformaradargeo.com.br/curso_processamento_imagem/)
#' Processamento de imagens de satélite com software "R"
#' ---------------------------------------------------------------------------

# Carregando pacotes ---------------------------------------------------------

pkg <- c("raster", "rgdal", "rgeos", "ggplot2", "reshape2")
sapply(pkg, require, character.only = T)

#install.packages("raster")
#install.packages("rgdal")
#install.packages("rgeos")
#install.packages("ggplot2")
#install.packages("reshape2")

rm(pkg)

# Carregando dados processados -----------------------------------------------
L8_B1B7 <- stack("R/GDS/saida/L8_B1B7.tif")
names_L8_B1B7 <- read.table("R/GDS/saida/L8_B1B7.csv", header = T, sep = ',')
names(L8_B1B7) <- names_L8_B1B7[,2]
names(L8_B1B7)

L8_INDEX <- stack("R/GDS/saida/area_indices.tif")
names_L8_INDEX <- read.table("R/GDS/saida/area_indices.csv", header = T, sep = ',')
names(L8_INDEX) <- names_L8_INDEX[,2]
names(L8_INDEX)

rm(names_L8_B1B7, names_L8_INDEX) # limpar Renv

# Carregando arquivo de classificacao gerado no QGIS
amostra_classif <- readOGR("R/GDS/vector/mod_classif.shp")
View(data.frame(amostra_classif))

# Criando Modelo de Treinamento L8_B1B7 --------------------------------------
# Dissolvendo poligonos para valores unicos
classif_dslv <- gUnaryUnion(spgeom = amostra_classif, id = amostra_classif$classe)
classif_dslv # agora de 92 features restaram apenas 6

# Extrair atributos das classes com L8_B1B7
atributos_band <- raster::extract(x = L8_B1B7, y = classif_dslv)

# criando df para cada classe
agua <- data.frame(Classe = "Agua", atributos_band[[1]])
agricultura <- data.frame(Classe = "Agricultura", atributos_band[[2]])
CAD <- data.frame(Classe = "Caatinga Arborea Densa", atributos_band[[3]])
CHA <- data.frame(Classe = "Caatinga Herbacea Arbustiva", atributos_band[[4]])
solo <- data.frame(Classe = "Solo exposto", atributos_band[[5]])
urbano <- data.frame(Classe = "Urbano", atributos_band[[6]])

# Combinando os df
classif_band <- rbind(agua, agricultura, CAD, CHA, solo, urbano)

# Salvar o csv das classes extraidas do L8_B1B7
write.csv(classif_band, file = "R/GDS/vector/classif_band.csv")

# Criando Modelo de Treinamento L8_INDEX -------------------------------------
# Extrair atributos das classes com L8_INDEX
atributos_index <- raster::extract(x = L8_INDEX, y = classif_dslv)

# criando df para cada classe
agua_i <- data.frame(Classe = "Agua", atributos_index[[1]])
agricultura_i <- data.frame(Classe = "Agricultura", atributos_index[[2]])
CAD_i <- data.frame(Classe = "Caatinga Arborea Densa", atributos_index[[3]])
CHA_i <- data.frame(Classe = "Caatinga Herbacea Arbustiva", atributos_index[[4]])
solo_i <- data.frame(Classe = "Solo exposto", atributos_index[[5]])
urbano_i <- data.frame(Classe = "Urbano", atributos_index[[6]])

# Combinando os df
classif_index <- rbind(agua_i, agricultura_i, CAD_i, CHA_i, solo_i, urbano_i)

# Salvar o csv das classes extraidas do L8_INDEX
write.csv(classif_index, file = "R/GDS/vector/classif_index.csv")

# Criando visualizações para exploração dos dados ----------------------------
# Calcular o medio para cada uma das classes
agrupado_band <- group_by(classif_band, Classe)
media_refband <- summarise_each(agrupado_band, mean)

# Calculo das transpostas
refband <- t(media_refband[,1:7])

cores <- c("green", "blue", "yellow", "orange", "brown", "pink")
wavelength <- c(430, 450, 530, 640, 850, 1570, 2110)

# Gráfico do comportamente das classes espectrais
par(mar = c(5, 5, 4, 16), xpd = TRUE)
matplot(x = wavelength, y = refband, type = 'l', lwd = 3, lty = 1,
        xlab = "Comprimento de Onda (nm)", ylab = "Reflectancia",
        col = cores, ylim = c(0, 30000))
legend("topright", inset = c(- 0.68, 0), legend = media_refband$Classe, lty = 1, col = cores, ncol = 1, lwd = 2)

# Gráficos boxplot para classes e indices
classif_melt <- melt(classif_index)

ggplot(data = classif_melt, aes(Classe, value, fill = Classe)) + 
  geom_boxplot() + 
  facet_wrap(~variable, scales = 'free') + 
  theme(panel.grid.major = element_line(colour = "#d3d3d3"),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        text=element_text(family = "Tahoma"),
        axis.title = element_text(face="bold", size = 10),
        axis.text.x = element_text(colour="white", size = 0),
        axis.text.y = element_text(colour="black", size = 10),
        axis.line = element_line(size=1, colour = "black")) +
  theme(plot.margin = unit(c(1,1,1,1), "lines"))

# END ------------------------------------------------------------------------