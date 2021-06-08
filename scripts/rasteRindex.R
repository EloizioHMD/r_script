#' ---------------------------------------------------------------------------
#' Script para Carregamento de Raster e Aplicação de Índice espectrais
#' Serie R Classificação Machine Learning Parte 1
#' por Eloízio Dantas, em 2021-06-01
#' Baseado no curso da [RadarGeo](http://plataformaradargeo.com.br/curso_processamento_imagem/)
#' Processamento de imagens de satélite com software "R"
#' ---------------------------------------------------------------------------

# Carregando pacotes ---------------------------------------------------------

pkg <- c("raster", "rgdal", "rgeos", "sf")
sapply(pkg, require, character.only = T)

#install.packages("raster")
#install.packages("rgdal")
#install.packages("rgeos")
#install.packages("sf")

rm(pkg)

# Carregando imagem de Satélite ----------------------------------------------
# Sentinel: https://scihub.copernicus.eu/dhus/#/home
# Lansat: https://earthexplorer.usgs.gov/
# CBERS: http://www.dgi.inpe.br/CDSR/
options(stringsAsFactors = FALSE) # desligando a conversão de strings em fatores
rasterOptions(maxmemory = 1e+200, chunksize = 1e+200) # Melhorar a paralelização no raster
beginCluster(n = parallel::detectCores() - 1) # Melhorar a paralelização no raster

# carregando arquivos tif e pela expressao regular 'band'
all_band_r1 <- list.files("R/GDS/raster/LC08_L2SP_217066_20201008_20201016_02_T1_SR/", 
                       pattern = glob2rx("*SR_B*.TIF$"), full.names = T)
l8c_r1 <- stack(all_band_r1)
all_band_r2 <- list.files("R/GDS/raster/LC08_L2SP_217067_20201008_20201016_02_T1_SR/",
                       pattern = glob2rx("*SR_B*.TIF$"), full.names = T)
l8c_r2 <- stack(all_band_r2)

# mosaicando as duas cenas landsat8
l8c_mosaico <- mosaic(l8c_r1, l8c_r2, fun=mean)
#plot(l8c_mosaico$layer.5, main = "Mosaíco do NIR do Landsat 8")

# Carregando vetores dos municípios ------------------------------------------
area_int <- readOGR("R/GDS/vector/area_disolver.shp")
#plot(area_int)

# Recortar Mosaico pela área de interesse ------------------------------------
# Transformação do sistema de projeção para um único CRS 
crs(area_int)
crs(l8c_mosaico)
area_int_utm <- spTransform(x = area_int, CRSobj = crs(l8c_mosaico))
crs(area_int_utm)

# Mascara, cortar pela areas de interesse.
area_int_mask <- mask(x = l8c_mosaico, mask = area_int_utm)
area_int_crop <- crop(area_int_mask, area_int_utm)

#renomeando as bandas
names(area_int_crop) <- c("B1", "B2", "B3", "B4", "B5", "B6", "B7")
rm(l8c_r1, l8c_r2, l8c_mosaico, area_int_mask, area_int_utm)

# Salvando imagem recortada para area interesse das bandas 1-7
writeRaster(x = area_int_crop, filename = "R/GDS/saida/L8_B1B7.tif")
names_area <- names(area_int_crop)
write.csv(x = names_area, file = "R/GDS/saida/L8_B1B7.csv")

# Aplicacao de indices espectrais ---------------------------------------------
indices <- area_int_crop
names(indices) <- c("B1", "B2", "B3", "B4", "B5", "B6", "B7")

# Razao simples (SR)
indices$Simple_Ratio <- indices$B5 / indices$B4

# Indice de diferenca de vegetacao normalizada (NDVI)
indices$NDVI <- (indices$B5 - indices$B4)/(indices$B5 + indices$B4)

# indice de Vegetacao Ajustado ao Solo (SAVI)
indices$SAVI <- ((1 + 0.5) * (indices$B5 - indices$B4))/((indices$B5 + indices$B4) + 0.5)

# Indice de area foliar
indices$AFI <- log((0.69 - indices$SAVI)/(0.59))/0.91

# Indice de vegetacao melhorada (EVI)
indices$EVI <- 2.5 * (indices$B5 - indices$B4) / (indices$B5 + 6 * indices$B4 - 7.5 * indices$B2 + 1)

# Indice de agua da diferenca normalizada (NDWI)
indices$NDWI <- (indices$B3 - indices$B5)/(indices$B3 + indices$B5)

# Salvando imagem com os indices
writeRaster(x = indices, filename = "R/GDS/saida/area_indices.tif")
names_indices <- names(indices)
write.csv(x = names_indices, file = "R/GDS/saida/area_indices.csv")

# Plotando graficos dos indices em tons de cinza ------------------------------
par(mfrow = c(2,3))
plot(indices$Simple_Ratio, col = gray(0:100/100), main = "SR")
plot(indices$NDVI, col = gray(0:100/100), main = "NDVI")
plot(indices$SAVI, col = gray(0:100/100), main = "SAVI")
plot(indices$AFI, col = gray(0:100/100), main = "AFI")
plot(indices$EVI, col = gray(0:100/100), main = "EVI")
plot(indices$NDWI, col = gray(0:100/100), main = "NDWI")