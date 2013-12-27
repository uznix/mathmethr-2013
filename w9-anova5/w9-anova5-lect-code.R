# title       : Дисперсионный анализ, часть 5
# subtitle    : Математические методы в зоологии - на R, осень 2013
# author      : Марина Варфоломеева
# ---
# Модели с повторными измерениями
library(XLConnect)
library(ez)
library(plyr)
library(reshape2)
library(gridExtra)
library(ggplot2)
theme_set(theme_bw() + theme(legend.key = element_blank()))
update_geom_defaults("point", list(shape = 19))

# Пример: Последствия превентивных пожаров в Австралийском буше для лягушек
# Меняется ли число песен самцов лягушек в местах, где прошел пожар? (Driscoll Roberts 1997)
# Зависимая переменная - разница числа лягушачих песен в горевшем и негоревшем месте
# - 6 территорий водосбора (на каждой горевшее и не горевшее места) 
# - 3 года наблюдений (1992 - до пожара, 1993 и 1994 - после пожара)
# Проверяли $H _0$ о том, что разность числа лягушачих песен между горевшими и негоревшими местами не будет различаться по годам.
frogs <- readWorksheetFromFile(file="./data/frogs.xlsx", 
                               sheet = 1)
head(frogs)

# Альтернативное представление данных - широкий формат
wfrogs <- dcast(data=frogs, BLOCK~YEAR, value.var="CALLS")
wfrogs

# Превращаем в факторы год и блок
frogs$YEAR <- factor(frogs$YEAR, labels = c("Y1", "Y2", "Y3"))
frogs$BLOCK <- factor(frogs$BLOCK)
str(frogs)

# Боксплоты разницы числа лягушачих песен
ggplot(data = frogs, aes(x = YEAR, y = CALLS)) + geom_boxplot()

# Сбалансированный ли дизайн?
table(frogs$BLOCK, frogs$YEAR)
ezDesign(frogs, x = YEAR, y = BLOCK)

# Подбираем линейную модель при помощи ezANOVA
(res <- ezANOVA(frogs, dv=.(CALLS), wid=.(BLOCK), within=.(YEAR), detailed = TRUE))
# Визуализируем эффект
# Таблица со средними значениями
ezStats(data = frogs, dv=.(CALLS), 
        wid=.(BLOCK), within=.(YEAR))

# График различий между годами
ezPlot(data = frogs, dv=.(CALLS), 
       wid=.(BLOCK), within=.(YEAR), 
       x = YEAR)


# Таблица результатов?
res$ANOVA

# Влияние блока можем посчитать сами  
# тестировать эффект блока можно только если нет взаимодействия c годом
# Есть ли данные в пользу взаимодействия BLOCK и YEAR?
mod <- lm(CALLS ~ BLOCK + YEAR, frogs)
df <- fortify(mod)
p1 <- ggplot(df, aes(x = .fitted, y = .stdresid)) + geom_point() + geom_hline()
p2 <- ggplot(frogs, aes(x = BLOCK, y = CALLS, group = YEAR)) + 
  geom_line(stat = "summary", fun.y = "mean")
grid.arrange(p1, p2, ncol = 2)

# F _{BLOCK} = MS _{BLOCK} / MS _{e}

SS_block <- res$ANOVA$SSd[1]
df_block <- res$ANOVA$DFd[1]
MS_block <- SS_block/df_block

SS_e <- res$ANOVA$SSd[2]
df_e <- res$ANOVA$DFd[2]
MS_e <- SS_e/df_e

F_block <- MS_block/MS_e
p_block <- 1 - pf(F_block, df_block, df_e)
signif <- p_block <= 0.05

cat("F =", F_block, ", p =", p_block)
signif

# Тестируем дополнительные условия применимости для анализа с повторными измерениями

# Сложная симметрия - дисперсии значений в тритментах равны и ковариации равны  
# т.е. включает в себя гомогенность дисперсий
var(wfrogs[, -1])

# Сферичность - Дисперсии разностей между тритментами должны быть равны
sph <- data.frame(call12 = wfrogs[, 2] - wfrogs[, 3], 
                  call13 = wfrogs[, 4] - wfrogs[, 2], 
                  call23 = wfrogs[, 4] - wfrogs[, 3])
sph # разности между группами
colwise(var)(sph)

# Тест Мокли (Mauchly) на сферичность
res$"Mauchly's Test for Sphericity"

# Поправки на сферичность
# Какую поправку применить?
res$"Sphericity Corrections"


# Более сложный дизайн
# Пример: гипоксия у жаб
# Реакция на гипоксию у жабы-аги (Mullens, 1993)
# Зависимая переменная - частота буккального дыхания
# - Для каждой жабы - 8 уровней концентрации кислорода (0, 5, 10, 15, 20, 30, 40, 50%)  
# Это фактор с повторными измерениями (= "внутрисубъектный", "within subjects")
# - У разных жаб 2 типа дыхания (буккальное, легочное)  
# Это обычный фактор (= "межсубъектный", "between subjects")
# Проверяли $H _0$ о том, что частота дыхательных движений не будет отличаться в зависимости от типа дыхания и от концентрации кислорода.

toads <- read.table("./data/mullens.csv", 
                    header = TRUE, sep = ",")
head(toads)

# Переименовываем переменные и делаем факторы факторами
names(toads)[2:3] <- c("BRTH", "O2")
toads$O2 <- factor(toads$O2)
toads$TOAD <- factor(toads$TOAD)
toads$BRTH <- factor(toads$BRTH)
str(toads)

# Данные в широком формате получаем из исходных
wtoads <- dcast(data=toads, TOAD + BRTH ~ O2, value.var="FREQBUC")
wtoads
# То же самое для квадратных корней из частоты буккального дыхания
wstoads <- dcast(data=toads, TOAD + BRTH ~ O2, value.var="SFREQBUC")
wstoads

# Что лучше использовать - частоту буккального дыхания или корень из нее?
# Частота дыхательных движений при разном типе дыхания
p <- ggplot(data = toads, aes(x = BRTH, y = FREQBUC)) + geom_boxplot()
grid.arrange(p, p %+% aes(y = SFREQBUC), ncol = 2)
# Частота дыхательных движений в зависимости от концентрации кислорода. 
# Слева - без учета типа дыхания, справа - с учетом типа дыхания
grid.arrange(p %+% aes(x = O2, y = FREQBUC),
             p %+% aes(x = O2, y = SFREQBUC), 
             p %+% aes(x = O2, y = FREQBUC, fill = BRTH) + 
               theme(legend.position = "bottom"),
             p %+% aes(x = O2, y = SFREQBUC, fill = BRTH) + 
               theme(legend.position = "bottom"), 
             ncol = 4)

# Сбалансированный ли здесь дизайн?
table(toads$BRTH, toads$O2)
table(toads$TOAD, toads$O2)
ezDesign(toads, x = TOAD, y = O2, row = BRTH)
# ezPrecis(toads)

# Дисперсионный анализ с повторными измерениями
rest <- ezANOVA(toads, dv=.(SFREQBUC), wid=.(TOAD), within=.(O2), 
                between=.(BRTH), detailed = TRUE, type=3)
rest

# Статистика по эффектам
ezStats(toads, dv=.(SFREQBUC), wid=.(TOAD), within=.(O2), 
        between=.(BRTH), type = 3)

# График эффектов ("interaction plot")
ezPlot(toads, dv=.(SFREQBUC), wid=.(TOAD), within=.(O2), 
       between=.(BRTH), type = 3, 
       x = O2, split = BRTH) + 
  theme(legend.position = c(0.85, 0.80), legend.key = element_blank())

# Проверяем сложную симметрию
var(wstoads[, -c(1, 2)])
# Проверяем сферичность при помощи теста Мокли
rest$"Mauchly's Test for Sphericity"

# Какую поправку применить?
rest$'Sphericity Corrections'

# Таблица результатов
rest$ANOVA
# Недостающее можем посчитать сами
# MS _{e\ b} = {SS _{e\ b}}/{df _{e\ b}}
# MS _{e\ w} = {SS _{e\ w}}/{df _{e\ w}}
