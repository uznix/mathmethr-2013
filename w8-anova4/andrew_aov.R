library(XLConnect)
library(nlme)
# library(lme4)
library(ggplot2)

andr <- readWorksheetFromFile(file = "./data/andrew.xlsx", sheet = 1)
andr$patchrec <- factor(andr$patchrec)
andr$treat <- factor(andr$treat)
table(andr$treat, andr$patchrec)

# andr$patch <- factor(andr$patch)
# str(andr)
# table(andr$treat, andr$patch)

# Mixed, nested: treat fixed, patchrec random
# install.packages("GAD")
library(GAD) # Дисперсионный анализ по Underwood, 1997
table(andr$treat, andr$patchrec)
andr$treat <- as.fixed(andr$treat)
andr$patchrec <- as.random(andr$patchrec)
# Right result,  'classic' representation
model <- lm(algae ~ treat + patchrec %in% treat, data = andr)
model_ganova <- gad(model)
# Для проверки условий применимости
model_diag <- fortify(model)
# ggplot2::fortify(model) # если загружен lme4, в котором есть такая же fortify
# ...
# Посчитаем компоненты дисперсии в сбалансированном случае
MSa <-model_ganova$'Mean Sq'[1]
MSba <- model_ganova$'Mean Sq'[2]
MSe <- model_ganova$'Mean Sq'[3]
n <- 5 # квадратов на площадке
b <- 4 # площадок в тритменте
VCa <- (MSa - MSba)/(n*b) # интерпретация другая, это не компонента дисперсии, тк. фикс.фактор
VCba <- (MSba - MSe)/n
VCe <- MSe


# Посчитаем вручную значимость факторов путем сравнения моделей
# http://people.wku.edu/michael.collyer/biol.582.fall2011/Data_files/biol.582.rscript.11.nested.ANOVA.in.R
# make the models we need:
lm.null <- lm(algae ~1)
lm.full <- lm(algae ~ treat + patchrec %in% treat)
lm.no.nesting <- lm(algae ~ treat)
# A function for calculating SSE
SSE <- function(l){
  r <- resid(l)
  s <- t(r) %*% r
}
# SS for treat
SS.cages<-SSE(lm.null)-SSE(lm.no.nesting)
SS.nested.effect<-SSE(lm.no.nesting)-SSE(lm.full)
SSE<-SSE(lm.full)
# Results
SS.cages
SS.nested.effect
SSE



####### AOV ########
# treatment fixed, patch random
model_aov <- aov(algae ~ treat + Error(patch) , data = andr)
summary(model_aov)
aov_res <-summary(model_aov)
str(aov_res)
aov_res <- data.frame(aov_res[1][[1]])
# F and p are not computed

#### LME (NLME) ####
model_lme <- lme(algae ~ treat, random = ~ 1|patch, data=andr)
model_lme
# Random effects:
#   Formula: ~1 | patch
# (Intercept)  Residual
# StdDev:    17.15554 17.280046
anova(model_lme)
#              numDF denDF  F-value p-value
# (Intercept)     1    64 18.5550807  0.0001
# treat           3    12  2.7171019  0.0913
#  В случае сбалансированных данных, можно реконструировать MS из результатов lme()
# В результатах - компоненты дисперсии для случайных факторов, 
# можно подставить их в формулы для ожидаемых MS
vc <- VarCorr(model_lme) # компоненты дисперсии
vc  # все результаты, нужна 2я строка в 1м столбце - MSe
n <- 5 # квадратов в патче
b <- 4 # патча в тритменте
MSe <- VCe <- as.numeric(as.character(vc[2, 1]))
VCba <- as.numeric(as.character(vc[1, 1]))
MSba <- MSe + n * VCba
# Теперь можно рассчитать "компоненту дисперсии"
MSa <- 4809.71
VCa <- (MSa - MSba) / (n * b)


### LMER (LME4) ######
model_lmer <- lmer(algae ~ treat + (1|patch:treat), data=andr)
model_lmer
# Random effects:
#   Groups      Name        Std.Dev.
# patch:treat (Intercept) 17.156  
# Residual                17.280  
anova(model_lmer)
#       Df  Sum Sq Mean Sq F value
# treat  3 2433.95 811.316 2.71707
# wrong
model_lmer1 <- lmer(algae ~ treat + (treat|patch), data=andr)
model_lmer1
anova(model_lmer1)



############### UNBALANCED CASE #####################
# an Example which is similar to a breeding design
# http://people.wku.edu/michael.collyer/biol.582.fall2011/Data_files/biol.582.rscript.11.nested.ANOVA.in.R
library(MASS)
attach(genotype)
?genotype
genotype
str(genotype)
table(Mother, Litter)
Litter<-as.random(Litter)
Mother<-as.random(Mother)
gad(lm(Wt~Mother + Litter%in%Mother))
# ARGH!
# No need to do, just watch
library(lme4)
summary(lmer(Wt~Mother + (1|Litter)+(0+Mother|Litter )))


