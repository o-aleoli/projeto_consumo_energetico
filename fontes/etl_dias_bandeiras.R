library(dplyr)

dias_verde <- read.csv("bandeira_verde.csv") %>%
    mutate(tipos = "verde")
dias_amarela <- read.csv("bandeira_amarela.csv") %>%
    mutate(tipos = "amarela")
dias_vermelha1 <- read.csv("bandeira_vermelha1.csv") %>%
    mutate(tipos = "vermelha1")
dias_vermelha2 <- read.csv("bandeira_vermelha2.csv") %>%
    mutate(tipos = "vermelha2")
escassez <- data.frame(
    data_referencia = c("2021-09-01", "2021-10-01"),
    dias_medidos = c(31, 32),
    tipos = c("escassez", "escassez")
)

dias_bandeiras <- rbind(
    dias_verde,
    dias_amarela,
    dias_vermelha1,
    dias_vermelha2,
    escassez
)
dias_bandeiras <- dias_bandeiras[
    order(
        as.Date(
            dias_bandeiras$data_referencia,
            format = "%Y-%m-%d"
        )
    ),
]

write.csv(dias_bandeiras, "dias_bandeiras.csv", row.names = FALSE)