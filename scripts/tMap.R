#' ---------------------------------------------------------------------------
#' Script para Produção de Mapas com o TMAP
#' por Eloízio Dantas, em 17 de maio de 2021.
#' Baseado no script de [felipe barros](https://gitlab.com/geocastbrasil/liver/
#' ---------------------------------------------------------------------------

# Preparação para o script ---------------------------------------------------
install.packages('tmap') # https://github.com/mtennekes/tmap
install.packages('geobr') # https://github.com/ipeaGIT/geobr

library(sf) # ferramenta Geospacial
library(geobr) # Concetar dados do IBGE
library(tmap) # Mapas temáticos

dir.create("./scripts/data_tmap") # criando pasta no diretório

# Aquisição de dados para elaboração do mapa ---------------------------------
# Fonte da base de dados da [fbds](https://geo.fbds.org.br/)
# Shapefile da Massa d'água do Recife
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_MASSAS_DAGUA.cpg",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_MASSAS_DAGUA.cpg",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_MASSAS_DAGUA.dbf",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_MASSAS_DAGUA.dbf",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_MASSAS_DAGUA.prj",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_MASSAS_DAGUA.prj",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_MASSAS_DAGUA.shp",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_MASSAS_DAGUA.shp",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_MASSAS_DAGUA.shp.xml",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_MASSAS_DAGUA.shp.xml",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_MASSAS_DAGUA.shx",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_MASSAS_DAGUA.shx",
              mode = "wb")

# Shapefile da Nascentes do Recife
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_NASCENTES.cpg",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_NASCENTES.cpg",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_NASCENTES.dbf",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_NASCENTES.dbf",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_NASCENTES.prj",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_NASCENTES.prj",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_NASCENTES.shp",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_NASCENTES.shp",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_NASCENTES.shp.xml",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_NASCENTES.shp.xml",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_NASCENTES.shx",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_NASCENTES.shx",
              mode = "wb")

# Shapefile da Rios Duplos do Recife
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_DUPLOS.cpg",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_DUPLOS.cpg",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_DUPLOS.dbf",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_DUPLOS.dbf",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_DUPLOS.prj",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_DUPLOS.prj",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_DUPLOS.shp",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_DUPLOS.shp",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_DUPLOS.shp.xml",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_DUPLOS.shp.xml",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_DUPLOS.shx",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_DUPLOS.shx",
              mode = "wb")

# Shapefile da Rios Simples do Recife
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_SIMPLES.cpg",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_SIMPLES.cpg",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_SIMPLES.dbf",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_SIMPLES.dbf",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_SIMPLES.prj",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_SIMPLES.prj",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_SIMPLES.shp",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_SIMPLES.shp",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_SIMPLES.shp.xml",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_SIMPLES.shp.xml",
              mode = "wb")
download.file(url = "https://geo.fbds.org.br/PE/RECIFE/HIDROGRAFIA/PE_2611606_RIOS_SIMPLES.shx",
              destfile = "./scripts/data_tmap/RECIFE/PE_2611606_RIOS_SIMPLES.shx",
              mode = "wb")

# Importar dados geoespaciais para variáveis ---------------------------------
# Massa d'água
massa_daqua <- sf::st_read("./scripts/data_tmap/RECIFE/PE_2611606_MASSAS_DAGUA.shp")
massa_daqua
plot(massa_daqua$geometry)

# Nascente
nascente <- sf::st_read("./scripts/data_tmap/RECIFE/PE_2611606_NASCENTES.shp")
nascente
plot(nascente$geometry)

# Rios Duplos
rios_duplos <- sf::st_read("./scripts/data_tmap/RECIFE/PE_2611606_RIOS_DUPLOS.shp")
rios_duplos
plot(rios_duplos$geometry)

# Rio simples
rio_simples <- sf::st_read("./scripts/data_tmap/RECIFE/PE_2611606_RIOS_SIMPLES.shp")
rio_simples
plot(rio_simples$geometry)

# Recife
recife <- geobr::read_municipality(code_muni = 2611606)
recife
plot(recife$geom, col = 'gray')

PE <- geobr::read_municipality(code_muni = 'PE')
PE
plot(PE$geom, col = 'black')

#' Composição dos mapas -------------------------------------------------------
#' a composição de mapas segue a mesma lógica do ggplot2 de gráficos em camadas
#' gramática, onde na camada mais básica ficam as informações de fundo e na
#' superior os elementos mais visíveis.
#' ----------------------------------------------------------------------------
# Mapa base
mapabase <- tm_shape(PE, bbox = recife) + 
  tm_fill("lightgray") + 
  tm_borders("black") + 
  tm_shape(recife) + 
  tm_polygons(col = "beige")

# Mapa hidrológico
hidro <- tm_shape(rios_duplos) +
  tm_polygons(col = "deepskyblue3") + 
  tm_shape(rio_simples) +
  tm_lines(col='deepskyblue2') +
  tm_shape(massa_daqua) +
  tm_polygons(col='deepskyblue3') +
  tm_shape(nascente) + 
  tm_dots(col = "deepskyblue", size = .1)

# Mapa de estilo

estilo <- tm_compass(position=c("right", "top")) + 
  tm_layout(bg.color = "lightblue") +
  tm_scale_bar(position = "left") + 
  tm_layout(main.title = "Hidrografia do Recife/PE", legend.outside = T, main.title.position = 'center')

# Estilo padrão do pacote
# mapabase + hidro + tm_style("bw")
# mapabase + hidro + tm_style("classic")
# mapabase + hidro + tm_style("cobalt")
# mapabase + hidro + tm_style("col_blind")
              
# Para salvar imagem do mapa -------------------------------------------------
tmap::tmap_save(mapabase + hidro + estilo, filename = "./scripts/data_tmap/map_recife_hidro.png")

# Visualização por navegação do mapa -----------------------------------------
tmap_mode("plot")
tmap_mode("view")
webmap <- mapabase + hidro + estilo
webmap

# Modulo de exportar um widget para html -------------------------------------
tmap::tmap_save(mapabase + hidro + estilo, filename = "./scripts/data_tmap/map_recife_hidro.html",
                width = 20, 
                height = 20, 
                units = "cm", 
                dpi = 300)

# END ------------------------------------------------------------------------