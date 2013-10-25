# title       : Регрессионный анализ, часть 3
# subtitle    : Математические методы в зоологии - на R, осень 2013
# author      : Марина Варфоломеева
# ---
#   Множественная регрессия. I и II модели регрессии
# ========================================================

  
# Пример: птицы Австралии
# ========================================================
# Зависит ли обилие птиц в лесах Австралии от характеристик леса?  (Loyn, 1987)
# - `l10area` - Площадь леса, га
# - `l10dist` - Расстояние до ближайшего леса, км (логарифм)
# - `l10ldist` - Расстояние до ближайшего леса большего размера,
# км (логарифм)
# - `yr.isol` - Продолжительности изоляции, лет
# - `abund` - Обилие птиц
# setwd("C://mathmethr/w4") # установите рабочую директорию
# birds <- read.delim(file = "./data/loyn.csv")
library(XLConnect)
birds <- readWorksheetFromFile(file="./data/loyn.xls", sheet = 1)
str(birds)

# ########################################################
# Запишите в обозначениях R модель множественной линейной регрессии.



# ########################################################



# Подбираем модель
bird_lm <- lm(abund ~ l10area + l10dist + l10ldist + yr.isol, data = birds)
summary(bird_lm)

# # ########################################################
# Запишите уравнение множественной линейной регрессии (подставьте значения коэффициентов в модель)
# coef(bird_lm)
# bird_lm$call

# # ########################################################
 
#   Бета-коэффициенты 
# ========================================================
scaled_bird_lm <- lm(abund ~ scale(l10area) + scale(l10dist) + 
                       scale(l10ldist) + scale(yr.isol), data = birds)
coef(scaled_bird_lm)


# # ########################################################
# Определите по значениям beta-коэффициентов, какие факторы сильнее всего влияют на обилие птиц
summary(scaled_bird_lm)
# # ########################################################

# Качество подгонки модели. Скорректированный R^2
# ========================================================
summary(bird_lm)$adj.r.squared

#   Условия применимости множественной линейной регрессии
# ========================================================
# Проверка на колинеарность
install.packages("car") # "Companion for Applied Regression"
library(car)
vif(bird_lm) # variance inflation factors
sqrt(vif(bird_lm)) > 2 # есть ли проблемы?
1/vif(bird_lm) # tolerance

# # ########################################################
# Проверьте условия применимости линейной регрессии
# ========================================================
#   Постройте для стандартизованных остатков:
# - график зависимости от предсказанного значения
# - квантильный график
# Выполняются ли условия применения линейной регрессии?
# Используйте материалы прошлой лекции
# library(); fortify(); str(); mean(); sd(); ggplot(); aes()
# geom_abline(); geom_hline(); geom_point(); geom_smooth(); labs()



# # ########################################################  


library(ggplot2)
theme_set(theme_bw())
bird_diag <- fortify(bird_lm)
ggplot(data = bird_diag, aes(x = .fitted, y = .stdresid)) +
  geom_point(aes(size = .cooksd)) +          # расстояние Кука
  geom_smooth(method="loess", se = FALSE) +  # линия тренда
  geom_hline(yintercept = 0)                 # горизонтальная линия на уровне y = 0
mean_val <- mean(bird_diag$.stdresid)  
sd_val <- sd(bird_diag$.stdresid)
quantile_plot <- ggplot(bird_diag, aes(sample = .stdresid)) + 
  geom_point(stat = "qq") +
  geom_abline(intercept = mean_val, slope = sd_val) + # на эту линию должны ложиться значения
  labs(x = "Квантили стандартного нормального распределения", y = "Квантили набора данных")
quantile_plot


# Регрессия по I и II модели
# ========================================================
#   Пример: морфометрия поссумов
# possum <- read.table(file="./data/possum-small.csv", header = TRUE, 
#   sep = "\t", dec = ".") 
wb <- loadWorkbook("./../data/possum-small.xls")
possum <- readWorksheet(wb, sheet = 1)
str(possum)


# Зависит ли длина головы поссумов от общей длины тела?
ggplot(data = possum, aes(x = totall, y = headl)) + geom_point()


# RMA-регрессия (Ranged Major Axis Regression, RMA)
# ========================================================
install.packages("lmodel2")
library(lmodel2)
possum_rma <- lmodel2(headl ~ totall, data = possum,range.y="relative", 
                      range.x = "relative", nperm = 100)
possum_rma


# # ########################################################  
# Подставьте коэффициенты в уравнение линейной регрессии 
possum_rma$regression.results # Коэффициенты регрессии, нас интересует RMA

# # ########################################################  


#   График RMA-регрессии
# ========================================================
plot(possum_rma, "RMA", main = "", 
     xlab = "Общая длина, см", ylab = "Длина головы, мм")


# Тот же график в ggplot2
source(url("http://varmara.github.io/mathmethr-2013/w4-regression3/int_slope_lmodel2.R"))
reg_lines <- int_slope_lmodel2(possum_rma)
rma_plot <- ggplot(possum, aes(x = totall, y = headl)) + 
  geom_point() +
  geom_abline(data = reg_lines, 
              aes(intercept = intercept, slope = slope, 
                  colour = c("blue", "red", "red")),
              show_guide = TRUE, size = 1) + 
  scale_color_discrete(name = "",
                       labels = c("RMA-регрессия", "95% дов. инт. RMA-регрессии")) +
  labs(x = "Общая длина, см", y = "Длина головы, мм") + 
  theme(legend.position = 'bottom')
rma_plot


# Добавим для сравнения обычную регрессию
rma_plot + geom_smooth(method = 'lm', se = FALSE, aes(colour = 'green'), 
                       show_guide = FALSE, size = 1) +
  scale_colour_discrete(name = "Линии:", 
                        labels = c("RMA-регрессия", "OLS-регрессия", 
                                   "95% дов. инт. RMA-регрессии"))
