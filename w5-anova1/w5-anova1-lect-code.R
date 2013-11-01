# title       : Дисперсионный анализ, часть 1
# subtitle    : Математические методы в зоологии - на R, осень 2013
# author      : Марина Варфоломеева
# ========================================================
# Пакеты
# install.packages(c("reshape", "multcomp"))
library(reshape)
library(multcomp)
library(XLConnect)
library(ggplot2)
# чтобы кружочки были круглые (в Windows может быть не заметно на экране, но при выводе в файл должно работать)
update_geom_defaults("point", list(shape = 19)) 
# устанавливаем тему и относительный размер шрифта
theme_set(theme_bw(base_size = 16)) 

# Пример: рост корневой системы томатов
#Данные: Dr Ron Balham, Victoria University of Wellington NZ, 1971 - 1976.
# Фактор `trt`  - варианты обработки. Уровни фактора: (`Water` - вода, `1N` - 1 конц. удобрения, `3N` - 3 конц. удобрения, `D+1N` - гербицид + 1 конц. удобрения). Зависимая переменная `weight` - вес корневой системы томатов (г)
tomato <- readWorksheetFromFile(file="./data/tomato.xlsx", sheet = 1)
# tomato <- read.table(file="./data/tomato.csv", header=TRUE, dec = ",")
tomato

#   Для красоты на графиках упорядочиваем значения фактора `trt`
str(tomato)
tomato$trt <- factor(tomato$trt) # Если вы открывали из xls
levels(tomato$trt) # уровни фактора
# Хотим, чтобы первым был уровень "Water"
tomato$trt <- relevel(tomato$trt, ref = "Water")
str(tomato) # проверяем, что получилось

# В каких условиях корневая система лучше развивалась?
# ========================================================
tom_p <- ggplot(data = tomato, aes(x = trt, y = weight)) + 
  labs(x = "Обработка", y = "Вес, г")
tom_p + geom_boxplot()

# Дисперсионный анализ
# ========================================================
#   Посмотрим на данные
library(reshape) # есть удобные функции для описания данных
# статистику по столбцам можно получить так:
summarise(tomato, mean = mean(weight), variance = var(weight), sd = sd(weight), n = sum(!is.na(weight)))
# __Статистика по столбцам и по группам__ одновременно (n, средние, дисперсии, стандартные отклонения)
tomato_summary <- ddply(tomato, "trt", summarise, 
                        n = sum(!is.na(weight)),
                        mean = mean(weight), 
                        variance = var(weight),
                        sd = sd(weight))
tomato_summary # краткое описание данных

#   Этот график нам пригодится для представления результатов
tomato_p_means <- ggplot(tomato_summary, aes(x = trt, y = mean)) + 
  geom_bar(stat = "identity", fill = "gray70", colour = "black", width = 0.5) + 
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.2) +
  labs(x = "Обработка", y = "Вес, г")
tomato_p_means

# Проверяем  условия применимости дисперсионного анализа
# ========================================================
## Нормальность и гомогенность дисперсий - боксплот
ggplot(data = tomato, aes(x = trt, y = weight)) + geom_boxplot()

# Cвязь дисперсий и средних (проверка гомогенности дисперсий)
# Данные взяли в кратком описании
ggplot(tomato_summary, aes(x = mean, y = variance)) + geom_point()

# Дисперсионный анализ, чтобы сделать анализ остатков
tomato_aov <- aov(weight ~ trt, data=tomato)
# summary(tomato_aov)
# Данные для анализа остатков
tomato_diag <- fortify(tomato_aov)
head(tomato_diag)

# Графики остатков
ggplot(tomato_diag, aes(x = .fitted, y = .stdresid)) + geom_point(aes(size = .cooksd)) + geom_hline(yintercept = 0)
# Квантильный график
ggplot(tomato_diag) + geom_point(stat = "qq", aes(sample = .stdresid)) + 
  geom_abline(yintercept = 0, slope = sd(tomato_diag$.stdresid))

# Таблица дисперсионного анализа
# ========================================================
anova(tomato_aov)

# Post hoc тесты
# ========================================================
# - `glht()` - "general linear hypotheses testing"
# - `linfct` - гипотеза для тестирования
# - `mcp()` - функция, чтобы задать множественные сравнения (обычные пост-хоки)
# - `trt` = "Tukey" - тест Тьюки по фактору `trt`
library(multcomp)
tomato_pht <- glht(tomato_aov, linfct = mcp(trt = "Tukey"))
summary(tomato_pht)

# График результатов пост-хок теста.
tomato_p_anova <- tomato_p_means + 
  geom_text(aes(y = 0.5, label = c("AB", "A", "B", "AB")), colour = "white", size = 10)
tomato_p_anova

# Готовим результаты к представлению
# ========================================================
#   Приводим график в печатный вид
tomato_p_anova +
  scale_y_continuous(expand = c(0,0), limit = c(0, 3)) + 
  scale_x_discrete(labels = c("вода", "1 удобр.", "3 удобр.", "герб.+удобр."))
#   Сохраняем таблицу дисперсионного анализа в файл
medley_res <- anova(medley_aov) # Исходная таблица
# в xls или xlsx с помощью XLConnect
writeWorksheetToFile(data = medley_res, file = "medley_res.xls", sheet = "anova_table")
# в буфер обмена (без доп. настроек только Windows)
write.table(file = "clipboard", x = medley_res, sep = "\t")
