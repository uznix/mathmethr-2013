---
title       : Дисперсионный анализ, часть 5
subtitle    : Математические методы в зоологии - на R, осень 2013
author      : Марина Варфоломеева
job         : Каф. Зоологии беспозвоночных, СПбГУ
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : idea      # 
widgets     : [mathjax]            # {mathjax, quiz, bootstrap}
mode        : standalone # {selfcontained, standalone, draft}
---

Дисперсионный анализ
========================================================

- Модели с повторными измерениями




--- .learning

Вы сможете
========================================================

- Рассказать, как межиндивидуальные различия могут влиять на выявление эффектов других факторов
- Анализировать модели с повторными измерениями с одним или несколькими факторами

--- &twocol

# Исходные данные для дисперсионного анализа с повторными измерениями

*** left

выглядят так

Субъект | Обработка |
------ | ------- |
1 | A |
1 | B |
1 | C |
2 | A |
2 | B |
2 | C |
3 | A |
3 | B |
3 | C |
И т.д. | 

>- Один и тот же объект в нескольких вариантах обработки

*** right

или так

Субъект | Время |
------ | ------- |
1 | T1 |
1 | T2 |
1 | T3 |
2 | T1 |
2 | T2 |
2 | T3 |
3 | T1 |
3 | T2 |
3 | T3 |
И т.д. | 

>- Один и тот же объект несколько раз подвергается тому же воздействию

--- &twocol

# Один и тот же объект в нескольких вариантах обработки

*** left

выглядят так

Субъект | Обработка |
------ | ------- |
1 | A |
1 | B |
1 | C |
2 | A |
2 | B |
2 | C |
3 | A |
3 | B |
3 | C |
И т.д. | 

*** right

>- 20 улиток
  - При 3 значениях температуры измерили скорость каждой из 20
  - Температуры чередуются в случайном порядке


--- &twocol

# Один и тот же объект несколько раз подвергается тому же воздействию

*** left

Субъект | Время |
------ | ------- |
1 | T1 |
1 | T2 |
1 | T3 |
2 | T1 |
2 | T2 |
2 | T3 |
3 | T1 |
3 | T2 |
3 | T3 |
И т.д. | 

*** right

>- 20 улиток
  - Одно значение температуры
  - Скорость каждой улитки замеряли через 1, 3, 6 часов после начала экспозиции


--- &twocol

# Мы не можем учитывать только один фактор

*** left

Субъект | **Обработка / Время** |
------ | ------- |
1 | A |
1 | B |
1 | C |
2 | A |
2 | B |
2 | C |
3 | A |
3 | B |
3 | C |
И т.д. | 

*** right

Нужно учитывать индивидуальные различия субъектов:
все реагируют по-разному, есть у каждого свой "базовый" уровень.

--- &twocol

# Как могут выглядеть межиндивидуальные различия?

*** left

- Полностью одинаковые субъекты

<img src="figure/unnamed-chunk-1.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />


*** right

- Межиндивидуальные различия

<img src="figure/unnamed-chunk-2.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />


--- &twocol

# Где различия измерений замаскированы межиндивидуальными различиями?

*** left

<img src="figure/unnamed-chunk-3.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />


*** right

<img src="figure/unnamed-chunk-4.png" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" style="display: block; margin: auto;" />


---

# А теперь немного посчитаем


```r
library(XLConnect)
# library(car)
library(ez)
library(plyr)
library(reshape2)
library(gridExtra)
library(ggplot2)
theme_set(theme_bw() + theme(legend.key = element_blank()))
update_geom_defaults("point", list(shape = 19))
```


--- &twocol

# Пожары в Австралийском буше

*** left

Вот что бывает после большого пожара

<br />
<br />
<br />

<img src="http://www.abc.net.au/news/image/29022-16x9-340x191.jpg" width="500" title="after bushfire" alt="after bushfire"/>

*** right

Чтобы больших пожаров не было, устраивают превентивные пожары

<img src="http://www.esa.act.gov.au/wp-content/uploads/actrfs-hazard-reduction-burn-400x300.jpg" width="500" title="fuel-reduction burning" alt="fuel-reduction burning"/>

<div class="footnote">www.esa.act.gov.au; www.abc.net.au</div>

--- &twocol

# Пример: Последствия превентивных пожаров для лягушек

*** left

Меняется ли число песен самцов лягушек в местах, где прошел пожар? (Driscoll Roberts 1997)


```r
frogs <- readWorksheetFromFile(file="./data/frogs.xlsx", 
                               sheet = 1)
head(frogs)
```


```
##      BLOCK YEAR CALLS
## 1  logging   Y1     4
## 2   angove   Y1   -10
## 3  newpipe   Y1   -15
## 4 oldquinE   Y1   -14
## 5 newquinW   Y1    -4
## 6 newquinE   Y1     0
```


*** right

Зависимая переменная - разница числа лягушачих песен в горевшем и негоревшем месте

- 6 территорий водосбора (на каждой горевшее и не горевшее места) 
- 3 года наблюдений (1992 - до пожара, 1993 и 1994 - после пожара)

Проверяли $H _0$ о том, что разность числа лягушачих песен между горевшими и негоревшими местами не будет различаться по годам.

<div class="footnote">Данные из Quinn Keough 2002</div>

---

# Альтернативное представление данных - широкий формат

Каждая строка - один экспериментальный объект


```r
# Данные в широком формате получаем из исходных
wfrogs <- dcast(data=frogs, BLOCK~YEAR, value.var="CALLS")
wfrogs
```

```
##      BLOCK  Y1  Y2 Y3
## 1   angove -10  -1  8
## 2  logging   4  17 18
## 3  newpipe -15 -10  1
## 4 newquinE   0   5  1
## 5 newquinW  -4   6  0
## 6 oldquinE -14 -11 -2
```


<br />
- Способ лучше представить данные
- Для проверки условий применимости (сложная симметрия)
- Могут пригодятся для альтернативных вариантов подсчета дисперсионного анализа с повторными измерениями (`Anova()` из пакета `car`)

---

# Превращаем в факторы год и блок


```r
frogs$YEAR <- factor(frogs$YEAR, labels = c("Y1", "Y2", "Y3"))
frogs$BLOCK <- factor(frogs$BLOCK)
str(frogs)
```

```
## 'data.frame':	18 obs. of  3 variables:
##  $ BLOCK: Factor w/ 6 levels "angove","logging",..: 2 1 3 6 5 4 2 1 3 6 ...
##  $ YEAR : Factor w/ 3 levels "Y1","Y2","Y3": 1 1 1 1 1 1 2 2 2 2 ...
##  $ CALLS: num  4 -10 -15 -14 -4 0 17 -1 -10 -11 ...
```


---

# Боксплоты разницы числа лягушачих песен


```r
ggplot(data = frogs, aes(x = YEAR, y = CALLS)) + geom_boxplot()
```

<img src="figure/unnamed-chunk-10.png" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" style="display: block; margin: auto;" />


--- &twocol

# Сбалансированный ли дизайн?

*** left


```r
table(frogs$BLOCK, frogs$YEAR)
```

```
##           
##            Y1 Y2 Y3
##   angove    1  1  1
##   logging   1  1  1
##   newpipe   1  1  1
##   newquinE  1  1  1
##   newquinW  1  1  1
##   oldquinE  1  1  1
```


*** right


```r
ezDesign(frogs, x = YEAR, y = BLOCK)
```

<img src="figure/unnamed-chunk-13.png" title="plot of chunk unnamed-chunk-13" alt="plot of chunk unnamed-chunk-13" style="display: block; margin: auto;" />


---

# Подбираем линейную модель при помощи ezANOVA


```r
(res <- ezANOVA(frogs, dv=.(CALLS), wid=.(BLOCK), within=.(YEAR), detailed = TRUE))
```

```
## $ANOVA
##        Effect DFn DFd    SSn SSd      F       p p<.05     ges
## 1 (Intercept)   1   5   2.72 956 0.0142 0.90965       0.00237
## 2        YEAR   2  10 369.44 191 9.6601 0.00461     * 0.24365
## 
## $`Mauchly's Test for Sphericity`
##   Effect     W     p p<.05
## 2   YEAR 0.596 0.355      
## 
## $`Sphericity Corrections`
##   Effect   GGe  p[GG] p[GG]<.05   HFe   p[HF] p[HF]<.05
## 2   YEAR 0.712 0.0125         * 0.915 0.00617         *
```


--- &twocol

# Визуализируем эффект

*** left

Таблица со средними значениями


```r
ezStats(data = frogs, dv=.(CALLS), 
        wid=.(BLOCK), within=.(YEAR))
```

```
##   YEAR N  Mean    SD FLSD
## 1   Y1 6 -6.50  7.74 5.63
## 2   Y2 6  1.00 10.64 5.63
## 3   Y3 6  4.33  7.50 5.63
```


*** right

График различий между годами


```r
ezPlot(data = frogs, dv=.(CALLS), 
       wid=.(BLOCK), within=.(YEAR), 
       x = YEAR)
```

<img src="figure/unnamed-chunk-17.png" title="plot of chunk unnamed-chunk-17" alt="plot of chunk unnamed-chunk-17" style="display: block; margin: auto;" />


---

# Степени свободы и F критерий

Если А - фиксированный, B - случайный

Источник<br />изменчивости | $DF$    |  $F$      |
-------------------------- | ------- |-------- | 
A - межсубъектный фактор | $$(n _{between} - 1)$$ | $$MS _A / MS _B$$
Фактор с повторными измерениями (B'(A)) | $$(n _{subj.} - 1)$$ | $$MS _B / MS _e$$
Остаточная | $$(n _{between} - 1)(n _{within} - 1)$$ |

---

# Что должно быть в таблице результатов ?

>- Столбцы:
  - df
  - SS
  - MS
  - F
  - p
>- Строки:
  - A - межсубъектный фактор
  - B'(A) - Фактор с повторными измерениями (не обязательно, если нет взаимодействия A:B'(A))
  - Остаточная

---

# Что есть что в таблице результатов?


```r
res$ANOVA
```

```
##        Effect DFn DFd    SSn SSd      F       p p<.05     ges
## 1 (Intercept)   1   5   2.72 956 0.0142 0.90965       0.00237
## 2        YEAR   2  10 369.44 191 9.6601 0.00461     * 0.24365
```


Effect      | $DF _n$ | $DF _d$         | $SS _n$        | $SS _d$        | $F$   | $p$   | $p<0.05$ | ges
----------- | ------- | --------------- | -------------- | -------------- | ----- | ----- | -------- | ---
(Intercept) |         | $$df _{BLOCK}$$ |                | $$SS _{BLOCK}$$ |       |       |          | 
YEAR |$$df _{YEAR}$$ | $$df _{e}$$      | $$SS _{YEAR}$$ | $$SS _{e}$$ | $$F = \frac {SS _{YEAR} / df _{YEAR}} {SS _{e} / df _{e}} = MS _{YEAR} / MS _{e}$$ |

<br />
Влияние блока можем посчитать сами  
тестировать эффект блока можно только если нет взаимодействия c годом

$F = \frac {SS _{BLOCK} / df _{BLOCK}} {SS _{e} / df _{e}} = MS _{BLOCK} / MS _{e}$


*** pnotes

ges - Величина эффекта (Generalized Eta-Squared, см. Bakeman, 2005)

---

# Есть ли данные в пользу взаимодействия BLOCK и YEAR?


```r
mod <- lm(CALLS ~ BLOCK + YEAR, frogs)
df <- fortify(mod)
p1 <- ggplot(df, aes(x = .fitted, y = .stdresid)) + geom_point() + geom_hline()
p2 <- ggplot(frogs, aes(x = BLOCK, y = CALLS, group = YEAR)) + 
  geom_line(stat = "summary", fun.y = "mean")
grid.arrange(p1, p2, ncol = 2)
```

<img src="figure/unnamed-chunk-19.png" title="plot of chunk unnamed-chunk-19" alt="plot of chunk unnamed-chunk-19" style="display: block; margin: auto;" />


>- Нет:
  - нет паттернов на графике остатков
  - не видно взаимодействия на графике (линии более-менее параллельны)


--- &twocol

Effect      | $DF _n$ | $DF _d$         | $SS _n$        | $SS _d$        | $F$   | $p$   | $p<0.05$ | ges
----------- | ------- | --------------- | -------------- | -------------- | ----- | ----- | -------- | ---
(Intercept) |         | $$df _{BLOCK}$$ |                | $$SS _{BLOCK}$$ |       |       |          | 
YEAR |$$df _{YEAR}$$ | $$df _{e}$$      | $$SS _{YEAR}$$ | $$SS _{e}$$ | $$F = \frac {SS _{YEAR} / df _{YEAR}} {SS _{e} / df _{e}} = MS _{YEAR} / MS _{e}$$ |

```r
res$ANOVA
```

```
##        Effect DFn DFd    SSn SSd      F       p p<.05     ges
## 1 (Intercept)   1   5   2.72 956 0.0142 0.90965       0.00237
## 2        YEAR   2  10 369.44 191 9.6601 0.00461     * 0.24365
```


$F = \frac {SS _{BLOCK} / df _{BLOCK}} {SS _{e} / df _{e}} = MS _{BLOCK} / MS _{e}$

*** left


```r
SS_block <- res$ANOVA$SSd[1]
df_block <- res$ANOVA$DFd[1]
MS_block <- SS_block/df_block
SS_e <- res$ANOVA$SSd[2]
df_e <- res$ANOVA$DFd[2]
MS_e <- SS_e/df_e
F_block <- MS_block/MS_e
```


*** right


```r
p_block <- 1 - pf(F_block, df_block, df_e)
signif <- p_block <= 0.05
cat("F =", F_block, ", p =", p_block)
```

```
## F = 9.99 , p = 0.00121
```

```r
signif
```

```
## [1] TRUE
```


--- .segue

# Тестируем дополнительные условия применимости для анализа с повторными измерениями


---

# Сложная симметрия 

дисперсии значений в тритментах равны и ковариации равны  
т.е. включает в себя гомогенность дисперсий


```r
var(wfrogs[, -1])
```

```
##      Y1    Y2   Y3
## Y1 59.9  79.4 34.8
## Y2 79.4 113.2 57.8
## Y3 34.8  57.8 56.3
```


>- нет сложной симметрии

---

# Сферичность

Дисперсии разностей между тритментами должны быть равны


```r
sph <- data.frame(call12 = wfrogs[, 2] - wfrogs[, 3], 
                  call13 = wfrogs[, 4] - wfrogs[, 2], 
                  call23 = wfrogs[, 4] - wfrogs[, 3])
sph # разности между группами
```

```
##   call12 call13 call23
## 1     -9     18      9
## 2    -13     14      1
## 3     -5     16     11
## 4     -5      1     -4
## 5    -10      4     -6
## 6     -3     12      9
```

```r
colwise(var)(sph) # подозрительно, может, и нет сферичности
```

```
##   call12 call13 call23
## 1   14.3   46.6   53.9
```


---

# Что у нас со сферичностью?

Тест Мокли (Mauchly) на сферичность


```r
res$"Mauchly's Test for Sphericity"
```

```
##   Effect     W     p p<.05
## 2   YEAR 0.596 0.355
```


Формальный тест говорит, что скорее всего сферичность есть.

Но говорят, что лучше проводить поправку все равно, 

т.к. тест Мокли чувствителен к отклонением от нормальности

---

# Поправки на сферичность

$\epsilon$ - степень отклонения от сферичности (нет сферичности $\epsilon = 1$)

Поправка в значения $df$

$$df _{factor\ adj.} = df _{factor\ unadj.} \hat \epsilon$$

$$df _{e\ adj.} = df _{e\ unadj.} \hat \epsilon$$

<br />

- Поправка Гринхауса-Гейсера (Greenhouse Geisser 1959)
  - Если $\hat \epsilon < 0.75$ (если больше, то очень консервативный результат)

- Поправка Хюйна-Фельдта (Huynh, Feldt, 1976, Lecoutre, 1991)
  - Если $\hat \epsilon > 0.75$ (либеральнее, чем Гринхауса-Гейсера)

---

# Какую поправку применить?


```r
res$"Sphericity Corrections"
```

```
##   Effect   GGe  p[GG] p[GG]<.05   HFe   p[HF] p[HF]<.05
## 2   YEAR 0.712 0.0125         * 0.915 0.00617         *
```


<br />

>- $\hat \epsilon$ близко к 0.75, поэтому лучше поправку Хюйна-Фельдта

--- .segue

# Более сложный дизайн

--- &twocol

*** left

# Пример: гипоксия у жаб

Реакция на гипоксию у [жабы-аги](http://en.wikipedia.org/wiki/Cane_toad) (Mullens, 1993)

Зависимая переменная - частота буккального дыхания

- Для каждой жабы - 8 уровней концентрации кислорода (0, 5, 10, 15, 20, 30, 40, 50%)  
 Это фактор с повторными измерениями (= "внутрисубъектный", "within subjects")
- У разных жаб 2 типа дыхания (буккальное, легочное)  
 Это обычный фактор (= "межсубъектный", "between subjects")

Проверяли $H _0$ о том, что частота дыхательных движений не будет отличаться в зависимости от типа дыхания и от концентрации кислорода.

<div class = "footnote">Данные из Quinn, Keough, 2002, рис. upload.wikimedia.org</div>

*** right

<img src="http://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Canetoadfemale.jpg/320px-Canetoadfemale.jpg?uselang=ru" width="450"><img>


```r
toads <- read.table("./data/mullens.csv", 
                    header = TRUE, sep = ",")
head(toads)
```


```
##   TOAD BRTH.TYP O2LEVEL FREQBUC SFREQBUC
## 1    a     lung       0    10.6     3.26
## 2    a     lung       5    18.8     4.34
## 3    a     lung      10    17.4     4.17
## 4    a     lung      15    16.6     4.07
## 5    a     lung      20     9.4     3.07
## 6    a     lung      30    11.4     3.38
```


---

# Переименовываем переменные и делаем факторы факторами


```r
names(toads)[2:3] <- c("BRTH", "O2")
toads$O2 <- factor(toads$O2)
toads$TOAD <- factor(toads$TOAD)
toads$BRTH <- factor(toads$BRTH)
str(toads)
```

```
## 'data.frame':	168 obs. of  5 variables:
##  $ TOAD    : Factor w/ 21 levels "a","b","c","d",..: 1 1 1 1 1 1 1 1 2 2 ...
##  $ BRTH    : Factor w/ 2 levels "buccal","lung": 2 2 2 2 2 2 2 2 1 1 ...
##  $ O2      : Factor w/ 8 levels "0","5","10","15",..: 1 2 3 4 5 6 7 8 1 2 ...
##  $ FREQBUC : num  10.6 18.8 17.4 16.6 9.4 11.4 2.8 4.4 21.6 17.4 ...
##  $ SFREQBUC: num  3.26 4.34 4.17 4.07 3.07 ...
```


---

# Данные в широком формате получаем из исходных


```r
wtoads <- dcast(data=toads, TOAD + BRTH ~ O2, value.var="FREQBUC")
wtoads
```

```
##    TOAD   BRTH    0    5   10   15   20   30   40   50
## 1     a   lung 10.6 18.8 17.4 16.6  9.4 11.4  2.8  4.4
## 2     b buccal 21.6 17.4 22.4  8.4  3.0  3.8  6.4  3.2
## 3     c   lung  0.0  4.0 18.0 27.0 31.0 25.0 49.0 21.0
## 4     d buccal 38.0 34.8 31.4 28.4 29.2 32.0 12.8 22.2
## 5     e buccal 30.0 21.4  9.6 17.4 18.0 14.4  0.8  3.0
## 6     f buccal 20.0 22.4 14.4 17.2  6.4  2.8  3.6  4.0
## 7     g buccal 45.8 37.4 38.0 32.6 23.6 39.0 14.4 11.0
## 8     h   lung  2.4  6.6  8.4  4.2 11.4  7.8  4.8  5.8
## 9     i buccal 12.6  9.8 13.4  9.4  8.6  7.6  4.2  3.6
## 10    j   lung  3.0  4.0  5.6  9.2  6.2  4.0  2.8  2.8
## 11    k buccal  8.4  7.6 15.8  5.2  3.0  4.2  3.4  2.4
## 12    l buccal 12.6 22.2 13.8  9.6  9.4  8.8  5.8  5.2
## 13    m buccal 37.4 35.8 31.4 22.6 22.0 21.2 16.8 12.2
## 14    n buccal 31.6 21.4  9.8 10.4 11.4 17.4 12.2  2.8
## 15    o buccal 28.0 15.0 22.2 16.8 13.4  9.6  9.8  6.4
## 16    p buccal 31.4 44.0 24.0 40.2  9.2 13.4  9.8  9.0
## 17    q   lung  0.0  0.0  0.0  0.0  9.8  7.6  7.4  4.8
## 18    r buccal 16.6 17.2 16.2 14.6  8.4  6.6  4.8  5.2
## 19    s   lung 13.8 14.8 18.2 12.0 14.2  9.6  8.6  7.8
## 20    t   lung  4.6 17.6 22.4  8.4  4.4  3.8  6.4  3.8
## 21    u   lung  0.0  0.0 16.0 13.8  8.6 12.4  7.0  7.6
```

```r
# То же самое для квадратных корней из частоты буккального дыхания
wstoads <- dcast(data=toads, TOAD + BRTH ~ O2, value.var="SFREQBUC")
wstoads
```

```
##    TOAD   BRTH    0    5   10   15   20   30    40   50
## 1     a   lung 3.26 4.34 4.17 4.07 3.07 3.38 1.673 2.10
## 2     b buccal 4.65 4.17 4.73 2.90 1.73 1.95 2.530 1.79
## 3     c   lung 0.00 2.00 4.24 5.20 5.57 5.00 7.000 4.58
## 4     d buccal 6.16 5.90 5.60 5.33 5.40 5.66 3.578 4.71
## 5     e buccal 5.48 4.63 3.10 4.17 4.24 3.79 0.894 1.73
## 6     f buccal 4.47 4.73 3.79 4.15 2.53 1.67 1.897 2.00
## 7     g buccal 6.77 6.12 6.16 5.71 4.86 6.24 3.795 3.32
## 8     h   lung 1.55 2.57 2.90 2.05 3.38 2.79 2.191 2.41
## 9     i buccal 3.55 3.13 3.66 3.07 2.93 2.76 2.049 1.90
## 10    j   lung 1.73 2.00 2.37 3.03 2.49 2.00 1.673 1.67
## 11    k buccal 2.90 2.76 3.97 2.28 1.73 2.05 1.844 1.55
## 12    l buccal 3.55 4.71 3.71 3.10 3.07 2.97 2.408 2.28
## 13    m buccal 6.12 5.98 5.60 4.75 4.69 4.60 4.099 3.49
## 14    n buccal 5.62 4.63 3.13 3.22 3.38 4.17 3.493 1.67
## 15    o buccal 5.29 3.87 4.71 4.10 3.66 3.10 3.130 2.53
## 16    p buccal 5.60 6.63 4.90 6.34 3.03 3.66 3.130 3.00
## 17    q   lung 0.00 0.00 0.00 0.00 3.13 2.76 2.720 2.19
## 18    r buccal 4.07 4.15 4.02 3.82 2.90 2.57 2.191 2.28
## 19    s   lung 3.71 3.85 4.27 3.46 3.77 3.10 2.933 2.79
## 20    t   lung 2.14 4.20 4.73 2.90 2.10 1.95 2.530 1.95
## 21    u   lung 0.00 0.00 4.00 3.71 2.93 3.52 2.646 2.76
```


---

# Что лучше использовать - частоту буккального дыхания или корень из нее?


```r
p <- ggplot(data = toads, aes(x = BRTH, y = FREQBUC)) + geom_boxplot()
grid.arrange(p, p %+% aes(y = SFREQBUC), ncol = 2)
```

<img src="figure/unnamed-chunk-31.png" title="plot of chunk unnamed-chunk-31" alt="plot of chunk unnamed-chunk-31" style="display: block; margin: auto;" />

Частота дыхательных движений при разном типе дыхания

--- 

# Что лучше использовать - частоту буккального дыхания или корень из нее?


```r
grid.arrange(p %+% aes(x = O2, y = FREQBUC),
             p %+% aes(x = O2, y = SFREQBUC), 
             p %+% aes(x = O2, y = FREQBUC, fill = BRTH) + 
               theme(legend.position = "bottom"),
             p %+% aes(x = O2, y = SFREQBUC, fill = BRTH) + 
               theme(legend.position = "bottom"), 
             ncol = 4)
```

<img src="figure/unnamed-chunk-32.png" title="plot of chunk unnamed-chunk-32" alt="plot of chunk unnamed-chunk-32" style="display: block; margin: auto;" />

Частота дыхательных движений в зависимости от концентрации кислорода. Слева - без учета типа дыхания, справа - с учетом типа дыхания

--- &twocol

# Сбалансированный ли здесь дизайн?

*** left


```r
table(toads$BRTH, toads$O2)
```

```
##         
##           0  5 10 15 20 30 40 50
##   buccal 13 13 13 13 13 13 13 13
##   lung    8  8  8  8  8  8  8  8
```

```r
table(toads$TOAD, toads$O2)
```

```
##    
##     0 5 10 15 20 30 40 50
##   a 1 1  1  1  1  1  1  1
##   b 1 1  1  1  1  1  1  1
##   c 1 1  1  1  1  1  1  1
##   d 1 1  1  1  1  1  1  1
##   e 1 1  1  1  1  1  1  1
##   f 1 1  1  1  1  1  1  1
##   g 1 1  1  1  1  1  1  1
##   h 1 1  1  1  1  1  1  1
##   i 1 1  1  1  1  1  1  1
##   j 1 1  1  1  1  1  1  1
##   k 1 1  1  1  1  1  1  1
##   l 1 1  1  1  1  1  1  1
##   m 1 1  1  1  1  1  1  1
##   n 1 1  1  1  1  1  1  1
##   o 1 1  1  1  1  1  1  1
##   p 1 1  1  1  1  1  1  1
##   q 1 1  1  1  1  1  1  1
##   r 1 1  1  1  1  1  1  1
##   s 1 1  1  1  1  1  1  1
##   t 1 1  1  1  1  1  1  1
##   u 1 1  1  1  1  1  1  1
```


*** right


```r
ezDesign(toads, x = TOAD, y = O2, row = BRTH)
# ezPrecis(toads)
```

<img src="figure/unnamed-chunk-35.png" title="plot of chunk unnamed-chunk-35" alt="plot of chunk unnamed-chunk-35" style="display: block; margin: auto;" />


>- Несбалансированный дизайн - нужно выбрать тип сумм квадратов (например, III)

---

# Дисперсионный анализ 


```r
rest <- ezANOVA(toads, dv=.(SFREQBUC), wid=.(TOAD), within=.(O2), 
                between=.(BRTH), detailed = TRUE, type=3)
```

```
## Warning: Data is unbalanced (unequal N per group). Make sure you specified a
## well-considered value for the type argument to ezANOVA().
```

```r
rest
```

```
## $ANOVA
##        Effect DFn DFd    SSn SSd      F        p p<.05   ges
## 1 (Intercept)   1  19 1695.1 132 244.68 2.63e-12     * 0.880
## 2        BRTH   1  19   39.9 132   5.76 2.68e-02     * 0.147
## 3          O2   7 133   25.7 100   4.88 6.26e-05     * 0.100
## 4     BRTH:O2   7 133   56.4 100  10.69 1.23e-10     * 0.196
## 
## $`Mauchly's Test for Sphericity`
##    Effect      W         p p<.05
## 3      O2 0.0138 0.0000134     *
## 4 BRTH:O2 0.0138 0.0000134     *
## 
## $`Sphericity Corrections`
##    Effect   GGe     p[GG] p[GG]<.05   HFe      p[HF] p[HF]<.05
## 3      O2 0.428 0.0043333         * 0.517 0.00220836         *
## 4 BRTH:O2 0.428 0.0000113         * 0.517 0.00000187         *
```


---

# Статистика по эффектам


```r
ezStats(toads, dv=.(SFREQBUC), wid=.(TOAD), within=.(O2), 
        between=.(BRTH), type = 3)
```

```
## Warning: Data is unbalanced (unequal N per group). Make sure you specified a well-considered value for the type argument to ezANOVA().
## Warning: Unbalanced groups. Mean N will be used in computation of FLSD
```

```
##      BRTH O2  N Mean    SD  FLSD
## 1  buccal  0 13 4.94 1.177 0.749
## 2  buccal  5 13 4.72 1.167 0.749
## 3  buccal 10 13 4.39 0.978 0.749
## 4  buccal 15 13 4.07 1.198 0.749
## 5  buccal 20 13 3.40 1.141 0.749
## 6  buccal 30 13 3.48 1.405 0.749
## 7  buccal 40 13 2.70 0.929 0.749
## 8  buccal 50 13 2.48 0.921 0.749
## 9    lung  0  8 1.55 1.473 0.749
## 10   lung  5  8 2.37 1.729 0.749
## 11   lung 10  8 3.33 1.560 0.749
## 12   lung 15  8 3.05 1.540 0.749
## 13   lung 20  8 3.30 1.048 0.749
## 14   lung 30  8 3.06 0.971 0.749
## 15   lung 40  8 2.92 1.714 0.749
## 16   lung 50  8 2.56 0.904 0.749
```


---

# График эффектов ("interaction plot")


```r
ezPlot(toads, dv=.(SFREQBUC), wid=.(TOAD), within=.(O2), 
       between=.(BRTH), type = 3, 
       x = O2, split = BRTH) + 
  theme(legend.position = c(0.85, 0.80), legend.key = element_blank())
```

<img src="figure/unnamed-chunk-39.png" title="plot of chunk unnamed-chunk-39" alt="plot of chunk unnamed-chunk-39" style="display: block; margin: auto;" />


---

# Проверяем сложную симметрию


```r
var(wstoads[, -c(1, 2)])
```

```
##         0     5    10    15    20    30     40    50
## 0   4.439 3.413 1.648 1.664 0.570 0.994 -0.164 0.175
## 5   3.413 3.237 1.628 1.691 0.505 0.823  0.107 0.341
## 10  1.648 1.628 1.703 1.426 0.449 0.755  0.549 0.573
## 15  1.664 1.691 1.426 1.948 0.827 1.092  0.716 0.751
## 20  0.570 0.505 0.449 0.827 1.168 1.200  0.882 0.799
## 30  0.994 0.823 0.755 1.092 1.200 1.556  0.968 0.852
## 40 -0.164 0.107 0.549 0.716 0.882 0.968  1.558 0.874
## 50  0.175 0.341 0.573 0.751 0.799 0.852  0.874 0.796
```


>- Дисперсии ок, ковариации - не очень

---

# Проверяем сферичность при помощи теста Мокли


```r
rest$"Mauchly's Test for Sphericity"
```

```
##    Effect      W         p p<.05
## 3      O2 0.0138 0.0000134     *
## 4 BRTH:O2 0.0138 0.0000134     *
```

>- Вот здесь точно все несферично - нужно применять поправку Гринхауса-Гейсера или Хюйна-Фельдта

---

# Какую поправку применить?


```r
rest$'Sphericity Corrections'
```

```
##    Effect   GGe     p[GG] p[GG]<.05   HFe      p[HF] p[HF]<.05
## 3      O2 0.428 0.0043333         * 0.517 0.00220836         *
## 4 BRTH:O2 0.428 0.0000113         * 0.517 0.00000187         *
```


>- $\hat \epsilon _{GG} < 0.75$ - можно применять поправку Гринхауса-Гейсера

---

# Степени свободы и F критерий

Если А, С - фиксированные, B - случайный

Источник<br />изменчивости | $DF$    |  $F$      |
-------------------------- | ------- |-------- | 
Межсубъектные факторы: |
A - межсубъектный фактор | $$(n _{between} - 1)$$ | $$MS _A / MS _{e\ b}$$
Остаточная (это B'(A) - фактор с повторными измерениями) | $$df _{e\ b} = n _{between} (n _{subj} - 1)$$ | 
Внутрисубъектные факторы: |
C | $$(n _{within} - 1)$$ | $$MS _C /MS _{e\ w}$$
A:C | $$(n _{between} - 1)(n _{within} - 1)$$ | $$MS _{A:C} / MS _{e\ w}$$
Остаточная (это С x B'(A)) | $$df _{e\ w} = n _{between}(n _{subj} - 1)(n _{within} - 1)$$ |

---

# Что должно быть в таблице результатов ?

>- Столбцы:
  - df
  - SS
  - MS
  - F
  - p

>- Строки:
  - A - межсубъектный фактор, 
  - остаточная изменчивость для межсубъектного фактора (B'(A)), 
  - C, С:А - внутрисубъектный фактор и взаимодействие, 
  - остаточная изменчивость для внутрисубъектного фактора (С*B'(A))

---

# Что есть что в результатах?


```r
rest$ANOVA
```

```
##        Effect DFn DFd    SSn SSd      F        p p<.05   ges
## 1 (Intercept)   1  19 1695.1 132 244.68 2.63e-12     * 0.880
## 2        BRTH   1  19   39.9 132   5.76 2.68e-02     * 0.147
## 3          O2   7 133   25.7 100   4.88 6.26e-05     * 0.100
## 4     BRTH:O2   7 133   56.4 100  10.69 1.23e-10     * 0.196
```


Effect      | $DF _n$ | $DF _d$         | $SS _n$        | $SS _d$        | $F$   | $p$   | $p<0.05$ | ges
----------- | ------- | --------------- | -------------- | -------------- | ----- | ----- | -------- | ---
(Intercept) |
BRTH |$$df _{BRTH}$$    | $$df _{e\ b}$$ | $$SS _{BRTH}$$    | $$SS _{e\ b}$$ | $$F = \frac {SS _{BRTH} / df _{BRTH}} {SS _{e\ b} / df _{e\ b}} = MS _{BRTH} / MS _{e\ b}$$ |
O2 |$$df _{O2}$$      | $$df _{e\ w}$$ | $$SS _{O2}$$      | $$SS _{e\ w}$$ | $$F = \frac {SS _{O2} / df _{O2}} {SS _{e\ w} / df _{e\ w}} = MS _{O2} / MS _{e\ w}$$ |
BRTH:O2 |$$df _{BRTH:O2}$$ | $$df _{e\ w}$$ | $$SS _{BRTH:O2}$$ | $$SS _{e\ w}$$ | $$F = \frac {SS _{BRTH:O2} / df _{BRTH:O2}} {SS _{e\ w} / df _{e\ w}} = MS _{BRTH:O2} / MS _{e\ w}$$ |

--- &twocol

# Недостающее можем посчитать сами

Effect      | $DF _n$ | $DF _d$         | $SS _n$        | $SS _d$        | $F$   | $p$   | $p<0.05$ | ges
----------- | ------- | --------------- | -------------- | -------------- | ----- | ----- | -------- | ---
(Intercept) |
BRTH |$$df _{BRTH}$$    | $$df _{e\ b}$$ | $$SS _{BRTH}$$    | $$SS _{e\ b}$$ | $$F = \frac {SS _{BRTH} / df _{BRTH}} {SS _{e\ b} / df _{e\ b}} = MS _{BRTH} / MS _{e\ b}$$ |
O2 |$$df _{O2}$$      | $$df _{e\ w}$$ | $$SS _{O2}$$      | $$SS _{e\ w}$$ | $$F = \frac {SS _{O2} / df _{O2}} {SS _{e\ w} / df _{e\ w}} = MS _{O2} / MS _{e\ w}$$ |
BRTH:O2 |$$df _{BRTH:O2}$$ | $$df _{e\ w}$$ | $$SS _{BRTH:O2}$$ | $$SS _{e\ w}$$ | $$F = \frac {SS _{BRTH:O2} / df _{BRTH:O2}} {SS _{e\ w} / df _{e\ w}} = MS _{BRTH:O2} / MS _{e\ w}$$ |

<br />

$MS _{e\ b} = \frac {SS _{e\ b}}{df _{e\ b}}$

$MS _{e\ w} = \frac {SS _{e\ w}}{df _{e\ w}}$

---

Take home messages
========================================================

>- Межиндивидуальная изменчивость - различие средних значений между субъектами
- Межиндивидуальная изменчивость может маскировать эффекты других факторов (направление изменения значений между измерениями у разных субъектов)


---

Дополнительные ресурсы
========================================================

- Quinn, Keough, 2002
- Logan, 2010
- Sokal, Rohlf, 1995 
- Zar, 2010
