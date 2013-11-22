# title       : Дисперсионный анализ, часть 4
# subtitle    : Математические методы в зоологии - на R, осень 2013
# author      : Марина Варфоломеева
# ---
#   Иерархический дисперсионный анализ
# ========================================================
# Пример: Содержание кальция в листьях турнепса
# - 4 растения
# - 3 листа с каждого растения (по две пробы с каждого листа)
library(XLConnect)
turn <- readWorksheetFromFile(file="./data/turnips.xlsx", 
                              sheet = 1)
head(turn)

library(ggplot2)
theme_set(theme_bw(base_size = 18))
update_geom_defaults("point", list(shape = 19))
# можно преобразовать leaf и plant в факторы по-одному
# turn$leaf <- factor(turn$leaf)
# turn$plant <- factor(turn$plant)
# но лучше это сделать сразу с обоими переменными
# sapply - применяет функцию к столбцам
turn[, 1:2] <- sapply(turn[, 1:2], factor)
library(plyr)
turn_summary <- ddply(turn, c("plant", "leaf"), summarise, 
                      .mean = mean(ca),
                      .sd = sd(ca))
ggplot(data = turn_summary, aes(x = leaf, y = .mean)) + 
  geom_point() + 
  geom_errorbar(aes(ymin = .mean - .sd, ymax = .mean + .sd), width = 0.2) + 
  facet_wrap(~ plant, ncol = 2)
# График главного эффекта
turn_summary_a <- ddply(turn, c("plant"), summarise, 
                        .mean = mean(ca),
                        .sd = sd(ca))
ggplot(data = turn_summary_a, aes(x = plant, y = .mean)) + 
  geom_point() + 
  geom_errorbar(aes(ymin = .mean - .sd, ymax = .mean + .sd), width = 0.2)

# У нас сбалансированный дисперсионный комплекс?
table(turn$plant, turn$leaf, useNA = "no")

# Внимание, мы собираемся использовать функцию gad() из пакета GAD
# Для нее важно, чтобы вложенные факторы были закодированы одинаково на всех уровнях

# Дисперсионный анализ со вложенными факторами
# ТОЛЬКО ДЛЯ СБАЛАНСИРОВАННЫХ ДАННЫХ
# -----------------------------------------------------------
install.packages("GAD")
library(GAD) # Дисперсионный анализ по Underwood, 1997
# задаем фиксированные и случайные факторы
turn$plant <- as.fixed(turn$plant)
turn$leaf <- as.random(turn$leaf)

# Подбираем подель дисперсионного анализа с помощью lm()
model <- lm(ca ~ plant + leaf %in% plant, data = turn)
# Таблица результатов иерархического дисперсионного анализа
model_gad <- gad(model)
options(digits = 3, scipen = 6) # для форматирования чисел в таблице
model_gad

# Данные для проверки условий применимости
model_diag <- fortify(model) # fortify() из ggplot2
head(model_diag)

# Проверим условия применимости
# Квантильный график - нормальное распределение остатков
p1 <- ggplot(model_diag) + geom_point(stat = "qq", aes(sample = .stdresid)) + 
  geom_abline(yintercept = 0, slope = sd(model_diag$.stdresid))
# График стандартизованных остатков - гомогенность дисперсий остатков 
# Расстояние Кука - наличие "выбросов"
p2 <- ggplot(model_diag, aes(x = .fitted, y = .stdresid)) + 
  geom_point(aes(size = .cooksd)) + geom_hline(yintercept = 0)
library(gridExtra)
grid.arrange(p1, p2, ncol = 2)

# Посчитаем компоненты дисперсии
# Средние квадраты
MSa <-model_gad$'Mean Sq'[1]
MSba <- model_gad$'Mean Sq'[2]
MSe <- model_gad$'Mean Sq'[3]
# численности групп
table(turn$plant, turn$leaf, useNA = "no")
b <- 3 # число групп по фактору B (листьев на растении)
n <- 2 # объем группы (измерений на листе)
VC <- data.frame (VCa = (MSa - MSba)/(n*b),
                  VCba = (MSba - MSe)/n,
                  VCe = MSe)
VC # компоненты дисперсии
VC/sum(VC)*100 # в процентах

# Для сравнения доля объясненной изменчивости для фикс. фактора 
# (эта-квадрат и частный эта-квадрат)
(etasq_a <- model_gad$'Sum Sq'[1]/sum(model_gad$'Sum Sq'))
(p_etasq_a <- model_gad$'Sum Sq'[1]/(model_gad$'Sum Sq'[1] + model_gad$'Sum Sq'[3]))

#--------------------------------------------------------------------
# Пример: Морские ежи и водоросли
# Влияет ли плотность морских ежей на обилие нитчаток в сублиторали? 
# (Andrew, Underwood, 1993)
# - Обилие ежей - 4 уровня (нет, 33%, 66%, 100%)
# - Площадка - 4 штуки (площадь 3-4 $м^2$; по 5 проб на площадке)

andr <- readWorksheetFromFile(file = "./data/andrew.xlsx", sheet = 1)
head(andr)
# Подготавливаем данные
str(andr)
andr$patchrec <- factor(andr$patchrec)
andr$treat <- factor(andr$treat)
str(andr)

####################################################################
# Сбалансированный ли у нас дисперсионный комплекс?
# Проведите дисперсионный анализ
# Проведите диагностику дисперсионного анализа
# Проверьте условия применимости дисперсионного анализа
# - нормальное распределение остатков
# - гомогенность дисперсий остатков
# Проверьте наличие "выбросов"
# Посчитайте компоненты дисперсии в процентах
# Постройте график средних значений
####################################################################