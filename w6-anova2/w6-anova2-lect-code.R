# title       : Дисперсионный анализ, часть 2
# subtitle    : Математические методы в зоологии - на R, осень 2013
# author      : Марина Варфоломеева
# ---
#   Многофакторный дисперсионный анализ
# ========================================================
# Внимание: сегодня - только про фиксированные факторы
# Дисперсионный анализ для фиксированных факторов
# Пример: Возраст и память
# Почему пожилые не так хорошо запоминают? Может быть не так тщательно перерабатывают информацию? (Eysenck, 1974)
# Факторы:
#   - `Age` - Возраст:
#   - `Younger` - 50 молодых
# - `Older` - 50 пожилых (55-65 лет)
# - `Process` - тип активности:
#   - `Counting` - посчитать число букв
# - `Rhyming` - придумать рифму к слову
# - `Adjective` - придумать прилагательное
# - `Imagery` - представить образ
# - `Intentional` - запомнить слово 
# Зависимая переменная - `Words` - сколько вспомнили слов

library(ggplot2)
theme_set(theme_bw(base_size = 18))
update_geom_defaults("point", list(shape = 19)) 
memory <- read.delim(file="./data/eysenck.csv")
head(memory, 14)

  # Меняем порядок уровней для красоты
str(memory)
levels(memory$Age)
# Хотим, чтобы молодые шли первыми - меняем порядок уровней
memory$Age <- relevel(memory$Age, ref="Younger")


#   Посмотрим на боксплот
#   Этот график нам пригодится для представления результатов
ggplot(data = memory, aes(x = Age, y = Words)) + geom_boxplot(aes(fill = Process))
# некрасивый порядок уровней memory$Process
# переставляем в порядке следования средних значений memory$Words
memory$Process <- reorder(memory$Process, memory$Words, FUN=mean)

# Боксплот с правильным порядком уровней
mem_p <- ggplot(data = memory, aes(x = Age, y = Words)) + 
  geom_boxplot(aes(fill = Process))
mem_p

# Описательная статистика по группам
library(reshape)
# __Статистика по столбцам и по группам__ одновременно (n, средние, дисперсии, стандартные отклонения)
memory_summary <- ddply(memory, .variables = c("Age", "Process"), 
                        summarise, 
                        .n = sum(!is.na(Words)),
                        .mean = mean(Words), 
                        .var = var(Words),
                        .sd = sd(Words))
memory_summary # краткое описание данных
# - Какого типа здесь факторы?
# - Сбалансированный ли дизайн?

# Проверяем  условия применимости дисперсионного анализа
#   - Нормальное ли распределение?
# - Есть ли гомогенность дисперсий?
mem_p

# Cвязь дисперсий и средних
# - Есть ли гомогенность дисперсий?
# Данные взяли в кратком описании
ggplot(memory_summary, aes(x = .mean, y = .var)) + geom_point()

# Задаем модель со взаимодействием
# `Age:Process` - взаимодействие обозначается `:`
memory_aov <- aov(Words ~ Age + Process + Age:Process, data = memory)

# - То же самое можно записать иначе `Age*Process` - вместо всех факторов
memory_aov <- aov(Words ~ Age*Process, data = memory)

# Данные для графиков остатков
memory_diag <- fortify(memory_aov)
head(memory_diag, 3)

# Графики остатков
#   - Есть ли гомогенность дисперсий?
# - Не видно ли трендов в остатках?
ggplot(memory_diag, aes(x = .fitted, y = .stdresid)) + 
  geom_point(aes(size = .cooksd), position = position_jitter(width = .2)) + 
  geom_hline(yintercept = 0)

# Квантильный график
#   - Нормальное ли у остатков распределение?
ggplot(memory_diag) + geom_point(stat = "qq", aes(sample = .stdresid)) + 
  geom_abline(yintercept = 0, slope = sd(memory_diag$.stdresid))

# Результаты дисперсионного анализа
anova(memory_aov)

# Пост хок тест
# Взаимодействие достоверно, можно другое не тестировать
TukeyHSD(memory_aov, which=c("Age:Process"))

# Графики для результатов
# Боксплот 
mem_p # боксплот у нас уже есть

# Столбчатый график
mem_barp <- ggplot(data = memory_summary, aes(x = Age, y = .mean, ymin = .mean - .sd, ymax = .mean + .sd, fill = Process)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  geom_errorbar(width = 0.3, position = position_dodge(width = 0.9))
mem_barp

# Линии с точками
mem_linep <- ggplot(data = memory_summary, aes(x = Age, y = .mean, ymin = .mean - .sd, ymax = .mean + .sd, colour = Process, group = Process)) + 
  geom_point(size = 3, position = position_dodge(width = 0.9)) +
  geom_line(position = position_dodge(width = 0.9)) +
  geom_errorbar(width = 0.3, position = position_dodge(width = 0.9)) 
mem_linep

# library(gridExtra)
# grid.arrange(mem_p, mem_barp, mem_linep, ncol = 3)
# Максимум данных в минимуме чернил (Tufte, 1983)
mem_linep <- mem_linep + labs(x = "Возраст",  y = "Число запомненных слов") + scale_x_discrete(labels = c("Молодые", "Пожилые")) + 
  scale_colour_brewer(name = "Процесс", palette = "Dark2", 
                      labels = c("Счет", "Рифма", "Прилагательное",
                                 "Образ", "Запоминание")) + 
  theme(legend.key = element_blank())

# Проблемы несбалансированных дизайнов
# Данные для демонстрации
umemory <- memory
# Заменим 5 случайных NA
set.seed(2590) # чтобы на разных системах совп. случайные числа
umemory$Words[sample.int(100, 5)] <- NA

#####################################################
# Сделайте краткое описание данных
# - В каких группах численность меньше 10?
# создайте датафрейм umemory_summary
# ddply()
# summarise()
# sum(!is.na())
# mean()
# var()
# sd()
# umemory_summary <- 
#####################################################

#   # Красивый график из прошлого примера с другим датафреймом
#   `%+%` - заменяет датафрейм в `ggplot()`
mem_linep %+% umemory_summary

# Сравните результаты с использованием SS II и SS III
library(car)
umem_aov <- aov(Words ~ Age + Process + Age*Process, data = umemory)
Anova(umem_aov, type=2)
Anova(umem_aov, type=3)
