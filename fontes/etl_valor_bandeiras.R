library(rvest)

url <- "https://clarke.com.br/entenda-o-historico-do-sistema-de-bandeiras-tarifarias-no-brasil/"
caminho_seletor_datas <- "#post-6005 > div > div > div > p:nth-child(22) > b"
caminho_seletor_amarela <- "#post-6005 > div > div > div > ul:nth-child(23) > li:nth-child(2) > span"
caminho_seletor_vermelha1 <- "#post-6005 > div > div > div > ul:nth-child(23) > li:nth-child(3) > span"
caminho_seletor_vermelha2 <- "#post-6005 > div > div > div > ul:nth-child(23) > li:nth-child(4) > span"
padrao_iter <- "(p\\:nth\\-child|ul\\:nth\\-child)\\(([0-9]+)\\)"
padrao_extracao <- "(.*R\\$ ([0-9]),?([0-9]*).*)"
webpage <- read_html(url)
texto_datas_cru <- c()
texto_amarela_cru <- c()
texto_vermelha1_cru <- c()
texto_vermelha2_cru <- c()

for (i in 22:29) {
    # nth-child(i), i par: data de mudança
    # nth-child(i), i ímpar: bandeiras
    if ((i %% 2) == 0) {
        texto_datas_cru <- append(
            texto_datas_cru,
            webpage %>%
            html_element(
                css = gsub(padrao_iter, paste0("\\1(", i, ")"), caminho_seletor_datas)
            ) %>%
            html_text2()
        )
    } else {
        texto_amarela_cru <- append(
            texto_amarela_cru,
            webpage %>%
            html_element(
                css = gsub(padrao_iter, paste0("\\1(", i, ")"), caminho_seletor_amarela)
            ) %>%
            html_text2()
        )
        texto_vermelha1_cru <- append(
            texto_vermelha1_cru,
            webpage %>%
            html_element(
                css = gsub(padrao_iter, paste0("\\1(", i, ")"), caminho_seletor_vermelha1)
            ) %>%
            html_text2()
        )
        texto_vermelha2_cru <- append(
            texto_vermelha2_cru,
            webpage %>%
            html_element(
                css = gsub(padrao_iter, paste0("\\1(", i, ")"), caminho_seletor_vermelha2)
            ) %>%
            html_text2()
        )
    }
}

datas <- gsub("([A-Z][a-z]+) de ([0-9]+)", "\\1 \\2", texto_datas_cru) %>%
    gsub("Novembro", "11", .) %>%
    gsub("Julho", "07", .) %>%
    paste0("01 ", .)

amarelo <- data.frame(
    datas = datas,
    valores = as.numeric(gsub(padrao_extracao, "\\2.\\3", texto_amarela_cru)) / 100,
    tipo = c("amarela", "amarela", "amarela", "amarela")
)

vermelho1 <- data.frame(
    datas = datas,
    valores = as.numeric(gsub(padrao_extracao, "\\2.\\3", texto_vermelha1_cru)) / 100,
    tipo = c("vermelha1", "vermelha1", "vermelha1", "vermelha1")
)

vermelho2 <- data.frame(
    datas = datas,
    valores = as.numeric(gsub(padrao_extracao, "\\2.\\3", texto_vermelha2_cru)) / 100,
    tipo = c("vermelha2", "vermelha2", "vermelha2", "vermelha2")
)

# fonte: https://www.edp.com.br/distribuicao-es/saiba-mais/informativos/bandeira-tarifaria
escassez <- data.frame(
    datas = c("01 09 2021", "01 10 2021"),
    valores = c(0.142, 0.142),
    tipo = "escassez"
)

bandeiras_df <- rbind.data.frame(
    amarelo,
    vermelho1,
    vermelho2,
    escassez,
    deparse.level = 1)

write.csv(bandeiras_df, "./bandeiras.csv")