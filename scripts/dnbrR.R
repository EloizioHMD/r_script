#' Script para calcular e  espacilizar ΔNBR pelos dados MODIS
#' Autor Eloízio Dantas em 2021-05-19
#' Baseado ao vídeo e notebook de Cássio Moquedace
#' [Github](https://github.com/moquedace/delta_nbr)
#' [Youtube](https://www.youtube.com/watch?v=PINuGoRUPC4)

# Limpeza, verificação e Preparação dos pacotes ------------------------------

gc() # Limpar a memória

pkg <- c("raster", "sf", "sp", "rgdal", "dplyr", "MODIStsp", "tmap","MODIS",
         "tmaptools", "gdalUtilities", "gdalUtils", "rgeos", "kableExtra", "geobr")
sapply(pkg, require, character.only = T)
## instale os pacotes que deram FALSE.
## install.packages("pacote")
## O MODIStsp é um pacote desenvolvido em shiny, talvez precise de mais pacotes

rm(list = ls()) # Serve para limpa o ambiente de trabalho

# Baixando dados -------------------------------------------------------------

MODIStsp() # data inicial
MODIStsp() # data final

pantanal_lim <- geobr::read_biomes(year = 2019) %>%
  filter(code_biome == 6) %>%
  st_transform(crs = "EPSG:5641")

tm_shape(pantanal_lim) + tm_sf() # Verificação da polígonal

# Preparando dados MODIS -----------------------------------------------------
# Lendo arquivo hdf 
nome_hdf <- list.files(path = "~/R/R_scripts/r_script/scripts/delta_nbr", 
                       pattern = ".hdf$", 
                       full.names = T)

# Extraindo raster
hdf_list <- list()

for (i in seq_along(nome_hdf)) {
  
  hdf_list[[i]] <- getSds(nome_hdf[i])
  
}

# Separando bandas
list_raster <- list()

list_raster[[1]] <- raster(readGDAL(hdf_list[[1]][["SDS4gdal"]][2], as.is = TRUE))
list_raster[[2]] <- raster(readGDAL(hdf_list[[2]][["SDS4gdal"]][2], as.is = TRUE))
list_raster[[3]] <- raster(readGDAL(hdf_list[[1]][["SDS4gdal"]][6], as.is = TRUE))
list_raster[[4]] <- raster(readGDAL(hdf_list[[2]][["SDS4gdal"]][6], as.is = TRUE))
list_raster[[5]] <- raster(readGDAL(hdf_list[[3]][["SDS4gdal"]][2], as.is = TRUE))
list_raster[[6]] <- raster(readGDAL(hdf_list[[4]][["SDS4gdal"]][2], as.is = TRUE))
list_raster[[7]] <- raster(readGDAL(hdf_list[[3]][["SDS4gdal"]][6], as.is = TRUE))
list_raster[[8]] <- raster(readGDAL(hdf_list[[4]][["SDS4gdal"]][6], as.is = TRUE))

nomes <- c("2019.b2.1", "2019.b2.2", "2019.b6.1", "2019.b6.2", "2020.b2.1", "2020.b2.2", "2020.b6.1", "2020.b6.2")

names(list_raster) <- nomes

# Mosaico
b2_2019_mosaico <- mosaic(list_raster[["2019.b2.1"]],
                          list_raster[["2019.b2.2"]], fun = mean)

b6_2019_mosaico <- mosaic(list_raster[["2019.b6.1"]],
                          list_raster[["2019.b6.2"]], fun = mean)

b2_2020_mosaico <- mosaic(list_raster[["2020.b2.1"]],
                          list_raster[["2020.b2.2"]], fun = mean)

b6_2020_mosaico <- mosaic(list_raster[["2020.b6.1"]],
                          list_raster[["2020.b6.2"]], fun = mean)

# Calculando o Normalized Burn Ratio (NBR) -----------------------------------
f.nbr <- function(x, y){
  nbr <- (x - y) / (x + y)
  return(nbr)
}

nbr_2019 <- f.nbr(b2_2019_mosaico, b6_2019_mosaico)

nbr_2020 <- f.nbr(b2_2020_mosaico, b6_2020_mosaico)

# Visualização do NBR 2019-2020 ----------------------------------------------
nbr_2019_fig <- tm_shape(nbr_2019, raster.downsample = T) +
  tm_raster(midpoint = NA, style = "fisher") +
  tm_layout(legend.outside = T, main.title = "NBR 2019")

nbr_2020_fig <- tm_shape(nbr_2020, raster.downsample = T) +
  tm_raster(midpoint = NA, style = "fisher") +
  tm_layout(legend.outside = T, main.title = "NBR 2020")

tmap_arrange(nbr_2019_fig, nbr_2020_fig)

# Calculando o Delta (Δ) Normalized Burn Ratio (NBR) -------------------------
delta_nbr <- nbr_2019 - nbr_2020

tm_shape(delta_nbr, raster.downsample = T) +
  tm_raster(midpoint = NA, style = "fisher") +
  tm_layout(legend.outside = T)

# Ajustando o Delta (Δ) Normalized Burn Ratio (NBR) --------------------------
delta_nbr <- projectRaster(delta_nbr, crs = crs(pantanal_lim))

delta_nbr_mask <- delta_nbr %>% 
  crop(pantanal_lim) %>% 
  mask(pantanal_lim)

tm_shape(delta_nbr_mask, raster.downsample = F) +
  tm_raster(midpoint = NA, style = "fisher", palette = "-RdYlGn") +
  tm_layout(legend.outside = T)

# Reclassificando valores do Delta (Δ) Normalized Burn Ratio (NBR) -----------
# Fonte: [USGS](https://burnseverity.cr.usgs.gov/pdfs/LAv4_BR_CheatSheet.pdf)
categ_queima <- data.frame("NBR" = c("< -0,25", "-0,25 a -0,1", "-0,1 a +0,1", "0,1 a 0,27", "0,27 a 0,44", "0,44 a 0,66", "> 0,66"), 
                           "classe" = c("Alta regeneração pós-fogo", "Baixo crescimento pós-fogo", "Não queimado", "Queimada de baixa gravidade", "Queimada de gravidade moderada-baixa", "Queimada de gravidade moderada-alta", "Queimada de alta gravidade" ))

categ_queima %>%
  mutate_if(is.numeric, function(x) {
    cell_spec(x, bold = T, 
              color = spec_color(x, end = 0.9),
              font_size = spec_font_size(x))
  }) %>%
  mutate(classe = cell_spec(
    classe, color = "white", bold = T,
    background = spec_color(1:7, end = 0.9, option = "B", direction = -1)
  )) %>%
  kable(escape = F, align = "c", col.names = c("$\\Delta$ NBR", "Categoria"), caption = "**Tabela 1 - Distribuição dos intervalos $\\Delta$ NBR de acordo com a categoria de severidade da queimada **") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "bordered"), full_width = T)

# Criando matrix de classificação
m_rec <- matrix(c(-Inf, -0.25, 1,
                  -0.25, -0.1, 2,
                  -0.1, 0.1, 3,
                  0.1, 0.27, 4,
                  0.27, 0.44, 5,
                  0.44, 0.66, 6,
                  0.66, Inf, 7),
                ncol = 3, byrow = T)

# Aplicando reclassificação
reclas_nbr <- raster::reclassify(delta_nbr_mask, rcl = m_rec)
hist(reclas_nbr)

# Calculando área das classes
area_classe <- raster::zonal(reclas_nbr, reclas_nbr, fun = "count") *
  (prod(res(reclas_nbr))) / 1e+6

# Atribuindo nome as classes
n_classes <- c("Alta regeneração pós-fogo",
               "Baixo crescimento pós-fogo",
               "Não queimado",
               "Queimada de baixa gravidade",
               "Queimada de gravidade moderada-baixa", 
               "Queimada de gravidade moderada-alta",
               "Queimada de alta gravidade")

categ <- data.frame("categoria" = n_classes, "area_km_2" = area_classe[, 2])

# Criando mapa final ---------------------------------------------------------
# Definindo extensão 
bbox.pantanal <- st_bbox(reclas_nbr)

xrange <- bbox.pantanal$xmax - bbox.pantanal$xmin
yrange <- bbox.pantanal$ymax - bbox.pantanal$ymin

bbox.pantanal[1] <- bbox.pantanal[1] - (0.3 * xrange) 
bbox.pantanal[3] <- bbox.pantanal[3] + (0.3 * xrange) 
bbox.pantanal[2] <- bbox.pantanal[2] - (0.05 * yrange) 
bbox.pantanal[4] <- bbox.pantanal[4] + (0.05 * yrange)

bbox.pantanal <- bbox.pantanal %>% st_as_sfc()

# Legendas
legend_p <- "Dados: MODIS Terra MOD09A1\nLimites bioma: IBGE\nDatum: SIRGAS 2000\nResolução espacial: 500m"

# Mapa
mapa_pronto <- tm_shape(reclas_nbr, raster.downsample = F, bbox = bbox.pantanal) +
  tm_graticules(lines = F, n.x = 3, n.y = 4, labels.rot = c(0, 90),
                labels.size = 1) + # Adicionando e configurando grid de coordenadas
  tm_raster(style = "cat", palette = "-RdYlGn", # Definindo cor e estilo da paleta
            labels = paste0(categ$categoria, " (", # Atribuindo texto e área das categorias na legenda
                            trimws(format(round(categ$area_km_2, 1),
                                          nsmall = 1, big.mark = ".",
                                          decimal.mark = ",")), " km²)"),
            title = expression(bold(paste(Delta, " NBR", " (USGS)")))) + # Adicionando título da legenda
  tm_layout(legend.title.fontface = "bold", # Título da legenda em negrito
            legend.text.size = 0.65, # Tamanho do texto da legenda
            legend.position = c("RIGHT", "bottom"), # Posição da legenda
            legend.format = list(text.align = "left"), # Alinhando texto da legenda
            legend.width = 0.5) + # Largura da legenda
  tm_credits(text = legend_p, align = "center", fontface = "bold",
             position = c("left", "bottom")) + # Adicionando texto dos dados e configurando estilo
  tm_scale_bar(text.size = 0.5, width = 0.2, position = c("left", "bottom")) + # Adicionando escala ao mapa
  tm_compass(type ="8star", size = 4, position = c("right", "top")) + # Adicionando rosa dos ventos ao mapa
  tm_shape(pantanal_lim) + # Inserindo limites do Pantanal
  tm_borders(lwd = 0.75, col = "black") + # Cor e espessura da linha de borda
  tm_add_legend(type = "fill", col = "transparent", # Adicionando o limite do bioma a legenda do mapa
                border.col = 'black',
                labels =  "Limites Pantanal")

mapa_pronto

# Salvando mapa --------------------------------------------------------------
tmap::tmap_save(mapa_pronto, filename = "/home/eloiziodantas/R/R_scripts/r_script/scripts/delta_nbr/mapa_pronto.png",
          dpi = 600, 
          width = 12, 
          height = 6.75, 
          units = "in")

# Modulo de exportar um widget para html 
tmap::tmap_save(mapa_pronto, filename = "/home/eloiziodantas/R/R_scripts/r_script/scripts/delta_nbr/mapa_pronto.html",
                width = 12, 
                height = 6.75, 
                units = "in", 
                dpi = 600)

# END ------------------------------------------------------------------------