# Tabell for alovrlighet

# AIS 3+ ---------------------
dt3 <- acc[alvorlighetsgrad == 3]

sex3 <- show_pro(dt3, "kjonn", kb, value = F)
sex3[, item := "Kjønn"]
sex3 <- sex3[beskrivelse != "Total", ]

dt3[fodtAar_FMDS > 0, ageFMDS := lubridate::year(skadeDato) - fodtAar]
agegp3 <- do_agegroup(dt3, "ageFMDS", c(0, 15, 25, 45, 65, 80, Inf), "agegp")

age3 <- show_pro(agegp3, "agegp")
data.table::setnames(age3, "agegp", "beskrivelse")
age3[, item := "Alder"]
age3 <- age3[beskrivelse != "Total"]

frm3 <- show_pro(dt3, "fremkomstmiddel", kb, sort = "N", value = FALSE)
frm3[, item := "Fremkomstmiddel"]
frm3 <- frm3[beskrivelse != "Total"]

ais3 <- rbindlist(list(sex3, age3, frm3))
ais3[, alvor := "AIS 3+"]

# AIS 1&2 --------------------
dt12 <- acc[alvorlighetsgrad %in% 1:2]

sex2 <- show_pro(dt12, "kjonn", kb, value = F)
sex2[, item := "Kjønn"]
sex2 <- sex2[beskrivelse != "Total"]

dt12[fodtAar_FMDS > 0, ageFMDS := lubridate::year(skadeDato) - fodtAar]
agegp2 <- do_agegroup(dt12, "ageFMDS", c(0, 15, 25, 45, 65, 80, Inf), "agegp")

age2 <- show_pro(agegp2, "agegp")
data.table::setnames(age2, "agegp", "beskrivelse")
age2[, item := "Alder"]
age2 <- age2[beskrivelse != "Total"]

frm2 <- show_pro(dt12, "fremkomstmiddel", kb, sort = "N", value = FALSE)
frm2[, item := "Fremkomstmiddel"]
frm2 <- frm2[beskrivelse != "Total"]

ais2 <- rbindlist(list(sex2, age2, frm2))
ais2[, alvor := "AIS 1 & 2"]

# Merge -------
ais <- rbindlist(list(ais3, ais2))

tblAis <- dcast(ais, beskrivelse + item ~ alvor, value.var = c("N", "prosent"))

ordersty <- c("Kjønn", "Alder", "Fremkomstmiddel")
tblAis[, item := factor(item, levels = ordersty)]
tblAis <- tblAis[order(item)]

for (i in seq_len(ncol(tblAis))){
  if (!(is.character(i)))
    set(tblAis, which(is.na(tblAis[[i]])), j = i, value = 0 )
}


library("stringr")
coln <- colnames(tblAis) |>
  str_remove('(_AIS 1 & 2|_AIS 3\\+)') |>
  str_to_title()
names(coln) <- colnames(tblAis)

tblAis |>
  gt(groupname_col = 'item') |>
  cols_label(.list = coln) |>
  tab_spanner(
    label = md('**AIS 1 & 2**'),
    columns = contains("AIS 1 & 2")) |>
  tab_spanner(
    label = md('**AIS 3+**'),
    columns = contains("AIS 3+")) |>
  sub_zero(zero_text = "-") |>
  tab_options(
    data_row.padding = px(2),
    row_group.padding = px(4)) |>
  opt_stylize(style = 6, color = 'gray')
