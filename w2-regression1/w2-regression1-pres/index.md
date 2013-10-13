---
title       : Регрессионный анализ, часть 1
subtitle    : Математические методы в зоологии - на R, осень 2013
author      : Марина Варфоломеева
job         : Каф. Зоологии беспозвоночных, СПбГУ
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : idea      # 
widgets     : [mathjax]            # {mathjax, quiz, bootstrap}
mode        : standalone # {selfcontained, standalone, draft}
---




Знакомимся с линейными моделями
========================================================

- Модель простой линейной регрессии
- Проверка валидности модели
- Оценка качества подгонки модели







--- .learning

Вы сможете
========================================================

- подобрать модель линейной регрессии и записать ее в виде уравнения
- проверить валидность модели при помощи t- или F-теста
- оценить долю изменчивости, которую объясняет модель, при помощи $R^2$

--- .segue

Модель простой линейной регрессии
========================================================

---

Линейная регрессия
========================================================

- простая

$$Y _i = β _0 + βx _i + \epsilon _i$$

- множественная

$$Y _i = β _0 + βx _{1 i} + + βx _{2 i} + ... + \epsilon _i$$

---

Запись моделей в R
========================================================


```r
зависимая_переменная ~ модель
```


<br \>
$\hat y _i = b _0 + bx _i$ (простая линейная регрессия со свободным членом (intercept))
  - Y ~ X
  - Y ~ 1 + X 
  - Y ~ X + 1

$\hat y _i = bx _i$ (простая линейная регрессия без свободного члена)
  - Y ~ X - 1
  - Y ~ -1 + X

$\hat y _i = b _0$ (уменьшенная модель, линейная регрессия y от свободного члена)
  - Y ~ 1
  - Y ~ 1 - X

--- .prompt

Запишите в нотации R
========================================================
эти модели линейных регрессий

- $\hat y _i = b _0 + bx _{1 i} + bx _{2 i} + bx _{3 i}$ (множественная линейная регрессия со свободным членом)

- $\hat y _i = b _0 + bx _{1 i} + bx _{3 i}$ (уменьшенная модель множественной линейной регрессии, без $X2$)

*** pnotes

$\hat y _i = b _0 + bx _{1 i} + bx _{2 i} + bx _{3 i}$ 
  - Y ~ X1 + X2 + X3
  - Y ~ 1 + X1 + X2 + X3

$\hat y _i = b _0 + bx _{1 i} + bx _{3 i}$ 
  - Y ~ X1 + X3
  - Y ~ 1 + X1 + X3

--- &twocol

Минимизируем остаточную изменчивость
========================================================

*** left

$Y _i = β _0 + βx _i + \epsilon _i$ - модель регрессии

$\hat y _i = b _0 + b _1 x _i$ - оценка модели

нужно оценить $\beta _0$, $\beta _1$ и $σ^2$

![Линия регрессии по методу наименьших квадратов](./assets/img/OLS-regression-line.png "Линия регрессии по методу наименьших квадратов")

*** right

- Метод наименьших квадратов (Ordinary Least Squares, см. рис.)

<br />
<br />
Еще есть методы максимального правдоподобия (Maximum Likelihood, REstricted Maximum Likelihood)

<div class="footnote">Рисунок из кн. Quinn, Keough, 2002, стр. 85, рис. 5.6 a</div>

---

Оценки параметров линейной регрессии
========================================================

минимизируют $\sum{(y _i - \hat y _i)^2}$, т.е. остатки.

Параметры     | Оценки параметров | Стандартные ошибки оценок
------- | --------- | -----
$\beta _1$    | $$b _1 = \frac {\sum _{i=1}^{n} {[(x _i - \bar x)(y _i - \bar y)]}}{\sum _{i=1}^{n} {(x _i - \bar x)^2}}$$      | $$SE _{b _1} = \sqrt{\frac{MS _e}{\sum _{i=1}^{n} {(x _i - \bar x)^2}}}$$
$\beta _0$    | $$b _0 = \bar y - b _1 \bar x$$  | $$SE _{b _0} = \sqrt{MS _e [\frac{1}{n} + \frac{\bar x}{\sum _{i=1}^{n} {(x _i - \bar x)^2}}]}$$
$\epsilon _i$ | $$e _i = y _i - \hat y _i$$      | $$\approx \sqrt{MS _e}$$

>-  Стандартные ошибки коэффициентов нужны
  - для построения доверительных интервалов
  - для статистических тестов

<div class="footnote">Таблица из кн. Quinn, Keough, 2002, стр. 86, табл. 5.2</div>

---

Коэффициенты регрессии
========================================================

![Интерпретация коэффициентов регрессии](./assets/img/interpretation-of-regression-coefficients.png "Интерпретация коэффициентов регрессии")

<div class="footnote">Рисунок из кн. Logan, 2010, стр. 170, рис. 8.2</div>


>- Если нужно сравнивать - лучше стандартизованные (= "бета коэффициенты") коэффициенты (на след.лекции про сравнение моделей)
  - $b^\ast _1 = {b _1  {\sigma _x} \over {\sigma _y}}$
  - не зависят от масштаба

--- .sub-section &twocol

Пример: усыхающие личинки мучных хрущаков
=========================================================

Как зависит потеря влаги личинками [малого мучного хрущака](http://ru.wikipedia.org/wiki/Хрущак_малый_мучной) _Tribolium confusum_ от влажности воздуха? (Nelson, 1964)

*** left

9 экспериментов, продолжительность 6 дней
- разная относительная влажность воздуха, % (`humidity`)
- измерена потеря влаги, мг (`weightloss`)

Данные в файлах `nelson.xlsx` и `nelson.csv`

*** right

![Малый мучной хрущак Tribolium confusum](./assets/img/Tribolium_confusum.jpg "Малый мучной хрущак Tribolium confusum")

<div class = "footnote">Данные из Sokal, Rohlf, 1997, табл. 14.1 по Logan, 2010. глава 8, пример 8c</div>

---

Читаем данные из файла и знакомимся с ними
=========================================================




Внимание, установите рабочую директорию, или используйте полный путь к файлу


```r
setwd("C:\\mathmethr\week2")
## из .xlsx
library(XLConnect)
wb <- loadWorkbook(".\data\nelson.xlsx")
nelson <- readWorksheet(wb, sheet = 1)
## или из .csv 
# nelson <- read.table(file=".\data\nelson.xlsx", header = TRUE, sep = "\t", dec = ".") 
```


```r
str(nelson)
```

```
## 'data.frame':	9 obs. of  2 variables:
##  $ humidity  : num  0 12 29.5 43 53 62.5 75.5 85 93
##  $ weightloss: num  8.98 8.14 6.67 6.08 5.9 5.83 4.68 4.2 3.72
```

```r
head(nelson)
```

```
##   humidity weightloss
## 1      0.0       8.98
## 2     12.0       8.14
## 3     29.5       6.67
## 4     43.0       6.08
## 5     53.0       5.90
## 6     62.5       5.83
```


---
Как зависит потеря веса от влажности? График рассеяния.
========================================================

```r
library(ggplot2)
p_nelson <- ggplot(data=nelson, aes(x = humidity, y = weightloss)) + 
  geom_point() + 
  labs(x = "Относительная влажность, %", y = "Потеря веса, мг")
p_nelson
```

<img src="figure/unnamed-chunk-6.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />


---
Внешний вид графиков можно менять при помощи тем
========================================================




```r
p_nelson + theme_classic()
p_nelson + theme_bw()
theme_set(theme_classic()) # устанавливаем понравившуюся тему до конца сессии
```


<img src="figure/unnamed-chunk-9.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" style="display: block; margin: auto;" />


---
Подбираем параметры линейной модели
========================================================

```r
nelson_lm <- lm(weightloss ~ humidity, nelson)
summary(nelson_lm)
```

```
## 
## Call:
## lm(formula = weightloss ~ humidity, data = nelson)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.4640 -0.0344  0.0167  0.0746  0.4524 
## 
## Coefficients:
##             Estimate Std. Error t value      Pr(>|t|)    
## (Intercept)  8.70403    0.19156    45.4 0.00000000065 ***
## humidity    -0.05322    0.00326   -16.4 0.00000078161 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.297 on 7 degrees of freedom
## Multiple R-squared:  0.974,	Adjusted R-squared:  0.971 
## F-statistic:  267 on 1 and 7 DF,  p-value: 0.000000782
```


---

Добавим линию регрессии на график
========================================================

```r
p_nelson + geom_smooth(method = "lm")
```

<img src="figure/unnamed-chunk-11.png" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" style="display: block; margin: auto;" />


--- .prompt

Как вы думаете,
========================================================
что это за серая область вокруг линии регрессии?


```r
p_nelson + geom_smooth(method = "lm")
```

<img src="figure/unnamed-chunk-12.png" title="plot of chunk unnamed-chunk-12" alt="plot of chunk unnamed-chunk-12" style="display: block; margin: auto;" />


*** pnotes

Это 95% доверительная зона регрессии.

В ней с 95% вероятностью лежит регрессионная прямая.   

Возникает из-за неопределенности оценок коэффициентов регрессии.


--- .segue

Неопределенность оценок коэффициентов и предсказанных значений
========================================================

---
Неопределенность оценок коэффициентов
========================================================

>- __Доверительный интервал коэффициента__
  - зона, в которой с $(1 - \alpha) \cdot 100\%$ вероятностью содержится среднее значение коэффициента<br />
  - <large>$b _1 \pm t _{\alpha, df = n - 2}SE _{b _1}$</large><br />
  - $\alpha = 0.05$ => $(1 - 0.05) \cdot 100\% = 95\%$ интервал
<br /><br /><br />
>- __Доверительная зона регрессии__
  - зона, в которой с $(1 - \alpha) \cdot 100$% вероятностью лежит регрессионная прямая

---
Находим доверительные интервалы коэффициентов
===================================================

```r
# Вспомните, в выдаче summary(nelson_lm) были только оценки коэффициентов 
# и стандартные ошибки

# оценки коэффициентов отдельно
coef(nelson_lm)
```

```
## (Intercept)    humidity 
##      8.7040     -0.0532
```

```r

# доверительные интервалы коэффициентов
confint(nelson_lm)
```

```
##               2.5 %  97.5 %
## (Intercept)  8.2510  9.1570
## humidity    -0.0609 -0.0455
```



--- &twocol w1:60% w2:40% 

Оценим, какова средняя потеря веса при заданной влажности 
===================================================
__Нельзя давать оценки вне интервала значений $X$!__

*** left


```r
# новые данные для предсказания значений
newdata <- data.frame(humidity = c(50, 100)) 
predict(nelson_lm, newdata, 
        interval = "confidence", se = TRUE) 
```

```
## $fit
##    fit  lwr  upr
## 1 6.04 5.81 6.28
## 2 3.38 2.93 3.83
## 
## $se.fit
##      1      2 
## 0.0989 0.1894 
## 
## $df
## [1] 7
## 
## $residual.scale
## [1] 0.297
```

```r
# доверительный интервал к среднему значению
```


*** right

<img src="figure/unnamed-chunk-15.png" title="plot of chunk unnamed-chunk-15" alt="plot of chunk unnamed-chunk-15" style="display: block; margin: auto;" />


>- При 50 и 100% относительной влажности ожидаемая средняя потеря веса жуков будет 6 $\pm$ 0.2 и 3.4 $\pm$ 0.4, соответственно.

---

Строим доверительную зону регрессии
===================================================

```r
p_nelson + geom_smooth(method = "lm") + 
  ggtitle ("95% доверительная зона регрессии")
p_nelson + geom_smooth(method = "lm", level = 0.99) + 
  ggtitle ("99% доверительная зона регрессии")
```

<img src="figure/unnamed-chunk-17.png" title="plot of chunk unnamed-chunk-17" alt="plot of chunk unnamed-chunk-17" style="display: block; margin: auto;" />


---

Неопределенность оценок предсказанных значений
===================================================

>- __Доверительный интервал к предсказанному значению__
  - зона в которую попадают $(1 - \alpha) \cdot 100$% значений $\hat y _i$ при данном $x _i$<br />
  - <large>$\hat y _i \pm t _{0.05, n - 2}SE _{\hat y _i}$</large><br />
  - <large>$SE _{\hat y} = \sqrt{MS _{e} [1 + \frac{1}{n} + \frac{(x _{prediction} - \bar x)^2} {\sum _{i=1}^{n} {(x _{i} - \bar x)^2}}]}$</large>
<br /><br /><br />

>- __Доверительная область значений регрессии__
  - зона, в которую попадает $(1 - \alpha) \cdot 100$% всех предсказанных значений

--- &twocol w1:60% w2:40% 

Предсказываем для новых значений
===================================================
__Нельзя использовать для предсказаний вне интервала значений $X$!__

*** left


```r
# новые данные для предсказания значений
newdata <- data.frame(humidity = c(50, 100)) 
predict(nelson_lm, newdata, 
        interval = "prediction", se = TRUE)
```

```
## $fit
##    fit  lwr  upr
## 1 6.04 5.30 6.78
## 2 3.38 2.55 4.21
## 
## $se.fit
##      1      2 
## 0.0989 0.1894 
## 
## $df
## [1] 7
## 
## $residual.scale
## [1] 0.297
```

```r
# зона, в которой будут лежать 95% всех значений
```


*** right

<img src="figure/unnamed-chunk-19.png" title="plot of chunk unnamed-chunk-19" alt="plot of chunk unnamed-chunk-19" style="display: block; margin: auto;" />


>- У 95% жуков при 50 и 100% относительной влажности будет потеря веса будет в пределах 6 $\pm$ 0.7 и 3.4 $\pm$ 0.8, соответственно.

---
Данные для доверительной области значений
===================================================

```r
# предсказанные значения для исходных данных
predict(nelson_lm, interval = "prediction")
```

```
## Warning: predictions on current data refer to _future_ responses
```

```
##    fit  lwr  upr
## 1 8.70 7.87 9.54
## 2 8.07 7.27 8.86
## 3 7.13 6.38 7.89
## 4 6.42 5.67 7.16
## 5 5.88 5.14 6.62
## 6 5.38 4.63 6.12
## 7 4.69 3.92 5.45
## 8 4.18 3.39 4.97
## 9 3.75 2.95 4.56
```

```r
# объединим с исходными данными в новом датафрейме - для графиков
nelson_with_pred <- data.frame(nelson, predict(nelson_lm, interval = "prediction"))
```

```
## Warning: predictions on current data refer to _future_ responses
```


---
Строим доверительную область значений и доверительный интервал
===================================================

```r
p_nelson + geom_smooth(method = "lm", aes(fill = "Доверительный интервал"), alpha = 0.4) +
  geom_ribbon(data = nelson_with_pred, 
              aes(y = fit, ymin = lwr, ymax = upr, fill = "Доверительная область значений"), 
              alpha = 0.2) +
  scale_fill_manual('Интервалы', values = c('green', 'blue'))
```

<img src="figure/unnamed-chunk-21.png" title="plot of chunk unnamed-chunk-21" alt="plot of chunk unnamed-chunk-21" style="display: block; margin: auto;" />


--- .segue

Проверка валидности модели
========================================================
## $H _0: \beta _1 = 0$

## или t-, или F-тест

---

Проверка при помощи t-критерия
========================================================

$H _0 : b _1 = \theta$, $\theta = 0$
$$t = \frac{b _1 - \theta}{SE _{b _1}}$$
$df = n - 2$

---

Проверка коэффициентов с помощью t-критерия есть в сводке модели
========================================================

```r
summary(nelson_lm)
```

```
## 
## Call:
## lm(formula = weightloss ~ humidity, data = nelson)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.4640 -0.0344  0.0167  0.0746  0.4524 
## 
## Coefficients:
##             Estimate Std. Error t value      Pr(>|t|)    
## (Intercept)  8.70403    0.19156    45.4 0.00000000065 ***
## humidity    -0.05322    0.00326   -16.4 0.00000078161 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.297 on 7 degrees of freedom
## Multiple R-squared:  0.974,	Adjusted R-squared:  0.971 
## F-statistic:  267 on 1 and 7 DF,  p-value: 0.000000782
```


>- Увеличение относительной влажности привело к достоверному замедлению потери веса жуками ($b _1 = -0.053$, $t = - 16.35$, $p < 0.01$)

---

Проверка при помощи F-критерия
========================================================

$H _0: \beta _1 = 0$ 

- Та же самая нулевая гипотеза. Как так получается?

---

Общая изменчивость - отклонения от общего среднего значения
========================================================
$SS _{total}$
--------------------------------------------------------

<div style="line-height: 500px;">
<img style="vertical-align: middle;" src="./assets/img/total-variation.png" alt="Общая изменчивость" title="Общая изменчивость">
</div>

<div class="footnote">
Рисунок из кн. Logan, 2010, стр. 172, рис. 8.3 a
</div>

--- &twocol

$SS _{total} = SS _{regression} + SS _{error}$
--------------------------------------------------------

*** left

<div style="line-height: 500px;">
<img style="vertical-align: middle;" src="./assets/img/total-variation.png" alt="Общая изменчивость" title="Общая изменчивость">
</div>

<div class="footnote">
Рисунок из кн. Logan, 2010, стр. 172, рис. 8.3 a-c
</div>

*** right

![Объясненная регрессией изменчивость](./assets/img/explained-variation.png "Объясненная регрессией изменчивость")
![Остаточная изменчивость](./assets/img/residual-variation.png "Остаточная изменчивость")

--- &twocol

Если зависимости нет, $b _1 = 0$
========================================================

*** left
<div>
Тогда $\hat y _i = \bar y _i$
<br />
и $MS _{regression} \approx MS _{error}$
</div>

<div style="line-height: 400px;">
<img style="vertical-align: middle;" src="./assets/img/total-variation.png" alt="Общая изменчивость" title="Общая изменчивость">
</div>

<div class="footnote">
Рисунок из кн. Logan, 2010, стр. 172, рис. 8.3 a-c
</div>

*** right

![Объясненная регрессией изменчивость](./assets/img/explained-variation.png "Объясненная регрессией изменчивость")
![Остаточная изменчивость](./assets/img/residual-variation.png "Остаточная изменчивость")

*** pnotes

Что оценивают средние квадраты отклонений?

Источник изменчивости  |  Суммы квадратов отклонений<br />SS |   Число степеней свободы<br />df   | Средний квадрат отклонений<br />MS | Ожидаемый средний квадрат
---------------------- | ----- | ------ | ------------------- | -----
Регрессия | $$\sum{(\bar y - \hat y _i)^2}$$ | $$1$$ | $$\frac{\sum _{i=1}^{n}{(\bar y - \hat y _i)^2}}{1}$$ | $$\sigma _{\epsilon} ^2 + {\beta _1} ^2 \sum _{i=1}^{n} {(x _i - \bar x)^2}$$
Остаточная | $$\sum{(y _i - \hat y _i)^2}$$ | $$n - 2$$ | $$\frac{\sum _{i=1}^{n}{(y _i - \hat y _i)^2}}{n - 2}$$ | $$\sigma _{\epsilon} ^2$$
Общая | $$\sum {(\bar y - y _i)^2}$$ | $$n - 1$$ | 

<br />
Если $b _1 = 0$, тогда $\hat y _i = \bar y _i$ и $MS _{regression} \approx MS _{error}$

Тестируем:

$$F = {MS _{regression} \over MS _{error}}$$

--- &twocol

F-критерий и распределение F-статистики
========================================================

$$F = \frac {Объясненная\ изменчивость}{Необъясненная\ изменчивость} = \frac {MS _{regression}} {MS _{error}}$$


*** left

![Распределение F-статистики](./assets/img/f-distribution.png "Распределение F-статистики")

F-распределение при $H _0: b _1 = 0$ 

*** right

<br />
<br />
Зависит от

  - $\alpha$
  
  - $df _{regression}$
  
  - $df _{error}$

<div class="footnote">Рисунок с изменениями из кн. Logan, 2010, стр. 172, рис. 8.3 d</div>

---

Таблица результатов дисперсионного анализа
========================================================

Источник изменчивости  |  Суммы квадратов отклонений,<br /> SS   |   Число степеней свободы,<br /> df   | Средний квадрат отклонений,<br /> MS | F  
---------------------- | --------- | ------ | ------------------- | -----
Регрессия | $$SS _r = \sum{(\bar y - \hat y _i)^2}$$ | $$df _r = 1$$ | $$MS _r = \frac{SS _r}{df _r}$$ | $$F _{df _r, df _e} = \frac{MS _r}{MS _e}$$
Остаточная | $$SS _e = \sum{(y _i - \hat y _i)^2}$$ | $$df _e = n - 2$$ | $$MS _e = \frac{SS _e}{df _e}$$ | 
Общая | $$SS _t = \sum {(\bar y - y _i)^2}$$ | $$df _t = n - 1$$ | 

<br />
>- Минимальное упоминание в тексте - $F _{df _r, df _e}$, $p$

---

Проверяем валидность модели при помощи F-критерия
========================================================

```r
nelson_aov <- aov(nelson_lm)
summary(nelson_aov)
```

```
##             Df Sum Sq Mean Sq F value     Pr(>F)    
## humidity     1  23.51   23.51     267 0.00000078 ***
## Residuals    7   0.62    0.09                       
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


<br />
>- Количество влаги, потерянной жуками в период эксперимента, достоверно зависело от уровня относительной влажности ($F _{1, 7} = 267$, $p < 0.01$).

--- .segue

Оценка качества подгонки модели
========================================================

---

Коэффициент детерминации
========================================================
доля общей изменчивости, объясненная линейной связью x и y

$R^2 = \frac {SS _r} {SS _t}$

$0 \le R^2 \le 1$

<br /><br />
Иначе рассчитывается как $R^2 = r^2$

---

Коэффициент детерминации 
========================================================
можно найти в сводке модели

>- Осторожно, не сравнивайте $R^2$ моделей с разным числом параметров, для этого есть $R^2 _{adjusted}$


```r
summary(nelson_lm)
```

```
## 
## Call:
## lm(formula = weightloss ~ humidity, data = nelson)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.4640 -0.0344  0.0167  0.0746  0.4524 
## 
## Coefficients:
##             Estimate Std. Error t value      Pr(>|t|)    
## (Intercept)  8.70403    0.19156    45.4 0.00000000065 ***
## humidity    -0.05322    0.00326   -16.4 0.00000078161 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.297 on 7 degrees of freedom
## Multiple R-squared:  0.974,	Adjusted R-squared:  0.971 
## F-statistic:  267 on 1 and 7 DF,  p-value: 0.000000782
```


---

Take home messages
========================================================
>- Модель простой линейной регрессии $y _i = \beta _0 + \beta _1 \dot x _i + \epsilon _i$

>- В оценке коэффициентов регрессии и предсказанных значений существует неопределенность. Доверительные интервалы можно расчитать, зная стандартные ошибки.

>- Валидность модели линейной регрессии можно проверить при помощи t- или F-теста. $H _0: \beta _1 = 0$

>- Качество подгонки модели можно оценить при помощи коэффициента детерминации $R^2$

---

Дополнительные ресурсы
========================================================
- Гланц, 1999, стр. 221-244
- Logan, 2010, pp. 170-207
- Quinn, Keough, 2002, pp. 78-110
- [Open Intro to Statistics](https://docs.google.com/viewer?docex=1&url=http://www.openintro.org/stat/down/OpenIntroStatSecond.pdf): [Chapter 7. Introduction to linear regression](https://docs.google.com/viewer?docex=1&url=http://www.openintro.org/stat/down/oiStat2_07.pdf), pp. 315-353.  
- Sokal, Rohlf, 1995, pp. 451-491
- Zar, 1999, pp. 328-355
