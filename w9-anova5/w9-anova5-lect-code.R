# title       : ������������� ������, ����� 5
# subtitle    : �������������� ������ � �������� - �� R, ����� 2013
# author      : ������ ������������
# ---
# ������ � ���������� �����������
library(XLConnect)
library(ez)
library(plyr)
library(reshape2)
library(gridExtra)
library(ggplot2)
theme_set(theme_bw() + theme(legend.key = element_blank()))
update_geom_defaults("point", list(shape = 19))

# ������: ����������� ������������ ������� � ������������� ���� ��� �������
# �������� �� ����� ����� ������ ������� � ������, ��� ������ �����? (Driscoll Roberts 1997)
# ��������� ���������� - ������� ����� ��������� ����� � �������� � ���������� �����
# - 6 ���������� ��������� (�� ������ �������� � �� �������� �����) 
# - 3 ���� ���������� (1992 - �� ������, 1993 � 1994 - ����� ������)
# ��������� $H _0$ � ���, ��� �������� ����� ��������� ����� ����� ��������� � ����������� ������� �� ����� ����������� �� �����.
frogs <- readWorksheetFromFile(file="./data/frogs.xlsx", 
                               sheet = 1)
head(frogs)

# �������������� ������������� ������ - ������� ������
wfrogs <- dcast(data=frogs, BLOCK~YEAR, value.var="CALLS")
wfrogs

# ���������� � ������� ��� � ����
frogs$YEAR <- factor(frogs$YEAR, labels = c("Y1", "Y2", "Y3"))
frogs$BLOCK <- factor(frogs$BLOCK)
str(frogs)

# ��������� ������� ����� ��������� �����
ggplot(data = frogs, aes(x = YEAR, y = CALLS)) + geom_boxplot()

# ���������������� �� ������?
table(frogs$BLOCK, frogs$YEAR)
ezDesign(frogs, x = YEAR, y = BLOCK)

# ��������� �������� ������ ��� ������ ezANOVA
(res <- ezANOVA(frogs, dv=.(CALLS), wid=.(BLOCK), within=.(YEAR), detailed = TRUE))
# ������������� ������
# ������� �� �������� ����������
ezStats(data = frogs, dv=.(CALLS), 
        wid=.(BLOCK), within=.(YEAR))

# ������ �������� ����� ������
ezPlot(data = frogs, dv=.(CALLS), 
       wid=.(BLOCK), within=.(YEAR), 
       x = YEAR)


# ������� �����������?
res$ANOVA

# ������� ����� ����� ��������� ����  
# ����������� ������ ����� ����� ������ ���� ��� �������������� c �����
# ���� �� ������ � ������ �������������� BLOCK � YEAR?
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

# ��������� �������������� ������� ������������ ��� ������� � ���������� �����������

# ������� ��������� - ��������� �������� � ���������� ����� � ���������� �����  
# �.�. �������� � ���� ������������ ���������
var(wfrogs[, -1])

# ����������� - ��������� ��������� ����� ����������� ������ ���� �����
sph <- data.frame(call12 = wfrogs[, 2] - wfrogs[, 3], 
                  call13 = wfrogs[, 4] - wfrogs[, 2], 
                  call23 = wfrogs[, 4] - wfrogs[, 3])
sph # �������� ����� ��������
colwise(var)(sph)

# ���� ����� (Mauchly) �� �����������
res$"Mauchly's Test for Sphericity"

# �������� �� �����������
# ����� �������� ���������?
res$"Sphericity Corrections"


# ����� ������� ������
# ������: �������� � ���
# ������� �� �������� � ����-��� (Mullens, 1993)
# ��������� ���������� - ������� ����������� �������
# - ��� ������ ���� - 8 ������� ������������ ��������� (0, 5, 10, 15, 20, 30, 40, 50%)  
# ��� ������ � ���������� ����������� (= "����������������", "within subjects")
# - � ������ ��� 2 ���� ������� (����������, ��������)  
# ��� ������� ������ (= "�������������", "between subjects")
# ��������� $H _0$ � ���, ��� ������� ����������� �������� �� ����� ���������� � ����������� �� ���� ������� � �� ������������ ���������.

toads <- read.table("./data/mullens.csv", 
                    header = TRUE, sep = ",")
head(toads)

# ��������������� ���������� � ������ ������� ���������
names(toads)[2:3] <- c("BRTH", "O2")
toads$O2 <- factor(toads$O2)
toads$TOAD <- factor(toads$TOAD)
toads$BRTH <- factor(toads$BRTH)
str(toads)

# ������ � ������� ������� �������� �� ��������
wtoads <- dcast(data=toads, TOAD + BRTH ~ O2, value.var="FREQBUC")
wtoads
# �� �� ����� ��� ���������� ������ �� ������� ����������� �������
wstoads <- dcast(data=toads, TOAD + BRTH ~ O2, value.var="SFREQBUC")
wstoads

# ��� ����� ������������ - ������� ����������� ������� ��� ������ �� ���?
# ������� ����������� �������� ��� ������ ���� �������
p <- ggplot(data = toads, aes(x = BRTH, y = FREQBUC)) + geom_boxplot()
grid.arrange(p, p %+% aes(y = SFREQBUC), ncol = 2)
# ������� ����������� �������� � ����������� �� ������������ ���������. 
# ����� - ��� ����� ���� �������, ������ - � ������ ���� �������
grid.arrange(p %+% aes(x = O2, y = FREQBUC),
             p %+% aes(x = O2, y = SFREQBUC), 
             p %+% aes(x = O2, y = FREQBUC, fill = BRTH) + 
               theme(legend.position = "bottom"),
             p %+% aes(x = O2, y = SFREQBUC, fill = BRTH) + 
               theme(legend.position = "bottom"), 
             ncol = 4)

# ���������������� �� ����� ������?
table(toads$BRTH, toads$O2)
table(toads$TOAD, toads$O2)
ezDesign(toads, x = TOAD, y = O2, row = BRTH)
# ezPrecis(toads)

# ������������� ������ � ���������� �����������
rest <- ezANOVA(toads, dv=.(SFREQBUC), wid=.(TOAD), within=.(O2), 
                between=.(BRTH), detailed = TRUE, type=3)
rest

# ���������� �� ��������
ezStats(toads, dv=.(SFREQBUC), wid=.(TOAD), within=.(O2), 
        between=.(BRTH), type = 3)

# ������ �������� ("interaction plot")
ezPlot(toads, dv=.(SFREQBUC), wid=.(TOAD), within=.(O2), 
       between=.(BRTH), type = 3, 
       x = O2, split = BRTH) + 
  theme(legend.position = c(0.85, 0.80), legend.key = element_blank())

# ��������� ������� ���������
var(wstoads[, -c(1, 2)])
# ��������� ����������� ��� ������ ����� �����
rest$"Mauchly's Test for Sphericity"

# ����� �������� ���������?
rest$'Sphericity Corrections'

# ������� �����������
rest$ANOVA
# ����������� ����� ��������� ����
# MS _{e\ b} = {SS _{e\ b}}/{df _{e\ b}}
# MS _{e\ w} = {SS _{e\ w}}/{df _{e\ w}}
