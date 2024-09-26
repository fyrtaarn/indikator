## Alternative to source this file is to add this in code chunk
## source("tertial202401/setup.R", local = knitr::knit_global())

fdrive <- "f:/Forskningsprosjekter/PDB 3327 - Skader i Norge analy_"

# kodebok
kb <- fread(file.path(fdrive, "Data/Kodebok_Skader_i_Norge.csv"), encoding = "Latin-1")

# Somatikk
SOM <- fread(file.path(fdrive,"Data/02_extracted/NPR20240711/24_01903_som_til_utlevering.csv"),
             encoding = "Latin-1")

somdt <- unique(SOM)
somdt[, yr := year(innDato)]
somdt <- somdt[yr == 2024]
setkey(somdt, lopenr, innDato)

# FMDS
FMDS <- fread(file.path(fdrive,"Data/02_extracted/NPR20240711/24_01903_fmds_til_utlevering.csv"),
                encoding = "Latin-1")

fmddt <- unique(FMDS)
fmddt[, yr  := year(skadeDato)]
fmddt <- fmddt[yr == 2024]

setkey(fmddt, lopenr, skadeDato, skadeTid)

# Filter for fyrtårnenheter
fmddt[Ft_dummy_Kommunal == 1 | Ft_dummy_Spesialist == 1, insFmd := 1]

fmd <- fmddt[insFmd == 1]
fdd <- fmddt[!is.na(lopenr) & insFmd == 1]
