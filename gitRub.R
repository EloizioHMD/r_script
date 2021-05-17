#' Script para Configurar o Git e Github no RStudio
#' por Eloízio Dantas
#' base na palestra do Jean Prado na Hacktoberfest 2020 da R-Ladies São Paulo
#' [Link do vídeo no youtube](https://www.youtube.com/watch?v=2gmofUthjKk)

#' Instalação do Pacote [usethis](https://usethis.r-lib.org/)
#' O usethis desenvolvido automatizar tarefas repetitivas que surgem durante
#' a configuração e o desenvolvimento do projeto, tanto para pacotes R quanto
#' para projetos sem pacote.

install.packages("usethis")
library(usethis)

# Se apresentar para o git
usethis::use_git_config(user.name = "Eloízio Dantas",
                        user.email = "eloiziohmd@hotmail.com")

git_sitrep()

# Editar o arquivo .Renviron
# O Renviron é um arquivo que fica no RStudio para armazenar dados sensíveis,
usethis::edit_r_environ()

# Crie o token do github e depois leve ao .Renviron
usethis::create_github_token()

# Depois de salvar reinicie o R (Ctrl + Shift + F10) em na aba session
# Use o git
usethis::use_git()

# Use o github
usethis::use_github()
